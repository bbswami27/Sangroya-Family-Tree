import 'dart:convert';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const SangroyaApp());
}

class SangroyaApp extends StatelessWidget {
  const SangroyaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SANGROYA FAMILY TREE',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF315C4B),
        ),
        useMaterial3: true,
      ),
      home: const FamilyHome(),
    );
  }
}

class Member {
  final String name;
  final String father;
  final String village;
  final String occupation;
  final String spouse;
  final String generation;
  final String notes;

  const Member({
    this.name = '',
    this.father = '',
    this.village = '',
    this.occupation = '',
    this.spouse = '',
    this.generation = '',
    this.notes = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'father': father,
      'village': village,
      'occupation': occupation,
      'spouse': spouse,
      'generation': generation,
      'notes': notes,
    };
  }

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      name: json['name'] ?? '',
      father: json['father'] ?? '',
      village: json['village'] ?? '',
      occupation: json['occupation'] ?? '',
      spouse: json['spouse'] ?? '',
      generation: json['generation'] ?? '',
      notes: json['notes'] ?? '',
    );
  }
}

class FamilyHome extends StatefulWidget {
  const FamilyHome({super.key});

  @override
  State<FamilyHome> createState() => _FamilyHomeState();
}

class _FamilyHomeState extends State<FamilyHome> {
  final List<Member> members = [];
  final List<TextEditingController> controllers =
      List.generate(7, (_) => TextEditingController());

  final List<String> labels = [
    'नाम / Name',
    'पिता का नाम / Father',
    'गाँव / Village / Place',
    'नौकरी या व्यवसाय / Occupation',
    'जीवनसाथी / Life Partner',
    'पीढ़ी संख्या / Generation',
    'अन्य जानकारी / Notes',
  ];

  String status = 'अपनी Family की जानकारी जोड़ना शुरू करें';

  @override
  void initState() {
    super.initState();
    loadMembers();
  }

  @override
  void dispose() {
    for (final controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> loadMembers() async {
    final preferences = await SharedPreferences.getInstance();
    final saved = preferences.getString('members');
    if (saved == null) return;

    final decoded = jsonDecode(saved) as List<dynamic>;
    if (!mounted) return;
    setState(() {
      members.addAll(
        decoded.map(
          (item) => Member.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        ),
      );
    });
  }

  Future<void> saveMembers() async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      members.map((member) => member.toJson()).toList(),
    );
    await preferences.setString('members', encoded);
  }

