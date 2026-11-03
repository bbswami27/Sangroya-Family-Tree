import 'dart:convert';
import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

void main()=>runApp(const SangroyaApp());
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
 final String name,gender,father,mother,village,occupation,spouse,spouseCity,generation,dob,dod,marriageDate,visitedPlaces,jobType,jobCountry,jobDetails,notes,travelPlace,travelYear,travelDate,travelPurpose;
 const Member({this.name='',this.gender='',this.father='',this.mother='',this.village='',this.occupation='',this.spouse='',this.spouseCity='',this.generation='',this.dob='',this.dod='',this.marriageDate='',this.visitedPlaces='',this.jobType='',this.jobCountry='',this.jobDetails='',this.notes='',this.travelPlace='',this.travelYear='',this.travelDate='',this.travelPurpose=''});
 Map<String,dynamic> toJson()=>{'name':name,'gender':gender,'father':father,'mother':mother,'village':village,'occupation':occupation,'spouse':spouse,'spouseCity':spouseCity,'generation':generation,'dob':dob,'dod':dod,'marriageDate':marriageDate,'visitedPlaces':visitedPlaces,'jobType':jobType,'jobCountry':jobCountry,'jobDetails':jobDetails,'notes':notes,'travelPlace':travelPlace,'travelYear':travelYear,'travelDate':travelDate,'travelPurpose':travelPurpose};
 factory Member.fromJson(Map<String,dynamic> j)=>Member(name:j['name']??'',gender:j['gender']??'',father:j['father']??'',mother:j['mother']??'',village:j['village']??'',occupation:j['occupation']??'',spouse:j['spouse']??'',spouseCity:j['spouseCity']??'',generation:j['generation']??'',dob:j['dob']??'',dod:j['dod']??'',marriageDate:j['marriageDate']??'',visitedPlaces:j['visitedPlaces']??'',jobType:j['jobType']??'',jobCountry:j['jobCountry']??'',jobDetails:j['jobDetails']??'',notes:j['notes']??'',travelPlace:j['travelPlace']??'',travelYear:j['travelYear']??'',travelDate:j['travelDate']??'',travelPurpose:j['travelPurpose']??'');
}
class FamilyDocument { final String name,path,type; final int size; FamilyDocument({required this.name,required this.path,required this.type,required this.size}); Map<String,dynamic> toJson()=>{'name':name,'path':path,'type':type,'size':size}; factory FamilyDocument.fromJson(Map<String,dynamic> j)=>FamilyDocument(name:j['name']??'',path:j['path']??'',type:j['type']??'',size:j['size']??0); }
class FamilyHome extends StatefulWidget {const FamilyHome({super.key});@override State<FamilyHome> createState()=>_FamilyHomeState();}
class _FamilyHomeState extends State<FamilyHome>{
 final List<Member> members=[]; final List<FamilyDocument> documents=[]; String status='परिवार की जानकारी जोड़ें';
 @override void initState(){super.initState();load();}
 Future<void> load()async{final p=await SharedPreferences.getInstance();final s=p.getString('members');if(s!=null){try{final a=(jsonDecode(s) as List).map((e)=>Member.fromJson(Map<String,dynamic>.from(e))).toList();if(mounted)setState(()=>members.addAll(a));}catch(_){}} final ds=p.getString('family_documents'); if(ds!=null){try{final a=(jsonDecode(ds) as List).map((e)=>FamilyDocument.fromJson(Map<String,dynamic>.from(e))).toList();if(mounted)setState(()=>documents.addAll(a));}catch(_){}}}
 Future<void> save()async{final p=await SharedPreferences.getInstance();await p.setString('members',jsonEncode(members.map((m)=>m.toJson()).toList()));await p.setString('family_documents',jsonEncode(documents.map((d)=>d.toJson()).toList()));}
 Future<void> uploadDocument() async { final picked=await FilePicker.platform.pickFiles(type:FileType.custom,allowedExtensions:['pdf','jpg','jpeg','png'],withData:true); if(picked==null)return; final f=picked.files.single; if(f.bytes==null)return; final dir=await getApplicationDocumentsDirectory(); final folder=Directory('${dir.path}/family_documents'); await folder.create(recursive:true); final safe='${DateTime.now().millisecondsSinceEpoch}_${f.name.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'),'_')}'; final file=File('${folder.path}/$safe'); await file.writeAsBytes(f.bytes!,flush:true); setState(()=>documents.add(FamilyDocument(name:f.name,path:file.path,type:(f.extension??'').toLowerCase(),size:f.size))); await save(); setState(()=>status='Document अपलोड हुआ: ${f.name}'); }
 Future<void> downloadDocument(FamilyDocument d) async { final file=File(d.path); if(!await file.exists()){setState(()=>status='मूल फाइल नहीं मिली');return;} final bytes=await file.readAsBytes(); await FilePicker.platform.saveFile(dialogTitle:'फाइल सेव करें',fileName:d.name,bytes:bytes); }
 Future<void> exportBackup() async { final payload=jsonEncode({'members':members.map((m)=>m.toJson()).toList(),'documents':documents.map((d)=>d.toJson()).toList()}); await FilePicker.platform.saveFile(dialogTitle:'Family Backup सेव करें',fileName:'Sangroya_Family_Backup.json',bytes:Uint8List.fromList(utf8.encode(payload))); }
 Future<void> edit([int? i])async{final m=await showDialog<Member>(context:context,builder:(_)=>MemberForm(member:i==null?const Member():members[i]));if(m!=null){setState((){if(i==null){members.add(m);}else{members[i]=m;}status='जानकारी सुरक्षित हुई';});await save();}}
 Future<void> importExcel()async{final p=await FilePicker.platform.pickFiles(type:FileType.custom,allowedExtensions:['xlsx','xls'],withData:true);if(p==null||p.files.single.bytes==null){return;}try{final w=Excel.decodeBytes(p.files.single.bytes!);final added=<Member>[];for(final sh in w.tables.values){if(sh.rows.isEmpty)continue;final h=sh.rows.first.map((c)=>(c?.value?.toString()??'').toLowerCase()).toList();int ix(String s)=>h.indexWhere((x)=>x.contains(s));String v(List<Data?> r,int n)=>n<0||n>=r.length?'':(r[n]?.value?.toString()??'');for(final r in sh.rows.skip(1)){final n=v(r,ix('name'));if(n.trim().isEmpty){continue;}added.add(Member(name:n,gender:v(r,ix('gender')),father:v(r,ix('father')),mother:v(r,ix('mother')),village:v(r,ix('village')),occupation:v(r,ix('occupation')),spouse:v(r,ix('life partner')),spouseCity:v(r,ix('partner city')),generation:v(r,ix('generation')),dob:v(r,ix('date of birth')),dod:v(r,ix('date of death')),marriageDate:v(r,ix('marriage date')),visitedPlaces:v(r,ix('places visited')),jobType:v(r,ix('job type')),jobCountry:v(r,ix('job country')),jobDetails:v(r,ix('job details')),notes:v(r,ix('notes')),travelPlace:v(r,ix('travel place')),travelYear:v(r,ix('travel year')),travelDate:v(r,ix('travel date')),travelPurpose:v(r,ix('purpose of travel'))));}}setState(()=>members.addAll(added));await save();setState(()=>status='${added.length} records Import हुए');}catch(e){setState(()=>status='Excel error: $e');}}
 Future<void> template()async{final x=Excel.createExcel();final s=x['Family Members'];const h=['Name','Gender','Father','Mother','Village','Occupation','Life Partner','Life Partner City','Generation','Date of Birth','Date of Death','Marriage Date','Places Visited','Job Type','Job Country','Job Details','Notes','Ancestral Travel Place','Travel Year (Optional)','Travel Date (Optional)','Purpose of Travel'];s.appendRow(h.map((v)=>TextCellValue(v)).toList());s.appendRow(['नाम','पुरुष/महिला','पिता','माता','गाँव/शहर','पेशा','जीवनसाथी','शहर','1','DD-MM-YYYY','DD-MM-YYYY','DD-MM-YYYY','शहर/देश','Domestic/International','देश','कंपनी, पद, काम','अन्य','यात्रा स्थान','वैकल्पिक वर्ष','वैकल्पिक तारीख','यात्रा उद्देश्य'].map((v)=>TextCellValue(v)).toList());final b=x.encode();if(b!=null)await FilePicker.platform.saveFile(dialogTitle:'Excel Template सेव करें',fileName:'Sangroya_Family_Tree_Template.xlsx',bytes:Uint8List.fromList(b));}
 void tree()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>FamilyTreePage(members:members)));
 void showDocuments(){Navigator.pop(context);Navigator.push(context,MaterialPageRoute(builder:(_)=>Scaffold(appBar:AppBar(title:const Text('Family Documents')),body:documents.isEmpty?const Center(child:Text('अभी कोई PDF/JPEG अपलोड नहीं है')):ListView(children:documents.map((d)=>ListTile(leading:Icon(d.type=='pdf'?Icons.picture_as_pdf:Icons.image),title:Text(d.name),subtitle:Text('${(d.size/1024).toStringAsFixed(1)} KB'),trailing:IconButton(icon:const Icon(Icons.download),onPressed:()=>downloadDocument(d)))).toList()))));}
 void showAccess(bool registration){Navigator.pop(context);Navigator.push(context,MaterialPageRoute(builder:(_)=>AccessPage(registration:registration)));}
 @override Widget build(BuildContext context)=>Scaffold(
 drawer:Drawer(child:ListView(padding:EdgeInsets.zero,children:[DrawerHeader(decoration:const BoxDecoration(gradient:LinearGradient(colors:[Color(0xFF0B4A22),Color(0xFF27A36B)])),child:const Column(crossAxisAlignment:CrossAxisAlignment.start,mainAxisAlignment:MainAxisAlignment.end,children:[Icon(Icons.account_tree,color:Colors.white,size:38),Text('SANGROYA FAMILY TREE',style:TextStyle(color:Colors.white,fontWeight:FontWeight.bold,fontSize:18)),Text('परिवार की डिजिटल वंशावली',style:TextStyle(color:Colors.white))])),ListTile(leading:const Icon(Icons.upload_file),title:const Text('Upload PDF / JPEG'),onTap:(){Navigator.pop(context);uploadDocument();}),ListTile(leading:const Icon(Icons.download),title:const Text('Download / Backup'),onTap:(){Navigator.pop(context);exportBackup();}),ListTile(leading:const Icon(Icons.person_add),title:const Text('Add Family Member'),onTap:(){Navigator.pop(context);edit();}),ListTile(leading:const Icon(Icons.account_tree),title:const Text('Family Tree'),onTap:(){Navigator.pop(context);tree();}),ListTile(leading:const Icon(Icons.folder),title:const Text('Documents / Gallery'),onTap:showDocuments),ListTile(leading:const Icon(Icons.travel_explore),title:const Text('पूर्वजों की यात्रा'),onTap:(){Navigator.pop(context);Navigator.push(context,MaterialPageRoute(builder:(_)=>TravelPage(members:members)));}),ListTile(leading:const Icon(Icons.history_edu),title:const Text('बैरागी संप्रदाय का इतिहास'),onTap:(){Navigator.pop(context);Navigator.push(context,MaterialPageRoute(builder:(_)=>const CommunityHistoryPage()));}),const Divider(),ListTile(leading:const Icon(Icons.login),title:const Text('Family Login'),onTap:()=>showAccess(false)),ListTile(leading:const Icon(Icons.app_registration),title:const Text('Mobile Registration'),onTap:()=>showAccess(true)),const ListTile(leading:Icon(Icons.admin_panel_settings),title:Text('Admin Panel — अगला चरण'),subtitle:Text('केवल Super Admin के लिए'))])),
 appBar:AppBar(title:const Text('SANGROYA FAMILY TREE'),actions:[IconButton(onPressed:showDocuments,icon:const Icon(Icons.folder_open))]),
 body:Container(decoration:const BoxDecoration(gradient:LinearGradient(begin:Alignment.topLeft,end:Alignment.bottomRight,colors:[Color(0xFFEAF7EF),Color(0xFFFFF1DC),Color(0xFFF4FAF2)])),child:ListView(padding:const EdgeInsets.all(14),children:[
 Container(padding:const EdgeInsets.all(18),decoration:BoxDecoration(gradient:const LinearGradient(colors:[Color(0xFF0B4A22),Color(0xFF2C8B61)]),borderRadius:BorderRadius.circular(20)),child:const Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Hamari virasat, hamari pahchan',style:TextStyle(color:Colors.white,fontSize:21,fontWeight:FontWeight.bold)),Text('Hamari Legacy',style:TextStyle(color:Colors.white70))])),
 const SizedBox(height:12),GridView.count(crossAxisCount:2,shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),crossAxisSpacing:10,mainAxisSpacing:10,childAspectRatio:1.55,children:[_dash(Icons.account_tree,'Family Tree','वंशावली देखें',const Color(0xFF236B52),tree),_dash(Icons.person_add_alt_1,'Add Member','नया सदस्य जोड़ें',const Color(0xFFFF8A00),()=>edit()),_dash(Icons.upload_file,'Upload Files','PDF / JPEG / PNG',const Color(0xFF2C8B57),uploadDocument),_dash(Icons.download,'Download','Backup / Export',const Color(0xFFFF9A1F),exportBackup)]),
 Card(child:ListTile(title:const Text('कुल परिवार सदस्य'),trailing:Text('${members.length}',style:const TextStyle(fontSize:24,fontWeight:FontWeight.bold)))),Card(child:ListTile(title:const Text('अपलोड दस्तावेज़'),trailing:Text('${documents.length}',style:const TextStyle(fontSize:24,fontWeight:FontWeight.bold)),onTap:showDocuments)),Text(status),const Text('सदस्य सूची',style:TextStyle(fontWeight:FontWeight.bold,fontSize:18)),...members.asMap().entries.map((e)=>Card(child:ListTile(title:Text(e.value.name),subtitle:Text([e.value.gender,e.value.village,e.value.father].where((x)=>x.isNotEmpty).join(' • ')),onTap:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>ProfilePage(member:e.value,all:members))),trailing:IconButton(icon:const Icon(Icons.edit),onPressed:()=>edit(e.key))))),const SizedBox(height:70)])),
 floatingActionButton:FloatingActionButton.extended(onPressed:()=>edit(),icon:const Icon(Icons.person_add),label:const Text('Member जोड़ें')));
 Widget _dash(IconData icon,String title,String sub,Color color,VoidCallback action)=>InkWell(onTap:action,borderRadius:BorderRadius.circular(16),child:Container(padding:const EdgeInsets.all(13),decoration:BoxDecoration(color:color,borderRadius:BorderRadius.circular(16)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,mainAxisAlignment:MainAxisAlignment.center,children:[Icon(icon,color:Colors.white,size:28),const SizedBox(height:6),Text(title,style:const TextStyle(color:Colors.white,fontWeight:FontWeight.bold,fontSize:16)),Text(sub,style:const TextStyle(color:Colors.white70,fontSize:12))])));

}
class MemberForm extends StatefulWidget{final Member member;const MemberForm({super.key,required this.member});@override State<MemberForm> createState()=>_MemberFormState();}
class _MemberFormState extends State<MemberForm>{
 late final Map<String,TextEditingController> c;late String gender,job;
 @override void initState(){super.initState();final m=widget.member;gender=m.gender.isEmpty?'पुरुष':m.gender;job=m.jobType.isEmpty?'Domestic':m.jobType;c={'name':m.name,'father':m.father,'mother':m.mother,'village':m.village,'occupation':m.occupation,'spouse':m.spouse,'spouseCity':m.spouseCity,'generation':m.generation,'dob':m.dob,'dod':m.dod,'marriageDate':m.marriageDate,'visitedPlaces':m.visitedPlaces,'jobCountry':m.jobCountry,'jobDetails':m.jobDetails,'notes':m.notes,'travelPlace':m.travelPlace,'travelYear':m.travelYear,'travelDate':m.travelDate,'travelPurpose':m.travelPurpose}.map((k,v)=>MapEntry(k,TextEditingController(text:v)));}
 @override void dispose(){for(final x in c.values){x.dispose();}super.dispose();}
 Widget f(String k,String label,{int lines=1})=>Padding(padding:const EdgeInsets.only(bottom:8),child:TextField(controller:c[k],maxLines:lines,decoration:InputDecoration(labelText:label,border:const OutlineInputBorder())));
 @override Widget build(BuildContext context)=>AlertDialog(title:Text(widget.member.name.isEmpty?'नया सदस्य':'Member Edit करें'),content:SizedBox(width:500,child:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[f('name','पूरा नाम'),DropdownButtonFormField(initialValue:gender,decoration:const InputDecoration(labelText:'लिंग'),items:const [DropdownMenuItem(value:'पुरुष',child:Text('पुरुष / Male')),DropdownMenuItem(value:'महिला',child:Text('महिला / Female')),DropdownMenuItem(value:'अन्य',child:Text('अन्य'))],onChanged:(v){if(v!=null)setState(()=>gender=v);}),const SizedBox(height:8),f('father','पिता का नाम'),f('mother','माता का नाम'),f('village','गाँव / जन्म स्थान'),f('dob','Date of Birth DD-MM-YYYY'),f('dod','Date of Death DD-MM-YYYY'),f('spouse','जीवनसाथी का नाम'),f('spouseCity','जीवनसाथी का शहर'),f('marriageDate','Marriage Date DD-MM-YYYY'),f('generation','पीढ़ी संख्या'),f('occupation','पेशा / पद'),DropdownButtonFormField(initialValue:job,decoration:const InputDecoration(labelText:'Job Type'),items:const [DropdownMenuItem(value:'Domestic',child:Text('Domestic — भारत')),DropdownMenuItem(value:'International',child:Text('International — विदेश')),DropdownMenuItem(value:'लागू नहीं',child:Text('लागू नहीं'))],onChanged:(v){if(v!=null)setState(()=>job=v);}),if(job=='International')f('jobCountry','किस देश में नौकरी?'),f('jobDetails','Job Details — कंपनी, पद, शहर, अवधि',lines:3),f('visitedPlaces','कहाँ-कहाँ Visit किया',lines:2),f('travelPlace','पूर्वजों की यात्रा — स्थान'),f('travelYear','यात्रा वर्ष (वैकल्पिक)'),f('travelDate','यात्रा तारीख (वैकल्पिक)'),f('travelPurpose','यात्रा का उद्देश्य',lines:2),f('notes','अन्य जानकारी',lines:2)]))),actions:[TextButton(onPressed:()=>Navigator.pop(context),child:const Text('Cancel')),FilledButton(onPressed:(){if(c['name']!.text.trim().isEmpty)return;String v(String k)=>c[k]!.text.trim();Navigator.pop(context,Member(name:v('name'),gender:gender,father:v('father'),mother:v('mother'),village:v('village'),occupation:v('occupation'),spouse:v('spouse'),spouseCity:v('spouseCity'),generation:v('generation'),dob:v('dob'),dod:v('dod'),marriageDate:v('marriageDate'),visitedPlaces:v('visitedPlaces'),jobType:job,jobCountry:v('jobCountry'),jobDetails:v('jobDetails'),notes:v('notes'),travelPlace:v('travelPlace'),travelYear:v('travelYear'),travelDate:v('travelDate'),travelPurpose:v('travelPurpose')));},child:const Text('Save'))]);
}
class ProfilePage extends StatelessWidget{
 final Member member;final List<Member> all;const ProfilePage({super.key,required this.member,required this.all});
 List<Member> named(String n)=>all.where((m)=>m.name.toLowerCase().trim()==n.toLowerCase().trim()).toList();
 List<Member> kids(String n)=>all.where((m)=>m.father.toLowerCase().trim()==n.toLowerCase().trim()).toList();
 Widget row(String k,String v)=>v.isEmpty?const SizedBox.shrink():ListTile(title:Text(k),subtitle:Text(v));
 @override Widget build(BuildContext context){final f=named(member.father);final g=f.length==1?named(f.first.father):<Member>[];final sons=kids(member.name);final grand=sons.expand((m)=>kids(m.name)).toList();return Scaffold(appBar:AppBar(title:Text(member.name)),body:ListView(padding:const EdgeInsets.all(12),children:[Card(child:Column(children:[row('लिंग',member.gender),row('जन्म तिथि',member.dob),row('मृत्यु तिथि',member.dod),row('जन्म स्थान',member.village),row('पिता',member.father),row('माता',member.mother),row('दादा',g.length==1?g.first.name:'रिकॉर्ड नहीं मिला') ])),Card(child:Column(children:[row('जीवनसाथी',member.spouse),row('जीवनसाथी का शहर',member.spouseCity),row('विवाह तारीख',member.marriageDate)])),Card(child:Column(children:[row('पेशा',member.occupation),row('Job Type',member.jobType),row('देश',member.jobCountry),row('Job Details',member.jobDetails),row('Visited Places',member.visitedPlaces)])),Card(child:Column(children:[const ListTile(title:Text('तीन पीढ़ियों का विवरण')),row('पुत्र / पुत्रियाँ',sons.map((m)=>m.name).join(', ')),row('पोते / पोतियाँ',grand.map((m)=>m.name).join(', '))]))]));}
}
class FamilyTreePage extends StatelessWidget{final List<Member> members;const FamilyTreePage({super.key,required this.members});@override Widget build(BuildContext context){final counts=<String,int>{};for(final m in members){final k=m.name.toLowerCase().trim();counts[k]=(counts[k]??0)+1;}final map=<String,List<Member>>{};for(final m in members){final k=m.father.toLowerCase().trim();if(k.isNotEmpty&&counts[k]==1)map.putIfAbsent(k,()=>[]).add(m);}final roots=members.where((m){final k=m.father.toLowerCase().trim();return k.isEmpty||counts[k]!=1;}).toList();return Scaffold(appBar:AppBar(title:const Text('Family Tree')),body:ListView(padding:const EdgeInsets.all(12),children:[const Text('किसी भी सदस्य पर क्लिक करके पिता, दादा, बच्चों और पोते-पोतियों का विवरण देखें।'),...roots.map((m)=>TreeNode(m:m,map:map,all:members,path:<String>{},depth:1))]));}}
class TreeNode extends StatelessWidget{final Member m;final Map<String,List<Member>> map;final List<Member> all;final Set<String> path;final int depth;const TreeNode({super.key,required this.m,required this.map,required this.all,required this.path,required this.depth});@override Widget build(BuildContext context){final k=m.name.toLowerCase().trim();final p={...path,k};final kids=(map[k]??[]).where((x)=>!p.contains(x.name.toLowerCase().trim())).toList();final tile=ListTile(title:Text(m.name),subtitle:Text([m.gender,m.village,m.spouse].where((x)=>x.isNotEmpty).join(' • ')),onTap:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>ProfilePage(member:m,all:all))));return Card(margin:EdgeInsets.only(left:(depth-1)*10),child:kids.isEmpty?tile:ExpansionTile(title:Text(m.name),subtitle:tile.subtitle,children:kids.map((x)=>TreeNode(m:x,map:map,all:all,path:p,depth:depth+1)).toList()));}}


