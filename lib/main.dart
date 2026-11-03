import 'dart:convert';
import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:image_picker/image_picker.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const SangroyaApp());
}
class SangroyaApp extends StatelessWidget {
 const SangroyaApp({super.key});
 @override Widget build(BuildContext context)=>MaterialApp(title:'SANGROYA FAMILY TREE',debugShowCheckedModeBanner:false,theme:ThemeData(
  useMaterial3:true,
  colorScheme:const ColorScheme(
    brightness:Brightness.light,
    primary:Color(0xFF176B3A),
    onPrimary:Colors.white,
    secondary:Color(0xFFFF8A00),
    onSecondary:Colors.white,
    error:Color(0xFFB3261E),
    onError:Colors.white,
    surface:Color(0xFFFFF8ED),
    onSurface:Color(0xFF183322),
  ),
  scaffoldBackgroundColor:const Color(0xFFF1F8F1),
  appBarTheme:const AppBarTheme(
    backgroundColor:Color(0xFF176B3A),
    foregroundColor:Colors.white,
    iconTheme:IconThemeData(color:Colors.white),
    titleTextStyle:TextStyle(color:Colors.white,fontSize:20,fontWeight:FontWeight.bold),
  ),
  floatingActionButtonTheme:const FloatingActionButtonThemeData(
    backgroundColor:Color(0xFFFF8A00),foregroundColor:Colors.white,
  ),
  filledButtonTheme:FilledButtonThemeData(style:FilledButton.styleFrom(
    backgroundColor:const Color(0xFFFF8A00),foregroundColor:Colors.white,
  )),
  cardTheme:const CardThemeData(color:Color(0xFFFFFDF7),elevation:2),
),home:const FamilyHome());
}
class Member {
 final String memberId,fatherId,motherId,spouseId;
 final String name,gender,father,mother,village,occupation,spouse,spouseCity,spouseCaste,spouseGotra,generation,dob,dod,marriageDate,visitedPlaces,visitYears,jobType,govtLevel,jobCompany,jobTitle,jobCountry,jobDetails,photoPath,notes,travelPlace,travelYear,travelDate,travelPurpose;
 const Member({this.memberId='',this.fatherId='',this.motherId='',this.spouseId='',this.name='',this.gender='',this.father='',this.mother='',this.village='',this.occupation='',this.spouse='',this.spouseCity='',this.spouseCaste='',this.spouseGotra='',this.generation='',this.dob='',this.dod='',this.marriageDate='',this.visitedPlaces='',this.visitYears='',this.jobType='',this.govtLevel='',this.jobCompany='',this.jobTitle='',this.jobCountry='',this.jobDetails='',this.photoPath='',this.notes='',this.travelPlace='',this.travelYear='',this.travelDate='',this.travelPurpose=''});
 Map<String,dynamic> toJson()=>{'memberId':memberId,'fatherId':fatherId,'motherId':motherId,'spouseId':spouseId,'name':name,'gender':gender,'father':father,'mother':mother,'village':village,'occupation':occupation,'spouse':spouse,'spouseCity':spouseCity,'spouseCaste':spouseCaste,'spouseGotra':spouseGotra,'generation':generation,'dob':dob,'dod':dod,'marriageDate':marriageDate,'visitedPlaces':visitedPlaces,'visitYears':visitYears,'jobType':jobType,'govtLevel':govtLevel,'jobCompany':jobCompany,'jobTitle':jobTitle,'jobCountry':jobCountry,'jobDetails':jobDetails,'photoPath':photoPath,'notes':notes,'travelPlace':travelPlace,'travelYear':travelYear,'travelDate':travelDate,'travelPurpose':travelPurpose};
 factory Member.fromJson(Map<String,dynamic> j)=>Member(memberId:j['memberId']??'',fatherId:j['fatherId']??'',motherId:j['motherId']??'',spouseId:j['spouseId']??'',name:j['name']??'',gender:j['gender']??'',father:j['father']??'',mother:j['mother']??'',village:j['village']??'',occupation:j['occupation']??'',spouse:j['spouse']??'',spouseCity:j['spouseCity']??'',spouseCaste:j['spouseCaste']??'',spouseGotra:j['spouseGotra']??'',generation:j['generation']??'',dob:j['dob']??'',dod:j['dod']??'',marriageDate:j['marriageDate']??'',visitedPlaces:j['visitedPlaces']??'',visitYears:j['visitYears']??'',jobType:j['jobType']??'',govtLevel:j['govtLevel']??'',jobCompany:j['jobCompany']??'',jobTitle:j['jobTitle']??'',jobCountry:j['jobCountry']??'',jobDetails:j['jobDetails']??'',photoPath:j['photoPath']??'',notes:j['notes']??'',travelPlace:j['travelPlace']??'',travelYear:j['travelYear']??'',travelDate:j['travelDate']??'',travelPurpose:j['travelPurpose']??'');
}
class FamilyDocument { final String name,path,type; final int size; FamilyDocument({required this.name,required this.path,required this.type,required this.size}); Map<String,dynamic> toJson()=>{'name':name,'path':path,'type':type,'size':size}; factory FamilyDocument.fromJson(Map<String,dynamic> j)=>FamilyDocument(name:j['name']??'',path:j['path']??'',type:j['type']??'',size:j['size']??0); }
class FamilyHome extends StatefulWidget {const FamilyHome({super.key});@override State<FamilyHome> createState()=>_FamilyHomeState();}
class _FamilyHomeState extends State<FamilyHome>{
 final List<Member> members=[]; final List<FamilyDocument> documents=[]; String status='परिवार की जानकारी जोड़ें';
 @override void initState(){super.initState();load();}
 Future<void> load()async{final p=await SharedPreferences.getInstance();final s=p.getString('members');if(s!=null){try{final a=(jsonDecode(s) as List).map((e)=>Member.fromJson(Map<String,dynamic>.from(e))).toList();if(mounted){members.addAll(a);_ensureMemberIdsAndLinks();await save();}}catch(_){}} final ds=p.getString('family_documents'); if(ds!=null){try{final a=(jsonDecode(ds) as List).map((e)=>FamilyDocument.fromJson(Map<String,dynamic>.from(e))).toList();if(mounted)setState(()=>documents.addAll(a));}catch(_){}}}
 Future<void> save()async{final p=await SharedPreferences.getInstance();await p.setString('members',jsonEncode(members.map((m)=>m.toJson()).toList()));await p.setString('family_documents',jsonEncode(documents.map((d)=>d.toJson()).toList()));}
 void _ensureMemberIdsAndLinks() {
   final now = DateTime.now().microsecondsSinceEpoch;
   final used = <String>{};
   for (var i=0;i<members.length;i++) {
     final m=members[i];
     var id=m.memberId.trim();
     if(id.isEmpty || used.contains(id)) id='SFT-${now}-${i+1}';
     used.add(id);
     if(id!=m.memberId) members[i]=Member.fromJson({...m.toJson(),'memberId':id});
   }
   String norm(String v)=>v.trim().toLowerCase().replaceAll(RegExp(r'\\s+'),' ');
   int? gen(Member m)=>int.tryParse(m.generation.trim());
   Member? uniqueParent(String name, Member child) {
     if(name.trim().isEmpty)return null;
     final matches=members.where((x)=>norm(x.name)==norm(name)).toList();
     if(matches.length==1)return matches.first;
     final cg=gen(child);
     if(cg!=null){final adjacent=matches.where((x)=>gen(x)==cg-1).toList();if(adjacent.length==1)return adjacent.first;}
     return null;
   }
   Member? uniqueSpouse(String name) {
     if(name.trim().isEmpty)return null;
     final matches=members.where((x)=>norm(x.name)==norm(name)).toList();
     return matches.length==1?matches.first:null;
   }
   for(var i=0;i<members.length;i++){
     final m=members[i];
     final father=uniqueParent(m.father,m);
     final mother=uniqueParent(m.mother,m);
     final spouse=uniqueSpouse(m.spouse);
     members[i]=Member.fromJson({...m.toJson(),
       'fatherId':father?.memberId ?? m.fatherId,
       'motherId':mother?.memberId ?? m.motherId,
       'spouseId':spouse?.memberId ?? m.spouseId,
     });
   }
 }
 Future<void> uploadDocument() async { final picked=await FilePicker.platform.pickFiles(type:FileType.custom,allowedExtensions:['pdf','jpg','jpeg','png'],withData:true); if(picked==null)return; final f=picked.files.single; if(f.bytes==null)return; final dir=await getApplicationDocumentsDirectory(); final folder=Directory('${dir.path}/family_documents'); await folder.create(recursive:true); final safe='${DateTime.now().millisecondsSinceEpoch}_${f.name.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'),'_')}'; final file=File('${folder.path}/$safe'); await file.writeAsBytes(f.bytes!,flush:true); setState(()=>documents.add(FamilyDocument(name:f.name,path:file.path,type:(f.extension??'').toLowerCase(),size:f.size))); await save(); setState(()=>status='Document अपलोड हुआ: ${f.name}'); }
 Future<void> downloadDocument(FamilyDocument d) async { final file=File(d.path); if(!await file.exists()){setState(()=>status='मूल फाइल नहीं मिली');return;} final bytes=await file.readAsBytes(); await FilePicker.platform.saveFile(dialogTitle:'फाइल सेव करें',fileName:d.name,bytes:bytes); }
 Future<void> exportBackup() async { final payload=jsonEncode({'members':members.map((m)=>m.toJson()).toList(),'documents':documents.map((d)=>d.toJson()).toList()}); await FilePicker.platform.saveFile(dialogTitle:'Family Backup सेव करें',fileName:'Sangroya_Family_Backup.json',bytes:Uint8List.fromList(utf8.encode(payload))); }
 Future<void> edit([int? i])async{final m=await showDialog<Member>(context:context,builder:(_)=>MemberForm(member:i==null?const Member():members[i]));if(m!=null){setState((){if(i==null){members.add(m);}else{members[i]=m;} _ensureMemberIdsAndLinks();status='जानकारी सुरक्षित हुई';});await save();}}
 Future<void> importExcel() async {
  try {
    setState(() => status = 'Excel फाइल पढ़ी जा रही है...');
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
      withData: true,
    );
    if (picked == null) {
      if (mounted) setState(() => status = 'कोई Excel फाइल नहीं चुनी गई');
      return;
    }

    final file = picked.files.single;
    Uint8List? bytes = file.bytes;
    // Android पर कुछ file providers bytes नहीं देते, केवल path देते हैं।
    if (bytes == null && file.path != null) {
      final localFile = File(file.path!);
      if (await localFile.exists()) bytes = await localFile.readAsBytes();
    }
    if (bytes == null || bytes.isEmpty) {
      if (mounted) setState(() => status = 'फाइल पढ़ी नहीं जा सकी। कृपया Excel फाइल को फोन में डाउनलोड करके फिर चुनें।');
      return;
    }

    final extension = (file.extension ?? '').toLowerCase();
    if (extension == 'xls') {
      if (mounted) setState(() => status = 'कृपया फाइल को Excel में .xlsx फॉर्मेट में Save करके दोबारा Import करें।');
      return;
    }

    final workbook = Excel.decodeBytes(bytes);
    if (workbook.tables.isEmpty) {
      if (mounted) setState(() => status = 'Excel में कोई Worksheet नहीं मिली।');
      return;
    }

    final added = <Member>[];
    var skipped = 0;
    var foundNameColumn = false;

    String cleanHeader(Data? cell) {
      return (cell?.value?.toString() ?? '')
          .trim()
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
          .replaceAll(RegExp(r'\\s+'), ' ');
    }

    String cellText(List<Data?> row, int index) {
      if (index < 0 || index >= row.length) return '';
      final value = row[index]?.value;
      return value?.toString().trim() ?? '';
    }

    int findColumn(List<String> headers, List<String> aliases) {
      for (var i = 0; i < headers.length; i++) {
        if (aliases.any((alias) => headers[i] == alias || headers[i].contains(alias))) return i;
      }
      return -1;
    }

    for (final sheet in workbook.tables.values) {
      if (sheet.rows.isEmpty) continue;

      // Header row को पहले 5 rows में खोजें, ताकि ऊपर title/blank row होने पर भी import हो।
      var headerRowIndex = -1;
      var nameColumn = -1;
      for (var rowIndex = 0; rowIndex < sheet.rows.length && rowIndex < 5; rowIndex++) {
        final headers = sheet.rows[rowIndex].map(cleanHeader).toList();
        final candidate = findColumn(headers, ['name', 'member name', 'full name', 'पूरा नाम', 'नाम']);
        if (candidate >= 0) {
          headerRowIndex = rowIndex;
          nameColumn = candidate;
          break;
        }
      }
      if (headerRowIndex < 0) continue;
      foundNameColumn = true;

      final headers = sheet.rows[headerRowIndex].map(cleanHeader).toList();
      int col(List<String> names) => findColumn(headers, names);
      final nameIx = nameColumn;

      for (final row in sheet.rows.skip(headerRowIndex + 1)) {
        final name = cellText(row, nameIx);
        if (name.isEmpty) {
          skipped++;
          continue;
        }
        added.add(Member(
          name: name,
          gender: cellText(row, col(['gender', 'लिंग'])),
          father: cellText(row, col(['father', 'पिता'])),
          mother: cellText(row, col(['mother', 'माता'])),
          village: cellText(row, col(['village', 'birth place', 'गांव', 'गाँव'])),
          occupation: cellText(row, col(['occupation', 'profession', 'पेशा'])),
          spouse: cellText(row, col(['life partner', 'spouse', 'जीवनसाथी'])),
          spouseCity: cellText(row, col(['partner city', 'life partner city'])),
          spouseCaste: cellText(row, col(['life partner caste', 'spouse caste'])),
          spouseGotra: cellText(row, col(['life partner gotra', 'spouse gotra'])),
          generation: cellText(row, col(['generation', 'पीढ़ी'])),
          dob: cellText(row, col(['date of birth', 'dob'])),
          dod: cellText(row, col(['date of death', 'dod'])),
          marriageDate: cellText(row, col(['marriage date'])),
          visitedPlaces: cellText(row, col(['places visited', 'visited places'])),
          visitYears: cellText(row, col(['visit years'])),
          jobType: cellText(row, col(['job type'])),
          govtLevel: cellText(row, col(['government level', 'govt level'])),
          jobCompany: cellText(row, col(['company', 'department'])),
          jobTitle: cellText(row, col(['job title', 'designation'])),
          jobCountry: cellText(row, col(['job country'])),
          jobDetails: cellText(row, col(['job details'])),
          notes: cellText(row, col(['notes', 'remarks'])),
          travelPlace: cellText(row, col(['ancestral travel place', 'travel place'])),
          travelYear: cellText(row, col(['travel year'])),
          travelDate: cellText(row, col(['travel date'])),
          travelPurpose: cellText(row, col(['purpose of travel', 'travel purpose'])),
        ));
      }
    }

    if (!foundNameColumn) {
      if (mounted) setState(() => status = 'Excel में Name कॉलम नहीं मिला। कृपया ऐप का Excel Template इस्तेमाल करें।');
      return;
    }
    if (added.isEmpty) {
      if (mounted) setState(() => status = 'Name कॉलम मिला, लेकिन कोई सदस्य रिकॉर्ड नहीं मिला। डेटा दूसरी पंक्ति से भरें।');
      return;
    }

    if (!mounted) return;
    setState(() {
      members.addAll(added);
      _ensureMemberIdsAndLinks();
      status = '${added.length} सदस्य Import हुए। ${skipped > 0 ? '$skipped खाली पंक्तियाँ छोड़ी गईं।' : ''}';
    });
    await save();
    if (mounted) setState(() => status = '${added.length} सदस्य सफलतापूर्वक Import और Save हुए। ${skipped > 0 ? '$skipped खाली पंक्तियाँ छोड़ी गईं।' : ''}');
  } catch (e, stack) {
    debugPrint('Excel import error: $e\\n$stack');
    if (mounted) setState(() => status = 'Excel Import Error: $e');
  }
 }
 Future<void> template()async{final x=Excel.createExcel();final s=x['Family Members'];const h=['Name','Gender','Father','Mother','Village','Occupation','Life Partner','Life Partner City','Life Partner Caste','Life Partner Gotra','Generation','Date of Birth','Date of Death','Marriage Date','Places Visited','Visit Years','Job Type (Government/Private)','Government Level (State/UP/Central)','Company / Department','Job Title / Designation','Job Country','Job Details','Notes','Ancestral Travel Place','Travel Year (Optional)','Travel Date (Optional)','Purpose of Travel'];s.appendRow(h.map((v)=>TextCellValue(v)).toList());s.appendRow(['नाम','पुरुष/महिला','पिता','माता','गाँव/शहर','पेशा','जीवनसाथी','शहर','जाति','गोत्र','1','DD-MM-YYYY','DD-MM-YYYY','DD-MM-YYYY','शहर/देश','वर्ष','Government/Private','State/UP/Central','कंपनी/विभाग','पद/Designation','देश','अन्य विवरण','अन्य','यात्रा स्थान','वैकल्पिक वर्ष','वैकल्पिक तारीख','यात्रा उद्देश्य'].map((v)=>TextCellValue(v)).toList());final b=x.encode();if(b!=null)await FilePicker.platform.saveFile(dialogTitle:'Excel Template सेव करें',fileName:'Sangroya_Family_Tree_Template.xlsx',bytes:Uint8List.fromList(b));}
 void tree()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>FamilyTreePage(members:members)));
 void showDocuments({bool closeDrawer = false}) {
    if (closeDrawer) Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text('Family Documents')),
          body: documents.isEmpty
              ? const Center(child: Text('अभी कोई PDF/JPEG अपलोड नहीं है'))
              : ListView(
                  children: documents.map((d) {
                    return ListTile(
                      leading: Icon(d.type == 'pdf' ? Icons.picture_as_pdf : Icons.image),
                      title: Text(d.name),
                      subtitle: Text('${(d.size / 1024).toStringAsFixed(1)} KB'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'Download',
                            icon: const Icon(Icons.download),
                            onPressed: () => downloadDocument(d),
                          ),
                          IconButton(
                            tooltip: 'केवल Super Admin हटाएँ',
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Document हटाने के लिए Super Admin verification आवश्यक है।'),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
        ),
      ),
    );
  }
  void showAccess(bool registration){Navigator.pop(context);Navigator.push(context,MaterialPageRoute(builder:(_)=>AccessPage(registration:registration)));}
 @override Widget build(BuildContext context)=>Scaffold(
  drawer: Drawer(
    child: SafeArea(
      child: ListView(
        padding: EdgeInsets.zero,
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF0B4A22), Color(0xFF27A36B)])),
            child: const Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [
              Icon(Icons.account_tree, color: Colors.white, size: 38),
              Text('SANGROYA FAMILY TREE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              Text('परिवार की डिजिटल वंशावली', style: TextStyle(color: Colors.white)),
            ]),
          ),
          ListTile(leading: const Icon(Icons.upload_file), title: const Text('Upload PDF / JPEG'), onTap: () { Navigator.pop(context); uploadDocument(); }),
          ListTile(leading: const Icon(Icons.download), title: const Text('Download / Backup'), onTap: () { Navigator.pop(context); exportBackup(); }),
          ListTile(leading: const Icon(Icons.person_add), title: const Text('Add Family Member'), onTap: () { Navigator.pop(context); edit(); }),
          ListTile(leading: const Icon(Icons.table_view), title: const Text('Bulk Add — Excel Import'), subtitle: const Text('कई सदस्यों को एक साथ जोड़ें'), onTap: () { Navigator.pop(context); importExcel(); }),
          ListTile(leading: const Icon(Icons.file_download), title: const Text('Excel Template डाउनलोड करें'), onTap: () { Navigator.pop(context); template(); }),
          ListTile(leading: const Icon(Icons.account_tree), title: const Text('Family Tree'), onTap: () { Navigator.pop(context); tree(); }),
          ListTile(leading: const Icon(Icons.folder), title: const Text('Documents / Gallery'), onTap: () => showDocuments(closeDrawer: true)),
          ListTile(leading: const Icon(Icons.travel_explore), title: const Text('पूर्वजों की यात्रा'), onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => TravelPage(members: members))); }),
          ListTile(leading: const Icon(Icons.history_edu), title: const Text('बैरागी संप्रदाय का इतिहास'), onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const CommunityHistoryPage())); }),
          const Divider(),
          ListTile(leading: const Icon(Icons.login), title: const Text('Family Login'), onTap: () => showAccess(false)),
          ListTile(leading: const Icon(Icons.app_registration), title: const Text('Mobile Registration'), onTap: () => showAccess(true)),
          const ListTile(leading: Icon(Icons.admin_panel_settings), title: Text('Admin Panel — अगला चरण'), subtitle: Text('केवल Super Admin के लिए')),
        ],
      ),
    ),
  ),
 appBar:AppBar(title:const Text('SANGROYA FAMILY TREE'),actions:[IconButton(onPressed:()=>showDocuments(),icon:const Icon(Icons.folder_open))]),
 body:Container(decoration:const BoxDecoration(gradient:LinearGradient(begin:Alignment.topLeft,end:Alignment.bottomRight,colors:[Color(0xFFEAF7EF),Color(0xFFFFF1DC),Color(0xFFF4FAF2)])),child:ListView(padding:const EdgeInsets.all(14),children:[
 Container(padding:const EdgeInsets.all(18),decoration:BoxDecoration(gradient:const LinearGradient(colors:[Color(0xFF0B4A22),Color(0xFF2C8B61)]),borderRadius:BorderRadius.circular(20)),child:const Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('हमारी विरासत, हमारी पहचान',style:TextStyle(color:Colors.white,fontSize:21,fontWeight:FontWeight.bold)),Text('हमारी धरोहर',style:TextStyle(color:Colors.white70))])),
 const SizedBox(height:12),GridView.count(crossAxisCount:2,shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),crossAxisSpacing:10,mainAxisSpacing:10,childAspectRatio:1.55,children:[_dash(Icons.account_tree,'Family Tree','वंशावली देखें',const Color(0xFF236B52),tree),_dash(Icons.person_add_alt_1,'Add Member','नया सदस्य जोड़ें',const Color(0xFFFF8A00),()=>edit()),_dash(Icons.upload_file,'Upload Files','PDF / JPEG / PNG',const Color(0xFF2C8B57),uploadDocument),_dash(Icons.download,'Download','Backup / Export',const Color(0xFFFF9A1F),exportBackup),_dash(Icons.table_view,'Bulk Add','Excel से सदस्य जोड़ें',const Color(0xFF176B3A),importExcel),_dash(Icons.file_download,'Excel Template','पहले फॉर्मेट डाउनलोड करें',const Color(0xFFB56A12),template)]),
 Card(child:ListTile(title:const Text('कुल परिवार सदस्य'),trailing:Text('${members.length}',style:const TextStyle(fontSize:24,fontWeight:FontWeight.bold)))),Card(child:ListTile(title:const Text('अपलोड दस्तावेज़'),trailing:Text('${documents.length}',style:const TextStyle(fontSize:24,fontWeight:FontWeight.bold)),onTap:()=>showDocuments())),Text(status),const Text('सदस्य सूची',style:TextStyle(fontWeight:FontWeight.bold,fontSize:18)),...members.asMap().entries.map((e)=>Card(child:ListTile(title:Text(e.value.name),subtitle:Text([e.value.gender,e.value.village,e.value.father].where((x)=>x.isNotEmpty).join(' • ')),onTap:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>ProfilePage(member:e.value,all:members))),trailing:IconButton(icon:const Icon(Icons.edit),onPressed:()=>edit(e.key))))),const SizedBox(height:70)])),
  floatingActionButton: FloatingActionButton.extended(onPressed: () => edit(), icon: const Icon(Icons.person_add), label: const Text('Member जोड़ें')));
 Widget _dash(IconData icon,String title,String sub,Color color,VoidCallback action)=>InkWell(onTap:action,borderRadius:BorderRadius.circular(16),child:Container(padding:const EdgeInsets.all(13),decoration:BoxDecoration(color:color,borderRadius:BorderRadius.circular(16)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,mainAxisAlignment:MainAxisAlignment.center,children:[Icon(icon,color:Colors.white,size:28),const SizedBox(height:6),Text(title,style:const TextStyle(color:Colors.white,fontWeight:FontWeight.bold,fontSize:16)),Text(sub,style:const TextStyle(color:Colors.white70,fontSize:12))])));

}
class MemberForm extends StatefulWidget{final Member member;const MemberForm({super.key,required this.member});@override State<MemberForm> createState()=>_MemberFormState();}
class _MemberFormState extends State<MemberForm>{
 late final Map<String,TextEditingController> c;late String gender,job,govtLevel,photoPath;
 @override void initState(){super.initState();final m=widget.member;gender=m.gender.isEmpty?'पुरुष':m.gender;job=m.jobType;govtLevel=m.govtLevel;photoPath=m.photoPath;c={'name':m.name,'father':m.father,'mother':m.mother,'village':m.village,'occupation':m.occupation,'spouse':m.spouse,'spouseCity':m.spouseCity,'spouseCaste':m.spouseCaste,'spouseGotra':m.spouseGotra,'generation':m.generation,'dob':m.dob,'dod':m.dod,'marriageDate':m.marriageDate,'visitedPlaces':m.visitedPlaces,'visitYears':m.visitYears,'jobCompany':m.jobCompany,'jobTitle':m.jobTitle,'jobCountry':m.jobCountry,'jobDetails':m.jobDetails,'notes':m.notes,'travelPlace':m.travelPlace,'travelYear':m.travelYear,'travelDate':m.travelDate,'travelPurpose':m.travelPurpose}.map((k,v)=>MapEntry(k,TextEditingController(text:v)));}
 @override void dispose(){for(final x in c.values){x.dispose();}super.dispose();}
 Future<void> pickPhoto(ImageSource source) async { final x=await ImagePicker().pickImage(source:source,imageQuality:85,maxWidth:1200); if(x==null)return; final dir=await getApplicationDocumentsDirectory(); final folder=Directory('${dir.path}/member_photos'); await folder.create(recursive:true); final dest=File('${folder.path}/${DateTime.now().millisecondsSinceEpoch}_${x.name.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'),'_')}'); await File(x.path).copy(dest.path); if(mounted)setState(()=>photoPath=dest.path); }
  Future<void> choosePhoto() async { await showModalBottomSheet(context:context,builder:(ctx)=>SafeArea(child:Wrap(children:[ListTile(leading:const Icon(Icons.photo_library),title:const Text('Gallery से फोटो चुनें'),onTap:(){Navigator.pop(ctx);pickPhoto(ImageSource.gallery);}),ListTile(leading:const Icon(Icons.camera_alt),title:const Text('Camera से फोटो लें'),onTap:(){Navigator.pop(ctx);pickPhoto(ImageSource.camera);})]))); }
  Widget f(String k,String label,{int lines=1})=>Padding(padding:const EdgeInsets.only(bottom:8),child:TextField(controller:c[k],maxLines:lines,decoration:InputDecoration(labelText:label,border:const OutlineInputBorder())));
 @override Widget build(BuildContext context)=>AlertDialog(title:Text(widget.member.name.isEmpty?'नया सदस्य':'Member Edit करें'),content:SizedBox(width:500,child:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[GestureDetector(onTap:choosePhoto,child:CircleAvatar(radius:42,backgroundImage:photoPath.isNotEmpty&&File(photoPath).existsSync()?FileImage(File(photoPath)):null,child:photoPath.isEmpty||!File(photoPath).existsSync()?const Icon(Icons.add_a_photo,size:30):null)),const SizedBox(height:6),TextButton.icon(onPressed:choosePhoto,icon:const Icon(Icons.camera_alt),label:const Text('फोटो जोड़ें / Camera से लें')),f('name','पूरा नाम'),DropdownButtonFormField(initialValue:gender,decoration:const InputDecoration(labelText:'लिंग'),items:const [DropdownMenuItem(value:'पुरुष',child:Text('पुरुष / Male')),DropdownMenuItem(value:'महिला',child:Text('महिला / Female')),DropdownMenuItem(value:'अन्य',child:Text('अन्य'))],onChanged:(v){if(v!=null)setState(()=>gender=v);}),const SizedBox(height:8),f('father','पिता का नाम'),f('mother','माता का नाम'),f('village','गाँव / जन्म स्थान'),f('dob','Date of Birth DD-MM-YYYY'),f('spouse','जीवनसाथी का नाम'),f('spouseCity','जीवनसाथी का शहर'),f('spouseCaste','जीवनसाथी की जाति / Caste'),f('spouseGotra','जीवनसाथी का गोत्र / Gotra'),f('marriageDate','Marriage Date DD-MM-YYYY'),f('generation','पीढ़ी संख्या'),f('occupation','पेशा / पद'),DropdownButtonFormField<String>(initialValue:job.isEmpty?null:job,decoration:const InputDecoration(labelText:'नौकरी का प्रकार'),items:const [DropdownMenuItem(value:'Government',child:Text('Government / सरकारी')),DropdownMenuItem(value:'Private',child:Text('Private / निजी')),DropdownMenuItem(value:'Not Applicable',child:Text('लागू नहीं'))],onChanged:(v){if(v!=null)setState(()=>job=v);}),if(job=='Government')DropdownButtonFormField<String>(initialValue:govtLevel.isEmpty?null:govtLevel,decoration:const InputDecoration(labelText:'सरकारी नौकरी — विभाग का स्तर'),items:const [DropdownMenuItem(value:'State',child:Text('State Government')),DropdownMenuItem(value:'Uttar Pradesh',child:Text('Uttar Pradesh Government')),DropdownMenuItem(value:'Central',child:Text('Central Government'))],onChanged:(v){if(v!=null)setState(()=>govtLevel=v);}),f('jobCompany','Company / सरकारी विभाग का नाम'),f('jobTitle','Job Title / पदनाम'),if(job=='Private')f('jobCountry','किस देश में नौकरी?'),f('jobDetails','Job Details — शहर, अवधि आदि',lines:2),f('visitedPlaces','कहाँ-कहाँ Visit किया',lines:2),f('visitYears','Visit के वर्ष (जैसे 1998, 2005, 2022)',lines:2),f('travelPlace','पूर्वजों की यात्रा — स्थान'),f('travelYear','यात्रा वर्ष (वैकल्पिक)'),f('travelDate','यात्रा तारीख (वैकल्पिक)'),f('travelPurpose','यात्रा का उद्देश्य',lines:2),f('notes','अन्य जानकारी',lines:2),f('dod','Date of Death DD-MM-YYYY')]))),actions:[TextButton(onPressed:()=>Navigator.pop(context),child:const Text('Cancel')),FilledButton(onPressed:(){if(c['name']!.text.trim().isEmpty)return;String v(String k)=>c[k]!.text.trim();Navigator.pop(context,Member(memberId:widget.member.memberId,fatherId:widget.member.fatherId,motherId:widget.member.motherId,spouseId:widget.member.spouseId,name:v('name'),gender:gender,father:v('father'),mother:v('mother'),village:v('village'),occupation:v('occupation'),spouse:v('spouse'),spouseCity:v('spouseCity'),spouseCaste:v('spouseCaste'),spouseGotra:v('spouseGotra'),generation:v('generation'),dob:v('dob'),dod:v('dod'),marriageDate:v('marriageDate'),visitedPlaces:v('visitedPlaces'),visitYears:v('visitYears'),jobType:job,govtLevel:govtLevel,jobCompany:v('jobCompany'),jobTitle:v('jobTitle'),jobCountry:v('jobCountry'),jobDetails:v('jobDetails'),photoPath:photoPath,notes:v('notes'),travelPlace:v('travelPlace'),travelYear:v('travelYear'),travelDate:v('travelDate'),travelPurpose:v('travelPurpose')));},child:const Text('Save'))]);
}
class ProfilePage extends StatelessWidget {
 final Member member;
 final List<Member> all;
 const ProfilePage({super.key, required this.member, required this.all});

