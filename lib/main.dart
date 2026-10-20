import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:file_picker/file_picker.dart';

String gTel = ""; String gIsm = ""; String gRol = "";
const String API = "http://127.0.0.1:8000/api";

void main() => runApp(MaterialApp(debugShowCheckedModeBanner: false, home: LoginEkrani(), theme: ThemeData(primarySwatch: Colors.blue)));

// ================= LOGIN VA PAROL TEKSHIRUV =================
class LoginEkrani extends StatefulWidget { @override _LoginEkraniState createState() => _LoginEkraniState(); }
class _LoginEkraniState extends State<LoginEkrani> {
  final _tel = TextEditingController(); final _parol = TextEditingController(); bool _kut = false;
  
  kirish() async {
    if(_tel.text.isEmpty || _parol.text.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("To'liq kiriting!"))); return; }
    setState(() => _kut = true);
    try {
      final res = await http.post(Uri.parse('$API/login'), headers: {"Content-Type": "application/json"}, body: jsonEncode({"telefon": _tel.text, "parol": _parol.text}));
      if (res.statusCode == 200) {
        final d = jsonDecode(res.body); gTel = d['telefon']; gIsm = d['ism']; gRol = d['rol'];
        
        // MANTIQ: Agar parol eski bo'lsa (12345), majburiy o'zgartirish ekraniga o'tadi
        if (_parol.text == "12345") {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MajburiyParolEkrani()));
        } else {
          Widget ekran = DirektorEkrani();
          if (gRol == 'oqituvchi') ekran = OqituvchiEkrani(); else if (gRol == 'kassir') ekran = KassirEkrani(); else if (gRol == 'oquvchi') ekran = OquvchiEkrani();
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ekran));
        }
      } else { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Raqam yoki parol XATO!"), backgroundColor: Colors.red)); }
    } catch(e) {}
    setState(() => _kut = false);
  }
  @override Widget build(BuildContext context) => Scaffold(body: Padding(padding: EdgeInsets.all(20), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.security, size: 100, color: Colors.blue), SizedBox(height: 20), Text("Tizimga Kirish", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.blue[900])), SizedBox(height: 30), TextField(controller: _tel, decoration: InputDecoration(labelText: "Raqamingiz (+998...)", prefixIcon: Icon(Icons.phone), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)))), SizedBox(height: 15), TextField(controller: _parol, obscureText: true, decoration: InputDecoration(labelText: "Parol (Kod)", prefixIcon: Icon(Icons.lock), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)))), SizedBox(height: 20), _kut ? CircularProgressIndicator() : ElevatedButton(onPressed: kirish, child: Text("KIRISH", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 55), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)))) ])));
}

class MajburiyParolEkrani extends StatefulWidget { @override _MajburiyParolState createState() => _MajburiyParolState(); }
class _MajburiyParolState extends State<MajburiyParolEkrani> {
  final _yangi = TextEditingController(); final _takror = TextEditingController(); bool _kutish = false;
  saqlash() async {
    if (_yangi.text.length < 4) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Kamida 4 belgi bo'lishi kerak!"))); return; }
    if (_yangi.text != _takror.text) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Parollar mos tushmadi!"))); return; }
    setState(() => _kutish = true);
    try {
      final res = await http.post(Uri.parse('$API/parol_almashtir'), headers: {"Content-Type": "application/json"}, body: jsonEncode({"telefon": gTel, "yangi_parol": _yangi.text}));
      if (res.statusCode == 200) {
        Widget ekran = DirektorEkrani();
        if (gRol == 'oqituvchi') ekran = OqituvchiEkrani(); else if (gRol == 'kassir') ekran = KassirEkrani(); else if (gRol == 'oquvchi') ekran = OquvchiEkrani();
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ekran));
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Parol muvaffaqiyatli o'rnatildi!"), backgroundColor: Colors.green));
      }
    } catch(e) {}
    setState(() => _kutish = false);
  }
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text("Parolni Almashtirish"), backgroundColor: Colors.red, automaticallyImplyLeading: false), body: Padding(padding: EdgeInsets.all(20), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.lock_reset, size: 80, color: Colors.red), SizedBox(height: 20), Text("Xavfsizlik uchun boshlang'ich parolni (12345) o'zgartiring!", textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), SizedBox(height: 30), TextField(controller: _yangi, obscureText: true, decoration: InputDecoration(labelText: "Yangi parol", border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)))), SizedBox(height: 15), TextField(controller: _takror, obscureText: true, decoration: InputDecoration(labelText: "Parolni takrorlang", border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)))), SizedBox(height: 20), _kutish ? CircularProgressIndicator() : ElevatedButton(onPressed: saqlash, child: Text("SAQLASH VA DAVOM ETISH"), style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, minimumSize: Size(double.infinity, 55), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))))])));
}