class TravelPage extends StatelessWidget {
 final List<Member> members;
 const TravelPage({super.key,required this.members});
 @override Widget build(BuildContext context) {
  final records=members.where((m)=>m.travelPlace.trim().isNotEmpty||m.visitedPlaces.trim().isNotEmpty).toList();
  return Scaffold(appBar:AppBar(title:const Text('पूर्वजों की यात्रा')),body:records.isEmpty
   ?const Center(child:Text('अभी यात्रा का विवरण दर्ज नहीं है। सदस्य की प्रोफाइल/फॉर्म में यात्रा विवरण जोड़ें।'))
   :ListView(padding:const EdgeInsets.all(12),children:records.map((m)=>Card(child:ListTile(leading:const Icon(Icons.travel_explore,color:Color(0xFFFF8A00)),title:Text(m.name),subtitle:Text([m.travelPlace,m.travelYear,m.travelDate,m.travelPurpose,m.visitedPlaces].where((v)=>v.trim().isNotEmpty).join(' • '))))).toList()));
 }
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
 ]);
}

class AccessPage extends StatelessWidget {
  final bool registration;
  const AccessPage({super.key, required this.registration});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(registration ? 'Family Registration' : 'Family Login')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    registration ? Icons.app_registration : Icons.lock_outline,
                    size: 48,
                    color: const Color(0xFF236B52),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    registration ? 'परिवार सदस्यता अनुरोध' : 'परिवार लॉगिन',
                    style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  if (registration)
                    const TextField(
                      decoration: InputDecoration(
                        labelText: 'पूरा नाम',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  const TextField(
                    decoration: InputDecoration(
                      labelText: 'मोबाइल नंबर',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'पासवर्ड',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  FilledButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'यह केवल UI प्रोटोटाइप है। सुरक्षित लॉगिन, रजिस्ट्रेशन और Admin approval Firebase जोड़ने के बाद सक्रिय होंगे।',
                          ),
                        ),
                      );
                    },
                    child: Text(registration ? 'Request Registration' : 'Login'),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'अभी यह केवल डिजाइन है। वास्तविक अकाउंट, पासवर्ड सत्यापन, Super Admin approval और multi-phone sync सक्रिय नहीं हैं।',
                    style: TextStyle(color: Colors.deepOrange),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