 String norm(String value) => value.trim().toLowerCase().replaceAll(RegExp(r'\\s+'), ' ');
 int? gen(Member m) => int.tryParse(m.generation.trim());
 String identity(Member m) => [
   norm(m.name), norm(m.father), norm(m.mother), norm(m.generation),
   norm(m.village), norm(m.dob), norm(m.spouse),
 ].join('|');

 List<Member> parentMatches(Member child) {
   if(child.fatherId.isNotEmpty){
     final byId=all.where((m)=>m.memberId==child.fatherId).toList();
     if(byId.length==1)return byId;
   }
   final matches=all.where((m)=>m.name.trim().toLowerCase()==child.father.trim().toLowerCase()).toList();
   if(matches.length<=1)return matches;
   final g=int.tryParse(child.generation);
   if(g!=null){final adjacent=matches.where((m)=>int.tryParse(m.generation)==g-1).toList();if(adjacent.length==1)return adjacent;}
   return const [];
 }
 List<Member> childrenOf(Member parent) {
   final byId=all.where((m)=>m.fatherId==parent.memberId && parent.memberId.isNotEmpty).toList();
   if(byId.isNotEmpty)return byId;
   final matches=all.where((m)=>m.father.trim().toLowerCase()==parent.name.trim().toLowerCase()).toList();
   final g=int.tryParse(parent.generation);
   if(g!=null){final adjacent=matches.where((m)=>int.tryParse(m.generation)==g+1).toList();if(adjacent.isNotEmpty)return adjacent;}
   return matches;
 }
 Widget row(String k, String v) => v.trim().isEmpty ? const SizedBox.shrink() : ListTile(title: Text(k), subtitle: Text(v));