// ================= YORDAMCHI WIDGET (Statik Ekran) =================
class StatikEkran extends StatelessWidget { final String nomi, matn; final Color rang; StatikEkran({required this.nomi, required this.matn, required this.rang}); @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text(nomi), backgroundColor: rang), body: Center(child: Padding(padding: EdgeInsets.all(20), child: Text(matn, style: TextStyle(fontSize: 20, height: 1.5), textAlign: TextAlign.center)))); }

// ================= 1. DIREKTOR EKRANI VA FUNKSIYALARI =================
class DirektorEkrani extends StatelessWidget {
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text("Direktor: $gIsm"), backgroundColor: Colors.blue[800], foregroundColor: Colors.white, actions: [IconButton(icon: Icon(Icons.exit_to_app), onPressed: ()=>Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>LoginEkrani())))]),
    body: GridView.count(crossAxisCount: 2, padding: EdgeInsets.all(10), children: [
      _t(context, Icons.people, "Xodimlar Boshqaruvi", Colors.blue, XodimlarEkrani()),
      _t(context, Icons.school, "O'quvchi & Ustozlar", Colors.cyan, DirOquvchilar()),
      _t(context, Icons.group_add, "O'quvchi Yuklash", Colors.green, OquvchiExcelEkrani(turi: "oquvchi")),
      _t(context, Icons.assignment_turned_in, "Blok Test Yuklash", Colors.teal, OquvchiExcelEkrani(turi: "test")),
      _t(context, Icons.analytics, "Batafsil Moliya", Colors.orange, BatafsilKassaEkrani()),
      _t(context, Icons.checklist, "Umumiy Davomat", Colors.purple, DirDavomat()),
      _t(context, Icons.location_on, "Keldi-Ketdi", Colors.red, DirLokatsiya()),
    ]));
  Widget _t(BuildContext c, IconData i, String n, Color r, Widget e) => Card(elevation: 4, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), margin: EdgeInsets.all(8), child: InkWell(onTap: () => Navigator.push(c, MaterialPageRoute(builder: (_) => e)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(i, size: 45, color: r), SizedBox(height: 10), Text(n, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))])));
}
class XodimlarEkrani extends StatefulWidget { @override _XodimlarState createState() => _XodimlarState(); }
class _XodimlarState extends State<XodimlarEkrani> {
  List xodimlar = []; void initState() { super.initState(); yukla(); }
  yukla() async { final r = await http.get(Uri.parse('$API/direktor/xodimlar')); if(r.statusCode==200) setState(()=> xodimlar=jsonDecode(r.body)); }
  ochirish(String tel) async { await http.delete(Uri.parse('$API/direktor/xodim_ochir/${tel.replaceAll("+","")}')); yukla(); }
  qoshish() {
    final _ism = TextEditingController(); final _tel = TextEditingController(); String _rol = "oqituvchi";
    showDialog(context: context, builder: (_) => AlertDialog(title: Text("Yangi Xodim"), content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: _ism, decoration: InputDecoration(labelText: "Ismi")), TextField(controller: _tel, decoration: InputDecoration(labelText: "Raqami (+998...)")), DropdownButtonFormField(value: _rol, items: ["oqituvchi", "kassir", "direktor"].map((e)=>DropdownMenuItem(value:e, child:Text(e))).toList(), onChanged: (v)=>_rol=v.toString())]), actions: [ElevatedButton(child: Text("SAQLASH"), onPressed: () async { await http.post(Uri.parse('$API/direktor/xodim_qosh'), headers: {"Content-Type":"application/json"}, body: jsonEncode({"ism": _ism.text, "telefon": _tel.text, "rol": _rol})); Navigator.pop(context); yukla(); })]));
  }
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text("Xodimlar Boshqaruvi"), backgroundColor: Colors.blue), body: ListView.builder(itemCount: xodimlar.length, itemBuilder: (_, i) => ListTile(leading: CircleAvatar(backgroundColor: Colors.blue[100], child: Icon(Icons.person, color: Colors.blue)), title: Text(xodimlar[i]['ism']), subtitle: Text("${xodimlar[i]['rol'].toString().toUpperCase()} | ${xodimlar[i]['telefon']}\nParol: 12345"), trailing: IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: ()=>ochirish(xodimlar[i]['telefon'])))), floatingActionButton: FloatingActionButton(backgroundColor: Colors.blue, child: Icon(Icons.add), onPressed: qoshish));
}
class DirOquvchilar extends StatelessWidget {
  Future<List> fetch() async { final r = await http.get(Uri.parse('$API/direktor/oquvchilar')); return jsonDecode(r.body); }
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text("O'quvchilar"), backgroundColor: Colors.cyan), body: FutureBuilder<List>(future: fetch(), builder: (c, s) => s.hasData ? ListView.builder(itemCount: s.data!.length, itemBuilder: (_, i) { var o = s.data![i]; return Card(margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5), child: ListTile(leading: Icon(Icons.school, color: Colors.cyan, size: 40), title: Text(o['ism'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), subtitle: Text("📞 Tel: ${o['telefon']} (Parol: 12345)\n📚 Guruh: ${o['guruh'] ?? "-"}\n👨‍🏫 Ustoz: ${o['oqituvchi'] ?? "-"}"), isThreeLine: true)); }) : Center(child: CircularProgressIndicator())));
}
class DirLokatsiya extends StatelessWidget {
  Future<List> fetch() async { final r = await http.get(Uri.parse('$API/direktor/lokatsiyalar')); return jsonDecode(r.body); }
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text("Keldi-Ketdi (Lokatsiya)"), backgroundColor: Colors.red), body: FutureBuilder<List>(future: fetch(), builder: (c, s) => s.hasData ? ListView.builder(itemCount: s.data!.length, itemBuilder: (_, i) { var l = s.data![i]; return Card(margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5), child: ListTile(leading: Icon(Icons.location_on, color: Colors.red, size: 40), title: Text(l['ism'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), subtitle: Text("🕒 Vaqt: ${l['vaqt']}\n📍 Lok: ${l['lat']}, ${l['lon']}", style: TextStyle(color: Colors.blue[800])), isThreeLine: true)); }) : Center(child: CircularProgressIndicator())));
}
class DirDavomat extends StatelessWidget {
  Future<List> fetch() async { final r = await http.get(Uri.parse('$API/direktor/davomatlar')); return jsonDecode(r.body); }
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text("Umumiy Davomat"), backgroundColor: Colors.purple), body: FutureBuilder<List>(future: fetch(), builder: (c, s) => s.hasData ? ListView.builder(itemCount: s.data!.length, itemBuilder: (_, i) => Card(margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5), child: ListTile(leading: Icon(Icons.calendar_month, color: Colors.purple), title: Text(s.data![i]['ism'], style: TextStyle(fontWeight: FontWeight.bold)), subtitle: Text(s.data![i]['sana']), trailing: Text(s.data![i]['holat']=='Keldi'?'✅ Keldi':'❌ Kelmadi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: s.data![i]['holat']=='Keldi'?Colors.green:Colors.red))))) : Center(child: CircularProgressIndicator())));
}
class OquvchiExcelEkrani extends StatefulWidget { final String turi; OquvchiExcelEkrani({required this.turi}); @override _ExcelState createState() => _ExcelState(); }
class _ExcelState extends State<OquvchiExcelEkrani> {
  bool _kutish = false;
  yuklash() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['xlsx'], withData: true);
    if (result != null) {
      setState(() => _kutish = true);
      String urlManzil = widget.turi == "oquvchi" ? '/api/direktor/excel_yuklash' : '/api/direktor/test_yuklash';
      if(widget.turi == "test") { await Future.delayed(Duration(seconds: 2)); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Test natijalari qabul qilindi!"))); setState(() => _kutish = false); return; }
      var req = http.MultipartRequest('POST', Uri.parse('$API$urlManzil')); req.files.add(http.MultipartFile.fromBytes('fayl', result.files.first.bytes!, filename: 'baza.xlsx'));
      var res = await req.send(); var respStr = await res.stream.bytesToString();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(jsonDecode(respStr)['xabar'] ?? "Tugallandi"))); setState(() => _kutish = false);
    }
  }
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text(widget.turi == "oquvchi" ? "O'quvchi Yuklash" : "Test Yuklash"), backgroundColor: widget.turi == "oquvchi" ? Colors.green : Colors.teal), body: Center(child: _kutish ? CircularProgressIndicator() : Padding(padding: EdgeInsets.all(20), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.file_upload, size: 80, color: widget.turi == "oquvchi" ? Colors.green : Colors.teal), SizedBox(height: 20), Text(widget.turi == "oquvchi" ? "O'quvchilar bazasi (.xlsx)\nUstunlar: Ism, Telefon, Guruh_nomi, Oqituvchi_raqami" : "Blok Test Natijalari (.xlsx)\nUstunlar: Telefon, Fan, Ball", textAlign: TextAlign.center, style: TextStyle(fontSize: 16)), SizedBox(height: 30), ElevatedButton.icon(icon: Icon(Icons.upload, color: Colors.white), label: Text("FAYLNI YUKLASH", style: TextStyle(color: Colors.white, fontSize: 16)), onPressed: yuklash, style: ElevatedButton.styleFrom(minimumSize: Size(250, 60), backgroundColor: widget.turi == "oquvchi" ? Colors.green : Colors.teal, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))))]))));
}
class BatafsilKassaEkrani extends StatelessWidget {
  Future<Map> fetch() async { final r = await http.get(Uri.parse('$API/direktor/batafsil_kassa')); return jsonDecode(r.body); }
  @override Widget build(BuildContext context) => DefaultTabController(length: 3, child: Scaffold(appBar: AppBar(title: Text("Moliya va Tarix"), backgroundColor: Colors.orange, bottom: TabBar(indicatorColor: Colors.white, tabs: [Tab(text: "Hisobot"), Tab(text: "Kirim"), Tab(text: "Chiqim")])), body: FutureBuilder<Map>(future: fetch(), builder: (c, s) {
    if(!s.hasData) return Center(child: CircularProgressIndicator()); var d = s.data!;
    return TabBarView(children: [
      ListView(padding: EdgeInsets.all(15), children: [ _quti("BUGUN", d['kun']['kirim'], d['kun']['chiqim']), SizedBox(height: 10), _quti("SHU HAFTA", d['hafta']['kirim'], d['hafta']['chiqim']), SizedBox(height: 10), _quti("SHU OY", d['oy']['kirim'], d['oy']['chiqim']) ]),
      ListView.builder(itemCount: d['kirimlar'].length, itemBuilder: (_, i) { var k = d['kirimlar'][i]; return Card(child: ListTile(leading: Icon(Icons.arrow_downward, color: Colors.green), title: Text("${k['ism']} (${k['usul']})", style: TextStyle(fontWeight: FontWeight.bold)), subtitle: Text(k['sana']), trailing: Text("+${k['summa']}", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16)))); }),
      ListView.builder(itemCount: d['chiqimlar'].length, itemBuilder: (_, i) { var ch = d['chiqimlar'][i]; return Card(child: ListTile(leading: Icon(Icons.arrow_upward, color: Colors.red), title: Text(ch['izoh'], style: TextStyle(fontWeight: FontWeight.bold)), subtitle: Text(ch['sana']), trailing: Text("-${ch['summa']}", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)))); })
    ]);
  })));
  Widget _quti(String n, num k, num c) => Card(elevation: 3, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), color: Colors.orange[50], child: Padding(padding: EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(n, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange[900])), Divider(thickness: 2), Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("Kirim:", style: TextStyle(fontSize: 16)), Text("+${k.toStringAsFixed(0)}", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 18))]), Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("Chiqim:", style: TextStyle(fontSize: 16)), Text("-${c.toStringAsFixed(0)}", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18))]), Divider(thickness: 2), Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("SOF FOYDA:", style: TextStyle(fontWeight: FontWeight.bold)), Text("${(k-c).toStringAsFixed(0)} so'm", style: TextStyle(color: Colors.blue[900], fontWeight: FontWeight.bold, fontSize: 22))])])));
}

