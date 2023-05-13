import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as developer;

class UmkmModel {
  String id;
  String nama;
  String jenis;

  UmkmModel({required this.id, required this.nama, required this.jenis});

  factory UmkmModel.fromJson(Map<String, dynamic> json) {
    return UmkmModel(
      id: json['id'],
      nama: json['nama'],
      jenis: json['jenis'],
    );
  }
}

class DetailUmkmModel {
  String id;
  String nama;
  String jenis;
  String deskripsi;
  String alamat;
  String noTelepon;

  DetailUmkmModel({
    required this.id,
    required this.nama,
    required this.jenis,
    required this.deskripsi,
    required this.alamat,
    required this.noTelepon,
  });

  factory DetailUmkmModel.fromJson(Map<String, dynamic> json) {
    return DetailUmkmModel(
      id: json['id'],
      nama: json['nama'],
      jenis: json['jenis'],
      deskripsi: json['deskripsi'],
      alamat: json['alamat'],
      noTelepon: json['no_telepon'],
    );
  }
}

class UmkmCubit extends Cubit<List<UmkmModel>> {
  String url = "http://178.128.17.76:8000/daftar_umkm";

  UmkmCubit() : super([]);

  void setFromJson(Map<String, dynamic> json) {
    List data = json['data'];

    List<UmkmModel> data1 = data.map((e) => UmkmModel.fromJson(e)).toList();

    emit(data1);
  }

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      // success
      setFromJson(jsonDecode(response.body));
    } else {
      throw Exception('gagal load');
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocProvider(
        create: (_) => UmkmCubit(),
        child: const HalamanUtama(),
      ),
      routes: {
        '/detail': (context) => HalamanDetail(
            idUmkm: ModalRoute.of(context)!.settings.arguments as String),
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
  late UmkmCubit _umkmCubit;

  @override
  void initState() {
    _umkmCubit = context.read<UmkmCubit>();
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
                await _umkmCubit.fetchData();
              },
              child: const Text('Reload Daftar UMKM'),
            ),
            const SizedBox(height: 16),
            BlocBuilder<UmkmCubit, List<UmkmModel>>(
              builder: (context, listUmkm) {
                return Flexible(
                  child: ListView.builder(
                    itemCount: listUmkm.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                          onTap: () {
                            Navigator.of(context).pushNamed('/detail',
                                arguments: listUmkm[index].id);
                          },
                          leading: Image.network(
                                  'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl-2.jpg'),
                          title: Text(listUmkm[index].nama),
                          subtitle: Text(listUmkm[index].jenis),
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
        child: FutureBuilder<DetailUmkmModel>(
          future: _fetchData(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final detailUmkm = snapshot.data!;
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('ID: ${detailUmkm.id}'),
                  Text('Nama: ${detailUmkm.nama}'),
                  Text('Jenis: ${detailUmkm.jenis}'),
                  Text('Deskripsi: ${detailUmkm.deskripsi}'),
                  Text('Alamat: ${detailUmkm.alamat}'),
                  Text('No. Telepon: ${detailUmkm.noTelepon}'),
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

  Future<DetailUmkmModel> _fetchData() async {
    final url = 'http://178.128.17.76:8000/detil_umkm/$idUmkm';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return DetailUmkmModel.fromJson(json);
    } else {
      throw Exception('Gagal memuat data');
    }
  }
}