 List<Member> ancestors() {
   final result = <Member>[];
   var current = member;
   final seen = <String>{member.memberId.isNotEmpty ? member.memberId : identity(member)};
   for (var i = 0; i < 18 && current.father.trim().isNotEmpty; i++) {
     final matches = parentMatches(current);
     if (matches.length != 1) break;
     final next = matches.first;
     if (!seen.add(identity(next))) break;
     result.add(next);
     current = next;
   }
   return result;
 }

 List<Member> descendants() {
   final result = <Member>[];
   final queue = <Member>[member];
   final seen = <String>{member.memberId.isNotEmpty ? member.memberId : identity(member)};
   while (queue.isNotEmpty && result.length < 2000) {
     final parent = queue.removeAt(0);
     for (final child in childrenOf(parent)) {
       final key = child.memberId.isNotEmpty ? child.memberId : identity(child);
       if (key != identity(parent) && seen.add(key)) {
         result.add(child);
         queue.add(child);
       }
     }
   }
   return result;
 }

 @override Widget build(BuildContext context) {
   final up = ancestors();
   final down = descendants();
   return Scaffold(
     appBar: AppBar(title: Text(member.name)),
     body: SafeArea(
       child: ListView(
         primary: true,
         physics: const AlwaysScrollableScrollPhysics(),
         padding: const EdgeInsets.fromLTRB(12, 12, 12, 36),
         children: [
           if (member.photoPath.isNotEmpty && File(member.photoPath).existsSync())
             Center(child: CircleAvatar(radius: 58, backgroundImage: FileImage(File(member.photoPath)))),
           Card(child: Column(children: [
             row('Member ID', member.memberId),
             row('पीढ़ी संख्या / Generation', member.generation),
             row('लिंग', member.gender), row('जन्म तिथि', member.dob),
             row('मृत्यु तिथि', member.dod), row('जन्म स्थान', member.village),
             row('पिता', member.father), row('माता', member.mother),
           ])),
           Card(child: Column(children: [
             const ListTile(title: Text('पूर्वज / पहले की पीढ़ियाँ')),
             if (up.isEmpty) const ListTile(subtitle: Text('पूर्वज का मिलान नहीं मिला। पिता का नाम, पीढ़ी संख्या और रिकॉर्ड की वर्तनी जाँचें। एक जैसे नाम होने पर गलत रिश्ता जोड़ने के बजाय मिलान रोका जाता है।')),
             ...up.map((m) => ListTile(
               leading: const Icon(Icons.arrow_upward),
               title: Text(m.name),
               subtitle: Text('पीढ़ी: ${m.generation.isEmpty ? 'दर्ज नहीं' : m.generation} • पिता: ${m.father.isEmpty ? 'दर्ज नहीं' : m.father}'),
               onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilePage(member: m, all: all))),
             )),
           ])),
           Card(child: Column(children: [
             row('जीवनसाथी', member.spouse), row('जीवनसाथी का शहर', member.spouseCity),
             row('जीवनसाथी की जाति', member.spouseCaste), row('जीवनसाथी का गोत्र', member.spouseGotra),
             row('विवाह तारीख', member.marriageDate),
           ])),
           Card(child: Column(children: [
             row('पेशा', member.occupation), row('Job Type', member.jobType),
             row('देश', member.jobCountry), row('Government Level', member.govtLevel),
             row('Company / Department', member.jobCompany), row('Job Title', member.jobTitle),
             row('Job Details', member.jobDetails), row('Visited Places', member.visitedPlaces),
             row('Visit Years', member.visitYears), row('अन्य जानकारी', member.notes),
           ])),
           Card(child: Column(children: [
             ListTile(title: Text('बाद की पीढ़ियाँ / वंशज (${down.length})')),
             if (down.isEmpty) const ListTile(subtitle: Text('इस सदस्य के नाम से पिता का रिकॉर्ड मिलाकर कोई संतान नहीं मिली। पिता का नाम और अगली पीढ़ी संख्या जाँचें।')),
             ...down.map((m) => ListTile(
               leading: const Icon(Icons.arrow_downward),
               title: Text(m.name),
               subtitle: Text('पीढ़ी: ${m.generation.isEmpty ? 'दर्ज नहीं' : m.generation} • पिता: ${m.father}'),
               onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilePage(member: m, all: all))),
             )),
           ])),
         ],
       ),
     ),
   );
 }
}