  Future<void> addMember() async {
    final name = controllers[0].text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Member का नाम भरें')),
      );
      return;
    }

    final member = Member(
      name: name,
      father: controllers[1].text.trim(),
      village: controllers[2].text.trim(),
      occupation: controllers[3].text.trim(),
      spouse: controllers[4].text.trim(),
      generation: controllers[5].text.trim(),
      notes: controllers[6].text.trim(),
    );

    setState(() {
      members.add(member);
      status = 'Member सुरक्षित कर दिया गया';
    });
    await saveMembers();

    for (final controller in controllers) {
      controller.clear();
    }
  }

  Future<void> importExcel() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
      withData: true,
    );

    if (picked == null || picked.files.single.bytes == null) return;

    try {
      final workbook = Excel.decodeBytes(picked.files.single.bytes!);
      final imported = <Member>[];

      for (final sheet in workbook.tables.values) {
        if (sheet.rows.isEmpty) continue;

        final headers = sheet.rows.first
            .map((cell) => (cell?.value?.toString() ?? '')
                .toLowerCase()
                .trim())
            .toList();

        int findColumn(List<String> candidates) {
          for (var index = 0; index < headers.length; index++) {
            if (candidates.any((candidate) =>
                headers[index].contains(candidate))) {
              return index;
            }
          }
          return -1;
        }

        final columns = [
          findColumn(['name', 'नाम', 'member']),
          findColumn(['father', 'पिता']),
          findColumn(['village', 'गांव', 'गाँव', 'place']),
          findColumn(['occupation', 'job', 'नौकरी', 'काम']),
          findColumn(['spouse', 'husband', 'wife', 'जीवनसाथी']),
          findColumn(['generation', 'पीढ़ी', 'pidhi']),
          findColumn(['notes', 'remark', 'विवरण']),
        ];

        if (columns[0] == -1) continue;

        String cellText(List<Data?> row, int column) {
          if (column < 0 || column >= row.length) return '';
          return row[column]?.value?.toString() ?? '';
        }

        for (final row in sheet.rows.skip(1)) {
          final memberName = cellText(row, columns[0]).trim();
          if (memberName.isEmpty) continue;

          imported.add(
            Member(
              name: memberName,
              father: cellText(row, columns[1]),
              village: cellText(row, columns[2]),
              occupation: cellText(row, columns[3]),
              spouse: cellText(row, columns[4]),
              generation: cellText(row, columns[5]),
              notes: cellText(row, columns[6]),
            ),
          );
        }
      }

      setState(() {
        members.addAll(imported);
        status = '${imported.length} records Excel से import हुए';
      });
      await saveMembers();
    } catch (error) {
      setState(() {
        status = 'Excel पढ़ने में समस्या: $error';
      });
    }
  }

  void openFamilyTree() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => FamilyTreePage(members: List<Member>.from(members)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SANGROYA FAMILY TREE'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'हमारे परिवार का डिजिटल इतिहास',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    '18 पीढ़ियों का Family Tree • Member Profiles • Village Records',
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: openFamilyTree,
                      icon: const Icon(Icons.account_tree),
                      label: const Text('पूरा Family Tree देखें'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'कुल सदस्य: ${members.length}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      FilledButton.icon(
                        onPressed: importExcel,
                        icon: const Icon(Icons.upload_file),
                        label: const Text('Excel Upload'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Text(status),
          const SizedBox(height: 12),
          const Text(
            'नया Family Member जोड़ें',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ...List.generate(
            labels.length,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: TextField(
                controller: controllers[index],
                decoration: InputDecoration(
                  labelText: labels[index],
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
          ),
          FilledButton.icon(
            onPressed: addMember,
            icon: const Icon(Icons.person_add),
            label: const Text('Member Save करें'),
          ),
          const Divider(height: 32),
          const Text(
            'Family Members',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          if (members.isEmpty)
            const Text(
              'अभी कोई Member नहीं है। ऊपर से जानकारी जोड़ें या Excel Upload करें।',
            ),
          ...members.asMap().entries.map(
            (entry) => Card(
              child: ListTile(
                leading: CircleAvatar(
                  child: Text(
                    entry.value.generation.isEmpty
                        ? '•'
                        : entry.value.generation,
                  ),
                ),
                title: Text(entry.value.name),
                subtitle: Text([
                  if (entry.value.father.isNotEmpty)
                    'पिता: ${entry.value.father}',
                  if (entry.value.village.isNotEmpty)
                    'गाँव: ${entry.value.village}',
                  if (entry.value.occupation.isNotEmpty)
                    'काम: ${entry.value.occupation}',
                  if (entry.value.spouse.isNotEmpty)
                    'जीवनसाथी: ${entry.value.spouse}',
                ].join(' | ')),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    setState(() {
                      members.removeAt(entry.key);
                    });
                    await saveMembers();
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'नोट: Hinglish अभी जैसे टाइप करेंगे वैसे ही सेव होगा। '
            'Hindi-English translation/transliteration अगली सुविधा में जोड़ी जाएगी। '
            'डेटा अभी केवल इसी फोन में सेव होता है।',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}


class FamilyTreePage extends StatelessWidget {
  final List<Member> members;

  const FamilyTreePage({super.key, required this.members});

  @override
  Widget build(BuildContext context) {
    final nameCounts = <String, int>{};
    for (final member in members) {
      final key = member.name.trim().toLowerCase();
      nameCounts[key] = (nameCounts[key] ?? 0) + 1;
    }

    final childrenByFather = <String, List<Member>>{};
    for (final member in members) {
      final fatherKey = member.father.trim().toLowerCase();
      if (fatherKey.isEmpty || nameCounts[fatherKey] != 1) continue;
      childrenByFather.putIfAbsent(fatherKey, () => <Member>[]).add(member);
    }

    final roots = members.where((member) {
      final fatherKey = member.father.trim().toLowerCase();
      return fatherKey.isEmpty || nameCounts[fatherKey] != 1;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('18 पीढ़ियों का Family Tree')),
      body: members.isEmpty
          ? const Center(
              child: Text('पहले Family Members जोड़ें या Excel Upload करें।'),
            )
          : ListView(
              padding: const EdgeInsets.all(12),
              children: [
                Card(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  child: const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      'यह Tree “पिता का नाम” के आधार पर बनता है। '
                      'जिस पिता का नाम सूची में एक ही सदस्य से मिलता है, '
                      'उसके बच्चे उसी शाखा में दिखेंगे। अधूरी या अस्पष्ट '
                      'जानकारी को अलग रखा गया है—रिश्ते अपने-आप नहीं माने गए हैं।',
                    ),
                  ),
                ),
                Text(
                  'कुल सदस्य: ${members.length}  •  मुख्य शाखाएँ: ${roots.length}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (roots.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        'कोई शुरुआती सदस्य नहीं मिला। पिता के नाम की जाँच करें; '
                        'संभव है रिकॉर्ड में चक्र या गलत नाम हो।',
                      ),
                    ),
                  ),
                ...roots.map(
                  (member) => _TreeMemberTile(
                    member: member,
                    childrenByFather: childrenByFather,
                    path: <String>{},
                    depth: 1,
                  ),
                ),
              ],
            ),
    );
  }
}

class _TreeMemberTile extends StatelessWidget {
  final Member member;
  final Map<String, List<Member>> childrenByFather;
  final Set<String> path;
  final int depth;

  const _TreeMemberTile({
    required this.member,
    required this.childrenByFather,
    required this.path,
    required this.depth,
  });

  @override
  Widget build(BuildContext context) {
    final key = member.name.trim().toLowerCase();
    final nextPath = <String>{...path, key};
    final children = childrenByFather[key] ?? <Member>[];
    final details = <String>[
      if (member.generation.isNotEmpty) 'पीढ़ी: ${member.generation}',
      if (member.father.isNotEmpty) 'पिता: ${member.father}',
      if (member.village.isNotEmpty) 'गाँव: ${member.village}',
      if (member.occupation.isNotEmpty) 'काम: ${member.occupation}',
      if (member.spouse.isNotEmpty) 'जीवनसाथी: ${member.spouse}',
    ].join('  •  ');

    final safeChildren = children
        .where((child) => !nextPath.contains(child.name.trim().toLowerCase()))
        .toList();

    return Card(
      margin: EdgeInsets.only(left: (depth - 1) * 12.0, bottom: 8),
      child: safeChildren.isEmpty
          ? ListTile(
              leading: CircleAvatar(child: Text(member.name.trim().isEmpty ? '?' : member.name.trim().substring(0, 1))),
              title: Text(member.name),
              subtitle: details.isEmpty ? const Text('विवरण उपलब्ध नहीं') : Text(details),
            )
          : ExpansionTile(
              initiallyExpanded: depth < 3,
              leading: CircleAvatar(child: Text(member.name.trim().isEmpty ? '?' : member.name.trim().substring(0, 1))),
              title: Text(member.name),
              subtitle: Text(details.isEmpty ? '${safeChildren.length} अगली पीढ़ी के सदस्य' : '$details  •  ${safeChildren.length} बच्चे'),
              children: safeChildren
                  .map(
                    (child) => _TreeMemberTile(
                      member: child,
                      childrenByFather: childrenByFather,
                      path: nextPath,
                      depth: depth + 1,
                    ),
                  )
                  .toList(),
            ),
    );
  }
}