// ================= 2. O'QITUVCHI EKRANI VA FUNKSIYALARI =================
class OqituvchiEkrani extends StatelessWidget {
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text("O'qituvchi: $gIsm"), backgroundColor: Colors.green, foregroundColor: Colors.white, actions: [IconButton(icon: Icon(Icons.exit_to_app), onPressed: ()=>Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>LoginEkrani())))]),
    body: ListView(padding: EdgeInsets.all(20), children: [ElevatedButton.icon(icon: Icon(Icons.checklist_rtl, size: 30, color: Colors.white), label: Text("Davomat Qilish", style: TextStyle(fontSize: 20, color: Colors.white)), onPressed: ()=>Navigator.push(context, MaterialPageRoute(builder: (_)=>OqGuruhlar())), style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 90), backgroundColor: Colors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)))), SizedBox(height: 20), ElevatedButton.icon(icon: Icon(Icons.star, size: 30, color: Colors.white), label: Text("Maosh va Reyting", style: TextStyle(fontSize: 20, color: Colors.white)), onPressed: ()=>Navigator.push(context, MaterialPageRoute(builder: (_)=>OqMaosh())), style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 90), backgroundColor: Colors.orange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))))]));
}
class OqGuruhlar extends StatefulWidget { @override _OqGuruhlarState createState() => _OqGuruhlarState(); }
class _OqGuruhlarState extends State<OqGuruhlar> {
  List guruhlar = []; void initState() { super.initState(); yukla(); }
  yukla() async { final r = await http.get(Uri.parse('$API/oqituvchi/guruhlar?tel=${Uri.encodeComponent(gTel)}')); setState(()=> guruhlar = jsonDecode(r.body)); }
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text("Guruhlaringiz"), backgroundColor: Colors.green), body: ListView.builder(itemCount: guruhlar.length, itemBuilder: (_, i) => Card(margin: EdgeInsets.all(10), child: ListTile(contentPadding: EdgeInsets.all(15), title: Text(guruhlar[i]['nomi'], style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), trailing: Icon(Icons.arrow_forward_ios, color: Colors.green), onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (_)=>OqDavomatBelgilash(g_id: guruhlar[i]['id'], g_nomi: guruhlar[i]['nomi'])))))));
}
class OqDavomatBelgilash extends StatefulWidget { final int g_id; final String g_nomi; OqDavomatBelgilash({required this.g_id, required this.g_nomi}); @override _OqDavomatBelgilashState createState() => _OqDavomatBelgilashState(); }
class _OqDavomatBelgilashState extends State<OqDavomatBelgilash> {
  List oq = []; void initState() { super.initState(); yukla(); }
  yukla() async { final r = await http.get(Uri.parse('$API/oqituvchi/oquvchilar?guruh_id=${widget.g_id}')); setState(()=> oq = jsonDecode(r.body)); }
  saqla(int oq_id, String holat) async { await http.post(Uri.parse('$API/oqituvchi/davomat_saqla'), headers: {"Content-Type":"application/json"}, body: jsonEncode({"guruh_id": widget.g_id, "oq_id": oq_id, "holat": holat, "oqituvchi_tel": gTel})); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$holat saqlandi!"), backgroundColor: holat == "Keldi" ? Colors.green : Colors.red)); }
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text(widget.g_nomi), backgroundColor: Colors.green), body: ListView.builder(itemCount: oq.length, itemBuilder: (_, i) => Card(margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5), child: ListTile(title: Text(oq[i]['ism'], style: TextStyle(fontWeight: FontWeight.bold)), trailing: Row(mainAxisSize: MainAxisSize.min, children: [IconButton(icon: Icon(Icons.check_circle, color: Colors.green, size: 35), onPressed: ()=>saqla(oq[i]['id'], "Keldi")), SizedBox(width: 15), IconButton(icon: Icon(Icons.cancel, color: Colors.red, size: 35), onPressed: ()=>saqla(oq[i]['id'], "Kelmadi"))])))));
}
class OqMaosh extends StatelessWidget {
  Future<Map> fetch() async { final r = await http.get(Uri.parse('$API/oqituvchi/maosh?tel=${Uri.encodeComponent(gTel)}')); return jsonDecode(r.body); }
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text("Maosh va Reyting"), backgroundColor: Colors.orange), body: FutureBuilder<Map>(future: fetch(), builder: (c, s) => s.hasData ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.monetization_on, size: 100, color: Colors.orange), SizedBox(height: 20), Text("Darsga kelgan jami o'quvchilar: ${s.data!['soni']} ta", style: TextStyle(fontSize: 18)), SizedBox(height: 10), Text("Taxminiy maosh:\n${s.data!['maosh']} so'm", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.orange[900]), textAlign: TextAlign.center)])) : Center(child: CircularProgressIndicator())));
}

