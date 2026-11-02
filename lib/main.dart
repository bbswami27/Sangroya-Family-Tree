import 'dart:convert';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const SangroyaApp());
class SangroyaApp extends StatelessWidget {
 const SangroyaApp({super.key});
 @override Widget build(BuildContext context)=>MaterialApp(title:'SANGROYA FAMILY TREE',debugShowCheckedModeBanner:false,theme:ThemeData(colorScheme:ColorScheme.fromSeed(seedColor:const Color(0xFF315C4B)),useMaterial3:true),home:const FamilyHome());
}
class Member {
 final String name,father,village,occupation,spouse,generation,notes;
 const Member({this.name='',this.father='',this.village='',this.occupation='',this.spouse='',this.generation='',this.notes=''});
 Map<String,dynamic> toJson()=>{'name':name,'father':father,'village':village,'occupation':occupation,'spouse':spouse,'generation':generation,'notes':notes};
 factory Member.fromJson(Map<String,dynamic> j)=>Member(name:j['name']??'',father:j['father']??'',village:j['village']??'',occupation:j['occupation']??'',spouse:j['spouse']??'',generation:j['generation']??'',notes:j['notes']??'');
}
class FamilyHome extends StatefulWidget {const FamilyHome({super.key});@override State<FamilyHome> createState()=>_FamilyHomeState();}
class _FamilyHomeState extends State<FamilyHome>{
 final List<Member> members=[]; final c=List.generate(7,(_)=>TextEditingController());
 final labels=['नाम / Name','पिता का नाम / Father','गाँव / Village / Place','नौकरी या व्यवसाय / Occupation','जीवनसाथी / Life Partner','पीढ़ी संख्या / Generation','अन्य जानकारी / Notes'];
 String status='अपनी Family की जानकारी जोड़ना शुरू करें';
 @override void initState(){super.initState();_load();}
 Future<void> _load()async{final p=await SharedPreferences.getInstance();final s=p.getString('members');if(s!=null){final a=jsonDecode(s) as List;setState(()=>members.addAll(a.map((e)=>Member.fromJson(Map<String,dynamic>.from(e)))));}}
 Future<void> _save()async{final p=await SharedPreferences.getInstance();await p.setString('members',jsonEncode(members.map((e)=>e.toJson()).toList()));}
 void _add(){if(c[0].text.trim().isEmpty){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Member का नाम भरें')));return;}setState(()=>members.add(Member(name:c[0].text.trim(),father:c[1].text.trim(),village:c[2].text.trim(),occupation:c[3].text.trim(),spouse:c[4].text.trim(),generation:c[5].text.trim(),notes:c[6].text.trim())));_save();for(final x in c){x.clear();}setState(()=>status='Member सुरक्षित कर दिया गया');}
 Future<void> _import()async{final f=await FilePicker.platform.pickFiles(type:FileType.custom,allowedExtensions:['xlsx','xls'],withData:true);if(f==null||f.files.single.bytes==null)return;try{final book=Excel.decodeBytes(f.files.single.bytes!);final added=<Member>[];for(final sh in book.tables.values){if(sh.rows.isEmpty)continue;final h=sh.rows.first.map((x)=>(x?.value?.toString()??'').toLowerCase().trim()).toList();int ix(List<String> keys){for(var i=0;i<h.length;i++){if(keys.any((k)=>h[i].contains(k)))return i;}return -1;}final ids=[ix(['name','नाम','member']),ix(['father','पिता']),ix(['village','गांव','गाँव','place']),ix(['occupation','job','नौकरी','काम']),ix(['spouse','husband','wife','जीवनसाथी']),ix(['generation','पीढ़ी','pidhi']),ix(['notes','remark','विवरण'])];if(ids[0]<0)continue;String v(List<Data?> r,int i)=>i<0||i>=r.length?'':(r[i]?.value?.toString()??'');for(final r in sh.rows.skip(1)){final n=v(r,ids[0]).trim();if(n.isNotEmpty)added.add(Member(name:n,father:v(r,ids[1]),village:v(r,ids[2]),occupation:v(r,ids[3]),spouse:v(r,ids[4]),generation:v(r,ids[5]),notes:v(r,ids[6])));}}setState((){members.addAll(added);status='${added.length} records Excel से import हुए';});await _save();}catch(e){setState(()=>status='Excel पढ़ने में समस्या: $e');}}
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
                 const Text('हमारे परिवार का डिजिटल इतिहास',
                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                 const Text('18 पीढ़ियों का Family Tree • Member Profiles • Village Records'),
                 const SizedBox(height: 12),
                 Row(
                   children: [
                     Expanded(child: Text('कुल सदस्य: ${members.length}',
                       style: const TextStyle(fontWeight: FontWeight.bold))),
                     FilledButton.icon(
                       onPressed: _import,
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
         const Text('नया Family Member जोड़ें',
           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
         const SizedBox(height: 10),
         ...List.generate(7, (i) => Padding(
           padding: const EdgeInsets.only(bottom: 10),
           child: TextField(
             controller: c[i],
             decoration: InputDecoration(
               labelText: labels[i],
               border: const OutlineInputBorder(),
             ),
           ),
         )),
         FilledButton.icon(
           onPressed: _add,
           icon: const Icon(Icons.person_add),
           label: const Text('Member Save करें'),
         ),
         const Divider(height: 32),
         const Text('Family Members',
           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
         if (members.isEmpty)
           const Text('अभी कोई Member नहीं है। ऊपर से जानकारी जोड़ें या Excel Upload करें।'),
         ...members.asMap().entries.map((e) => Card(
           child: ListTile(
             leading: CircleAvatar(
               child: Text(e.value.generation.isEmpty ? '•' : e.value.generation),
             ),
             title: Text(e.value.name),
             subtitle: Text([
               if (e.value.father.isNotEmpty) 'पिता: ${e.value.father}',
               if (e.value.village.isNotEmpty) 'गाँव: ${e.value.village}',
               if (e.value.occupation.isNotEmpty) 'काम: ${e.value.occupation}',
               if (e.value.spouse.isNotEmpty) 'जीवनसाथी: ${e.value.spouse}',
             ].join(' | ')),
             trailing: IconButton(
               icon: const Icon(Icons.delete_outline),
               onPressed: () async {
                 setState(() => members.removeAt(e.key));
                 await _save();
               },
             ),
           ),
         )),
         const SizedBox(height: 18),
         const Text(
           'नोट: Hinglish अभी जैसे टाइप करेंगे वैसे ही सेव होगा। Hindi-English translation/transliteration अगली सुविधा में जोड़ी जाएगी। डेटा अभी केवल इसी फोन में सेव होता है।',
           style: TextStyle(fontSize: 12, color: Colors.grey),
         ),
       ],
     ),
   );
 }
port 'dart:convert';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const SangroyaApp());
class SangroyaApp extends StatelessWidget {
 const SangroyaApp({super.key});
 @override Widget build(BuildContext context)=>MaterialApp(title:'SANGROYA FAMILY TREE',debugShowCheckedModeBanner:false,theme:ThemeData(colorScheme:ColorScheme.fromSeed(seedColor:const Color(0xFF315C4B)),useMaterial3:true),home:const FamilyHome());
}
class Member {
 final String name,father,village,occupation,spouse,generation,notes;
 const Member({this.name='',this.father='',this.village='',this.occupation='',this.spouse='',this.generation='',this.notes=''});
 Map<String,dynamic> toJson()=>{'name':name,'father':father,'village':village,'occupation':occupation,'spouse':spouse,'generation':generation,'notes':notes};
 factory Member.fromJson(Map<String,dynamic> j)=>Member(name:j['name']??'',father:j['father']??'',village:j['village']??'',occupation:j['occupation']??'',spouse:j['spouse']??'',generation:j['generation']??'',notes:j['notes']??'');
}
class FamilyHome extends StatefulWidget {const FamilyHome({super.key});@override State<FamilyHome> createState()=>_FamilyHomeState();}
class _FamilyHomeState extends State<FamilyHome>{
 final List<Member> members=[]; final c=List.generate(7,(_)=>TextEditingController());
 final labels=['नाम / Name','पिता का नाम / Father','गाँव / Village / Place','नौकरी या व्यवसाय / Occupation','जीवनसाथी / Life Partner','पीढ़ी संख्या / Generation','अन्य जानकारी / Notes'];
 String status='अपनी Family की जानकारी जोड़ना शुरू करें';
 @override void initState(){super.initState();_load();}
 Future<void> _load()async{final p=await SharedPreferences.getInstance();final s=p.getString('members');if(s!=null){final a=jsonDecode(s) as List;setState(()=>members.addAll(a.map((e)=>Member.fromJson(Map<String,dynamic>.from(e)))));}}
 Future<void> _save()async{final p=await SharedPreferences.getInstance();await p.setString('members',jsonEncode(members.map((e)=>e.toJson()).toList()));}
 void _add(){if(c[0].text.trim().isEmpty){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Member का नाम भरें')));return;}setState(()=>members.add(Member(name:c[0].text.trim(),father:c[1].text.trim(),village:c[2].text.trim(),occupation:c[3].text.trim(),spouse:c[4].text.trim(),generation:c[5].text.trim(),notes:c[6].text.trim())));_save();for(final x in c){x.clear();}setState(()=>status='Member सुरक्षित कर दिया गया');}
 Future<void> _import()async{final f=await FilePicker.platform.pickFiles(type:FileType.custom,allowedExtensions:['xlsx','xls'],withData:true);if(f==null||f.files.single.bytes==null)return;try{final book=Excel.decodeBytes(f.files.single.bytes!);final added=<Member>[];for(final sh in book.tables.values){if(sh.rows.isEmpty)continue;final h=sh.rows.first.map((x)=>(x?.value?.toString()??'').toLowerCase().trim()).toList();int ix(List<String> keys){for(var i=0;i<h.length;i++){if(keys.any((k)=>h[i].contains(k)))return i;}return -1;}final ids=[ix(['name','नाम','member']),ix(['father','पिता']),ix(['village','गांव','गाँव','place']),ix(['occupation','job','नौकरी','काम']),ix(['spouse','husband','wife','जीवनसाथी']),ix(['generation','पीढ़ी','pidhi']),ix(['notes','remark','विवरण'])];if(ids[0]<0)continue;String v(List<Data?> r,int i)=>i<0||i>=r.length?'':(r[i]?.value?.toString()??'');for(final r in sh.rows.skip(1)){final n=v(r,ids[0]).trim();if(n.isNotEmpty)added.add(Member(name:n,father:v(r,ids[1]),village:v(r,ids[2]),occupation:v(r,ids[3]),spouse:v(r,ids[4]),generation:v(r,ids[5]),notes:v(r,ids[6])));}}setState((){members.addAll(added);status='${added.length} records Excel से import हुए';});await _save();}catch(e){setState(()=>status='Excel पढ़ने में समस्या: $e');}}
 @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('SANGROYA FAMILY TREE'),backgroundColor:Theme.of(context).colorScheme.primaryContainer),body:ListView(padding:const EdgeInsets.all(16),children:[
 Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('हमारे परिवार का डिजिटल इतिहास',style:TextStyle(fontSize:20,fontWeight:FontWeight.bold)),const Text('18 पीढ़ियों का Family Tree • Member Profiles • Village Records'),const SizedBox(height:12),Row(children:[Expanded(child:Text('कुल सदस्य: ${members.length}',style:const TextStyle(fontWeight:FontWeight.bold))),FilledButton.icon(onPressed:_import,icon:const Icon(Icons.upload_file),label:const Text('Excel Upload'))])]))),
 Text(status),const SizedBox(height:12),const Text('नया Family Member जोड़ें',style:TextStyle(fontSize:18,fontWeight:FontWeight.bold)),const SizedBox(height:10),
 ...List.generate(7,(i)=>Padding(padding:const EdgeInsets.only(bottom:10),child:TextField(controller:c[i],decoration:InputDecoration(labelText:labels[i],border:const OutlineInputBorder())))),
 FilledButton.icon(onPressed:_add,icon:const Icon(Icons.person_add),label:const Text('Member Save करें')),const Divider(height:32),const Text('Family Members',style:TextStyle(fontSize:18,fontWeight:FontWeight.bold)),
 if(members.isEmpty)const Text('अभी कोई Member नहीं है। ऊपर से जानकारी जोड़ें या Excel Upload करें।'),
 ...members.asMap().entries.map((e)=>Card(child:ListTile(leading:CircleAvatar(child:Text(e.value.generation.isEmpty?'•':e.value.generation)),title:Text(e.value.name),subtitle:Text([if(e.value.father.isNotEmpty)'पिता: ${e.value.father}',if(e.value.village.isNotEmpty)'गाँव: ${e.value.village}',if(e.value.occupation.isNotEmpty)'काम: ${e.value.occupation}',if(e.value.spouse.isNotEmpty)'जीवनसाथी: ${e.value.spouse}'].join(' | ')),trailing:IconButton(icon:const Icon(Icons.delete_outline),onPressed:()async{setState(()=>members.removeAt(e.key));await _save();}))),
 const SizedBox(height:18),const Text('नोट: Hinglish अभी जैसे टाइप करेंगे वैसे ही सेव होगा। Hindi-English translation/transliteration अगली सुविधा में जोड़ी जाएगी। डेटा अभी केवल इसी फोन में सेव होता है।',style:TextStyle(fontSize:12,color:Colors.grey))
 ]));
}