class FamilyTreePage extends StatelessWidget {
 final List<Member> members;
 const FamilyTreePage({super.key, required this.members});
 @override Widget build(BuildContext context) {
   final counts = <String, int>{};
   for (final m in members) {
     final k = m.name.trim().toLowerCase();
     counts[k] = (counts[k] ?? 0) + 1;
   }
   final map = <String, List<Member>>{};
   for (final m in members) {
     final k = m.fatherId.isNotEmpty ? m.fatherId : m.father.trim().toLowerCase();
     if (k.isNotEmpty && counts[k] == 1) map.putIfAbsent(k, () => []).add(m);
   }
   final roots = members.where((m) {
     final k = m.fatherId.isNotEmpty ? m.fatherId : m.father.trim().toLowerCase();
     return k.isEmpty || counts[k] != 1;
   }).toList()
     ..sort((a, b) {
       final ai = int.tryParse(a.generation) ?? 999;
       final bi = int.tryParse(b.generation) ?? 999;
       return ai.compareTo(bi);
     });
   return Scaffold(
     appBar: AppBar(title: const Text('Family Tree')),
     body: ListView(padding: const EdgeInsets.all(12), children: [
       const Text('सदस्य के नाम पर क्लिक करके उससे जुड़ी उपलब्ध पूर्वज और अगली पीढ़ियाँ देखें। पिता का नाम सही और अद्वितीय होना आवश्यक है।'),
       ...roots.map((m) => TreeNode(m: m, map: map, all: members, path: <String>{}, depth: 1)),
     ]),
   );
 }
}

