// ignore_for_file: no_logic_in_create_state

import 'dart:html';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as developer;

class umkmModel {
  String id;
  String nama;
  String jenis;

  umkmModel({required this.id, required this.nama, required this.jenis});
}

class umkmCubit extends Cubit<List<umkmModel>> {
  String url = "http://178.128.17.76:8000/daftar_umkm";

  umkmCubit() : super([]);

  void setFromJson(Map<String, dynamic> json) {
    List data = json['data'];

    List<umkmModel> data1 = data
        .map((e) => umkmModel(id: e['id'], nama: e['nama'], jenis: e['jenis']))
        .toList();

    emit(data1);
  }

  void fetchData() async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      // success
      setFromJson(jsonDecode(response.body));
    } else {
      throw Exception('gagal load');
    }
  }
}

class detailModel {
  String id;
  String nama;
  String jenis;
  String omzet_bulan;
  String lama_usaha;
  String member_sejak;
  String jumlah_pinjaman_sukses;

  detailModel(
      {required this.id,
      required this.nama,
      required this.jenis,
      required this.omzet_bulan,
      required this.lama_usaha,
      required this.member_sejak,
      required this.jumlah_pinjaman_sukses});

  factory detailModel.fromJson(Map<String, dynamic> json) {
    return detailModel(
      id: json['id'],
      nama: json['nama'],
      jenis: json['jenis'],
      omzet_bulan: json['omzet_bulan'],
      lama_usaha: json['lama_usaha'],
      member_sejak: json['member_sejak'],
      jumlah_pinjaman_sukses: json['jumlah_pinjam_suskses'],
    );
  }
}

class detailCubit extends Cubit<detailModel> {
  String url = "http://178.128.17.76:8000/detail_umkm/";

  detailCubit()
      : super(detailModel(
            id: '',
            nama: '',
            jenis: '',
            omzet_bulan: '',
            lama_usaha: '',
            member_sejak: '',
            jumlah_pinjaman_sukses: ''));

  void setFromJson(Map<String, dynamic> json) {
    String id = json['id'];
    String nama = json['nama'];
    String jenis = json['jenis'];
    String omzet_bulan = json['omzet_bulan'];
    String lama_usaha = json['lama_usaha'];
    String member_sejak = json['member_sejak'];
    String jumlah_pinjaman_sukses = json['jumlah_pinjam_suskses'];
    emit(detailModel(
        id: id,
        nama: nama,
        jenis: jenis,
        omzet_bulan: omzet_bulan,
        lama_usaha: lama_usaha,
        member_sejak: member_sejak,
        jumlah_pinjaman_sukses: jumlah_pinjaman_sukses));
  }

  void fetchData(String id) async {
    final response = await http.get(Uri.parse(url + id));
    if (response.statusCode == 200) {
      // success
      setFromJson(jsonDecode(response.body));
    } else {
      throw Exception('gagal load');
    }
  }
}

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocProvider(
        create: (_) => umkmCubit(),
        child: const HalamanUtama(),
      ),
      routes: {
        '/detail': (context) =>
            HalamanDetail(idUmkm: ModalRoute.of(context)!.settings.arguments as String),
      },
    );
  }
}

class HalamanUtama extends StatefulWidget {
  const HalamanUtama({Key? key}) : super(key: key);

  @override
  State<HalamanUtama> createState() => _HalamanUtamaState();
}

class _HalamanUtamaState extends State<HalamanUtama> {
  late umkmCubit _umkmCubit;

  @override
  void initState() {
    _umkmCubit = context.read<umkmCubit>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar UMKM'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(25),
              child: Text(
                  "2102165, Mia Karisma Haq ; 2100543, Muhammad Daffa Yusuf Fadhilah; Saya berjanji tidak akan berbuat curang atau membatu orang lain berbuat curang"),
            ),
            ElevatedButton(
              onPressed: () async {
                _umkmCubit.fetchData();
              },
              child: const Text('Reload Daftar UMKM'),
            ),
            const SizedBox(height: 16),
            BlocBuilder<umkmCubit, List<umkmModel>>(
              builder: (context, listUmkm) {
                return Flexible(
                  child: ListView.builder(
                    itemCount: listUmkm.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: Column(
                          children: [
                            ListTile(
                              onTap: () {
                                Navigator.of(context).pushNamed('/detail',
                                    arguments: listUmkm[index].id);
                              },
                              leading: Image.network(
                                  'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl-2.jpg'),
                              title: Text(listUmkm[index].nama),
                              subtitle: Text(listUmkm[index].jenis),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class HalamanDetail extends StatelessWidget {
  const HalamanDetail({Key? key, required this.idUmkm}) : super(key: key);

  final String idUmkm;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail UMKM'),
      ),
      body: Center(
        child: FutureBuilder<detailModel>(
          future: _fetchData(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final detailUmkm = snapshot.data!;
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Text('ID: ${detailUmkm.id}'),
                  Text('Nama: ${detailUmkm.nama}'),
                  Text('Detil: ${detailUmkm.jenis}'),
                  Text('Member Sejak: ${detailUmkm.member_sejak}'),
                  Text('Omzet per bulan: ${detailUmkm.omzet_bulan}'),
                  Text('Lama usaha: ${detailUmkm.lama_usaha}'),
                  Text('Jumlah pinjaman sukses: ${detailUmkm.jumlah_pinjaman_sukses}'),
                ],
              );
            } else if (snapshot.hasError) {
              return Text('Terjadi kesalahan saat memuat data');
            } else {
              return const CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }

  Future<detailModel> _fetchData() async {
    final url = 'http://178.128.17.76:8000/detil_umkm/$idUmkm';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return detailModel.fromJson(json);
    } else {
      throw Exception('Gagal memuat data');
    }
  }
}