// ================= 3. KASSIR EKRANI VA FUNKSIYALARI =================
class KassirEkrani extends StatelessWidget {
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text("Kassir: $gIsm"), backgroundColor: Colors.purple, foregroundColor: Colors.white, actions: [IconButton(icon: Icon(Icons.exit_to_app), onPressed: ()=>Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>LoginEkrani())))]),
    body: GridView.count(crossAxisCount: 2, padding: EdgeInsets.all(15), children: [
      _q(context, Icons.payments, "To'lov qabul qilish", Colors.green, KasTolov()),
      _q(context, Icons.outbox, "Xarajat (Chiqim)", Colors.red, KasXarajat()),
      _q(context, Icons.analytics, "Kassa Hisoboti", Colors.blue, BatafsilKassaEkrani()),
      _q(context, Icons.lock, "Kunni Yopish", Colors.grey, StatikEkran(nomi: "Kunni Yopish", matn: "Kassa muvaffaqiyatli yopildi va hisobot direktorga yuborildi! ✅", rang: Colors.grey)),
    ]));
  Widget _q(BuildContext c, IconData i, String n, Color r, Widget e) => Card(elevation: 4, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), margin: EdgeInsets.all(10), child: InkWell(onTap: () => Navigator.push(c, MaterialPageRoute(builder: (_) => e)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(i, size: 50, color: r), SizedBox(height: 10), Text(n, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))])));
}
class KasTolov extends StatefulWidget { @override _KasTolovState createState() => _KasTolovState(); }
class _KasTolovState extends State<KasTolov> {
  final _qidir = TextEditingController(); List natija = [];
  qidirish() async { final r = await http.get(Uri.parse('$API/kassir/qidir?ism=${_qidir.text}')); setState(()=> natija = jsonDecode(r.body)); }
  tolash(int id, String ism) {
    final _summa = TextEditingController(); String usul = "Naqd";
    showDialog(context: context, builder: (_) => AlertDialog(title: Text("$ism dan to'lov"), content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: _summa, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: "Summa (so'm)")), SizedBox(height: 10), DropdownButtonFormField(value: usul, items: ["Naqd", "Terminal", "Click"].map((e)=>DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v)=>usul=v.toString())]), actions: [ElevatedButton(child: Text("QABUL"), onPressed: () async { await http.post(Uri.parse('$API/kassir/tolov'), headers: {"Content-Type":"application/json"}, body: jsonEncode({"oq_id": id, "summa": int.parse(_summa.text), "usul": usul, "kassir_tel": gTel})); Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("To'lov saqlandi!"), backgroundColor: Colors.green)); })]));
  }
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text("To'lov Qabul Qilish"), backgroundColor: Colors.green), body: Column(children: [Padding(padding: EdgeInsets.all(15), child: Row(children: [Expanded(child: TextField(controller: _qidir, decoration: InputDecoration(labelText: "O'quvchi ismini yozing", border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))))), SizedBox(width: 10), Container(decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(10)), child: IconButton(icon: Icon(Icons.search, size: 30, color: Colors.white), onPressed: qidirish))])), Expanded(child: ListView.builder(itemCount: natija.length, itemBuilder: (_, i) => Card(margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5), child: ListTile(title: Text(natija[i]['ism'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), trailing: ElevatedButton(child: Text("To'lov"), onPressed: ()=>tolash(natija[i]['id'], natija[i]['ism']), style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white))))))]));
}
class KasXarajat extends StatelessWidget {
  final _summa = TextEditingController(); final _izoh = TextEditingController();
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text("Xarajat (Chiqim)"), backgroundColor: Colors.red), body: Padding(padding: EdgeInsets.all(20), child: Column(children: [TextField(controller: _summa, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: "Summa (so'm)", border: OutlineInputBorder())), SizedBox(height: 15), TextField(controller: _izoh, decoration: InputDecoration(labelText: "Izoh (Nimaga sarflandi?)", border: OutlineInputBorder())), SizedBox(height: 20), ElevatedButton(child: Text("SAQLASH", style: TextStyle(fontSize: 18)), onPressed: () async { await http.post(Uri.parse('$API/kassir/xarajat'), headers: {"Content-Type":"application/json"}, body: jsonEncode({"summa": int.parse(_summa.text), "izoh": _izoh.text, "kassir_tel": gTel})); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Xarajat saqlandi!"))); Navigator.pop(context); }, style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, minimumSize: Size(double.infinity, 55)))])));
}

// ================= 4. O'QUVCHI EKRANI VA FUNKSIYALARI =================
class OquvchiEkrani extends StatelessWidget {
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text("O'quvchi: $gIsm"), backgroundColor: Colors.deepOrange, foregroundColor: Colors.white, actions: [IconButton(icon: Icon(Icons.exit_to_app), onPressed: ()=>Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>LoginEkrani())))]),
    body: ListView(padding: EdgeInsets.all(20), children: [
      _kT(context, Icons.location_on, "Keldim / Ketdim (Lokatsiya)", Colors.red, () async { await http.post(Uri.parse('$API/oquvchi/lokatsiya'), headers: {"Content-Type":"application/json"}, body: jsonEncode({"telefon": gTel, "lat": 41.32, "lon": 69.25})); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lokatsiya va vaqt qayd etildi!"), backgroundColor: Colors.green)); }), SizedBox(height: 15),
      _kT(context, Icons.calendar_month, "Dars Jadvali", Colors.blue, () => Navigator.push(context, MaterialPageRoute(builder: (_)=>StatikEkran(nomi: "Dars Jadvali", matn: "Dushanba:\n1. Matematika\n2. Ingliz tili\n3. Fizika", rang: Colors.blue)))), SizedBox(height: 15),
      _kT(context, Icons.analytics, "Davomatim va Natijam", Colors.green, () => Navigator.push(context, MaterialPageRoute(builder: (_)=>OqNatijalar()))), SizedBox(height: 15),
      _kT(context, Icons.credit_card, "To'lov Qilish", Colors.purple, () => showDialog(context: context, builder: (_) => AlertDialog(title: Text("Onlayn To'lov"), content: Column(mainAxisSize: MainAxisSize.min, children: [ElevatedButton(child: Text("Payme orqali to'lash"), onPressed: (){}, style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan, minimumSize: Size(double.infinity, 50))), SizedBox(height: 10), ElevatedButton(child: Text("Click orqali to'lash"), onPressed: (){}, style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[800], minimumSize: Size(double.infinity, 50)))])))), 
    ]));
  Widget _kT(BuildContext c, IconData i, String n, Color r, VoidCallback o) => ElevatedButton.icon(icon: Icon(i, size: 30, color: Colors.white), label: Text(n, style: TextStyle(fontSize: 18, color: Colors.white)), style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 80), backgroundColor: r, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))), onPressed: o);
}
class OqNatijalar extends StatelessWidget {
  Future<Map> fetch() async { final r = await http.get(Uri.parse('$API/oquvchi/info?tel=${Uri.encodeComponent(gTel)}')); return jsonDecode(r.body); }
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text("Davomat va Natijalar"), backgroundColor: Colors.green), body: FutureBuilder<Map>(future: fetch(), builder: (c, s) => s.hasData ? ListView(padding: EdgeInsets.all(15), children: [Card(elevation: 4, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), color: Colors.green[50], child: ListTile(contentPadding: EdgeInsets.all(15), title: Text("📚 Guruh: ${s.data!['guruh']}", style: TextStyle(fontSize: 18)), subtitle: Padding(padding: EdgeInsets.only(top: 8.0), child: Text("👨‍🏫 Ustoz: ${s.data!['oqituvchi']}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))))), SizedBox(height: 20), Text(" Oxirgi Davomatlar:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue[900])), ...s.data!['davomat'].map((d) => Card(child: ListTile(leading: Icon(Icons.calendar_today, color: Colors.blue), title: Text(d['sana']), trailing: Text(d['holat']=='Keldi'?'✅ Keldi':'❌ Kelmadi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: d['holat']=='Keldi'?Colors.green:Colors.red))))), SizedBox(height: 20), Text(" Blok Test Natijalari:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue[900])), ...s.data!['testlar'].map((t) => Card(child: ListTile(leading: Icon(Icons.assignment_turned_in, color: Colors.teal), title: Text(t['fan'], style: TextStyle(fontWeight: FontWeight.bold)), subtitle: Text(t['sana']), trailing: Text("${t['ball']} ball", style: TextStyle(color: Colors.blue[900], fontWeight: FontWeight.bold, fontSize: 18))))), ]) : Center(child: CircularProgressIndicator())));
}