class TreeNode extends StatelessWidget {
 final Member m;
 final Map<String, List<Member>> map;
 final List<Member> all;
 final Set<String> path;
 final int depth;
 const TreeNode({super.key, required this.m, required this.map, required this.all, required this.path, required this.depth});
 @override Widget build(BuildContext context) {
   final k = m.memberId.isNotEmpty ? m.memberId : m.name.trim().toLowerCase();
   final p = {...path, k};
   final kids = (map[k] ?? []).where((x) => !p.contains(x.memberId.isNotEmpty ? x.memberId : x.name.trim().toLowerCase())).toList()
     ..sort((a, b) => (int.tryParse(a.generation) ?? 999).compareTo(int.tryParse(b.generation) ?? 999));
   final subtitle = [
     if (m.memberId.isNotEmpty) 'ID: ${m.memberId}',
     if (m.generation.isNotEmpty) 'पीढ़ी ${m.generation}',
     m.gender, m.village, m.spouse,
   ].where((x) => x.isNotEmpty).join(' • ');
   final tile = ListTile(
     title: Text(m.name),
     subtitle: Text(subtitle.isEmpty ? 'पीढ़ी संख्या दर्ज नहीं' : subtitle),
     onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilePage(member: m, all: all))),
   );
   return Card(
     margin: EdgeInsets.only(left: (depth - 1) * 10),
     child: kids.isEmpty ? tile : ExpansionTile(
       title: Text(m.name),
       subtitle: Text(subtitle.isEmpty ? 'पीढ़ी संख्या दर्ज नहीं' : subtitle),
       children: kids.map((x) => TreeNode(m: x, map: map, all: all, path: p, depth: depth + 1)).toList(),
     ),
   );
 }
}

class TravelPage extends StatefulWidget {
 final List<Member> members;
 const TravelPage({super.key,required this.members});
 @override State<TravelPage> createState()=>_TravelPageState();
}
class _TravelPageState extends State<TravelPage> {
 final List<Map<String,String>> records=[];
 final place=TextEditingController(), person=TextEditingController(), date=TextEditingController(), year=TextEditingController(), purpose=TextEditingController(), details=TextEditingController(), from=TextEditingController(), to=TextEditingController();
 @override void initState(){super.initState();_load();}
 Future<void> _load()async{final p=await SharedPreferences.getInstance();final raw=p.getString('ancestor_travel_records');if(raw!=null){try{final a=(jsonDecode(raw) as List).map((e)=>Map<String,String>.from(e)).toList();if(mounted)setState(()=>records.addAll(a));}catch(_){}}}
 Future<void> _save()async{final p=await SharedPreferences.getInstance();await p.setString('ancestor_travel_records',jsonEncode(records));}
 @override void dispose(){for(final x in [place,person,date,year,purpose,details,from,to]){x.dispose();}super.dispose();}
 Future<void> _add()async{await showDialog(context:context,builder:(ctx)=>AlertDialog(title:const Text('पूर्वजों की यात्रा जोड़ें'),content:SizedBox(width:480,child:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[_field(place,'यात्रा स्थान'),_field(person,'किस पूर्वज / सदस्य की यात्रा'),_field(from,'कहाँ से'),_field(to,'कहाँ तक'),_field(date,'यात्रा की तारीख'),_field(year,'वर्ष'),_field(purpose,'यात्रा का उद्देश्य'),_field(details,'यात्रा का पूरा विवरण',lines:3)]))),actions:[TextButton(onPressed:()=>Navigator.pop(ctx),child:const Text('रद्द करें')),FilledButton(onPressed:(){if(place.text.trim().isEmpty)return;setState(()=>records.add({'place':place.text.trim(),'person':person.text.trim(),'from':from.text.trim(),'to':to.text.trim(),'date':date.text.trim(),'year':year.text.trim(),'purpose':purpose.text.trim(),'details':details.text.trim()}));_save();for(final x in [place,person,date,year,purpose,details,from,to]){x.clear();}Navigator.pop(ctx);},child:const Text('यात्रा सुरक्षित करें'))]));}
 Widget _field(TextEditingController c,String label,{int lines=1})=>Padding(padding:const EdgeInsets.only(bottom:9),child:TextField(controller:c,maxLines:lines,decoration:InputDecoration(labelText:label,border:const OutlineInputBorder())));
 @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('पूर्वजों की यात्रा')),floatingActionButton:FloatingActionButton.extended(onPressed:_add,icon:const Icon(Icons.add),label:const Text('यात्रा जोड़ें')),body:records.isEmpty?Center(child:Column(mainAxisSize:MainAxisSize.min,children:[const Icon(Icons.travel_explore,size:48),const SizedBox(height:10),const Text('अभी यात्रा का विवरण दर्ज नहीं है।'),const SizedBox(height:12),FilledButton.icon(onPressed:_add,icon:const Icon(Icons.add),label:const Text('पहली यात्रा जोड़ें'))])):ListView(padding:const EdgeInsets.all(12),children:[...records.asMap().entries.map((e)=>Card(child:ListTile(isThreeLine:true,leading:const Icon(Icons.travel_explore,color:Color(0xFFFF8A00)),title:Text(e.value['place']??''),subtitle:Text([e.value['person'],e.value['from'].toString().isNotEmpty?'से: ${e.value['from']}':'',e.value['to'].toString().isNotEmpty?'तक: ${e.value['to']}':'',e.value['date'],e.value['year'],e.value['purpose'],e.value['details']].where((v)=>v!=null&&v.toString().trim().isNotEmpty).join(' • ')),trailing:IconButton(icon:const Icon(Icons.delete_outline),onPressed:()async{setState(()=>records.removeAt(e.key));await _save();})))) ,const SizedBox(height:80)]));
}
class CommunityHistoryPage extends StatelessWidget {
 const CommunityHistoryPage({super.key});
 @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('बैरागी संप्रदाय का संक्षिप्त इतिहास')),body:ListView(padding:const EdgeInsets.all(16),children:[
 const Text('बैरागी संप्रदाय — संक्षिप्त परिचय',style:TextStyle(fontSize:22,fontWeight:FontWeight.bold)),
 const SizedBox(height:12),
 const Text('बैरागी परंपरा वैष्णव भक्ति से जुड़ी तपस्वी और साधु परंपराओं का व्यापक समूह है। “बैरागी” शब्द वैराग्य—सांसारिक आसक्ति से दूरी—से संबंधित है। विभिन्न क्षेत्रों में बैरागी समुदायों की धार्मिक, सामाजिक और ऐतिहासिक परंपराएँ अलग-अलग रूपों में विकसित हुई हैं।'),
 const SizedBox(height:12),
 const Text('इस अनुभाग में परिवार द्वारा सत्यापित जानकारी, मौखिक इतिहास, पुराने दस्तावेज़, स्थान, तिथियाँ और संदर्भ क्रमशः जोड़े जा सकते हैं। अपुष्ट जानकारी को “सत्यापन बाकी” के रूप में रखें।'),
 const SizedBox(height:12),
 const Text('नोट: यह सामान्य परिचय है, आपके परिवार/शाखा का प्रमाणित इतिहास नहीं। विशिष्ट वंश-परंपरा जोड़ने से पहले विश्वसनीय स्रोतों से पुष्टि करें।',style:TextStyle(color:Color(0xFF9A4D00))),
 ]));
}

class AccessPage extends StatefulWidget {
 final bool registration;
 const AccessPage({super.key, required this.registration});
 @override State<AccessPage> createState()=>_AccessPageState();
}
class _AccessPageState extends State<AccessPage>{
 final name=TextEditingController(),mobile=TextEditingController(),email=TextEditingController(),relation=TextEditingController(),password=TextEditingController();
 String role='Family Member';
 @override void dispose(){name.dispose();mobile.dispose();email.dispose();relation.dispose();password.dispose();super.dispose();}
 Future<void> _send(bool whatsapp)async{
  final target=role=='Super Admin'?'Super Admin':role=='Admin'?'Admin':'Family Member';
  final message='SANGROYA FAMILY TREE — सदस्यता / एक्सेस अनुरोध\nनाम: ${name.text.trim()}\nमोबाइल: ${mobile.text.trim()}\nईमेल: ${email.text.trim()}\nअनुरोध: $target\nपरिवार से संबंध: ${relation.text.trim()}\nकृपया मुझे परिवार ऐप का सुरक्षित आमंत्रण लिंक भेजें।';
  final uri=whatsapp?Uri.parse('https://wa.me/?text=${Uri.encodeComponent(message)}'):Uri(scheme:'mailto',path:email.text.trim(),queryParameters:{'subject':'SANGROYA FAMILY TREE Access Request','body':message});
  if(!await launchUrl(uri,mode:LaunchMode.externalApplication)&&mounted){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('यह ऐप/ईमेल सेवा उपलब्ध नहीं है।')));}
 }
 @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:Text(widget.registration?'Family Registration':'Family Login')),body:Center(child:SingleChildScrollView(padding:const EdgeInsets.all(18),child:ConstrainedBox(constraints:const BoxConstraints(maxWidth:520),child:Card(child:Padding(padding:const EdgeInsets.all(20),child:Column(mainAxisSize:MainAxisSize.min,children:[
 const Text('SANGROYA FAMILY TREE में आपका स्वागत है',textAlign:TextAlign.center,style:TextStyle(fontSize:22,fontWeight:FontWeight.w900,color:Color(0xFF176B3A))),
 const SizedBox(height:18),Icon(widget.registration?Icons.app_registration:Icons.lock_outline,size:42,color:const Color(0xFF236B52)),
 Text(widget.registration?'परिवार सदस्यता अनुरोध':'परिवार लॉगिन',style:const TextStyle(fontSize:20,fontWeight:FontWeight.bold)),
 if(widget.registration)...[
 const SizedBox(height:12),TextField(controller:name,decoration:const InputDecoration(labelText:'पूरा नाम',border:OutlineInputBorder())),
 const SizedBox(height:9),TextField(controller:mobile,keyboardType:TextInputType.phone,decoration:const InputDecoration(labelText:'मोबाइल नंबर',border:OutlineInputBorder())),
 const SizedBox(height:9),TextField(controller:email,keyboardType:TextInputType.emailAddress,decoration:const InputDecoration(labelText:'ईमेल',border:OutlineInputBorder())),
 const SizedBox(height:9),DropdownButtonFormField<String>(initialValue:role,decoration:const InputDecoration(labelText:'किससे अनुरोध भेजना है',border:OutlineInputBorder()),items:const [DropdownMenuItem(value:'Super Admin',child:Text('Super Admin')),DropdownMenuItem(value:'Admin',child:Text('Admin')),DropdownMenuItem(value:'Family Member',child:Text('Family Member'))],onChanged:(v){if(v!=null)setState(()=>role=v);}),
 const SizedBox(height:9),TextField(controller:relation,decoration:const InputDecoration(labelText:'परिवार से संबंध / गाँव',border:OutlineInputBorder())),
 const SizedBox(height:14),Row(children:[Expanded(child:FilledButton.icon(onPressed:()=>_send(true),icon:const Icon(Icons.chat),label:const Text('WhatsApp लिंक'))),const SizedBox(width:8),Expanded(child:OutlinedButton.icon(onPressed:()=>_send(false),icon:const Icon(Icons.email),label:const Text('Email अनुरोध')))]),
 ]else...[
 const SizedBox(height:12),TextField(controller:mobile,decoration:const InputDecoration(labelText:'मोबाइल / ईमेल',border:OutlineInputBorder())),
 const SizedBox(height:9),TextField(controller:password,obscureText:true,decoration:const InputDecoration(labelText:'पासवर्ड',border:OutlineInputBorder())),
 const SizedBox(height:14),FilledButton(onPressed:()=>ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('वास्तविक लॉगिन के लिए Firebase Authentication और Super Admin account setup अभी आवश्यक है।'))),child:const Text('Login')),
 ],
 const SizedBox(height:12),const Text('नोट: WhatsApp/Email बटन आपके फोन में संदेश तैयार करते हैं। वास्तविक अकाउंट, OTP, पासवर्ड सत्यापन, Admin approval और सभी फोन में डेटा sync के लिए Firebase backend जोड़ना बाकी है।',style:TextStyle(color:Colors.deepOrange),textAlign:TextAlign.center)
 ])))))));
}
