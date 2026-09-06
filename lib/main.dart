import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// MY APP
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Buku Kontak',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const DefaultTabController(
        length: 2,
        child: MyHomePage(),
      ),
    );
  }
}

// HALAMAN UTAMA
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Menyimpan data kontak
  List<Kontak> items = [];

  final StreamController<String> _searchController = StreamController<String>();

  @override
  void dispose() {
    _searchController.close();
    super.dispose();
  }

  // FUNGSI UNTUK MEMBUKA HALAMAN TAMBAH KONTAK
  Future<void> tambahKontak() async {
    final hasil = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TambahKontakPage(),
      ),
    );

    // Jika ada data kontak yang dikirim kembali
    if (hasil != null) {
      setState(() {
        items.add(hasil);
      });
      DefaultTabController.of(context).animateTo(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: const Text('BUKU KONTAK'),

        // TAB BAR
        bottom: const TabBar(
          tabs: [
            Tab(
              icon: Icon(Icons.account_circle),
              text: 'Kontak',
            ),
            Tab(
              icon: Icon(Icons.star),
              text: 'Favorit',
            ),
          ],
        ),
      ),

      // DRAWER
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'BUKU KONTAK',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),

            // MENU KONTAK
            ListTile(
              leading: const Icon(Icons.contact_page),
              title: const Text('Kontak'),
              onTap: () {
                DefaultTabController.of(context).animateTo(0);
                Navigator.pop(context);
              },
            ),

            // MENU TAMBAH KONTAK
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Tambah Kontak'),
              onTap: () {
                Navigator.pop(context);
                tambahKontak();
              },
            ),

            // MENU FAVORIT
            ListTile(
              leading: const Icon(Icons.star),
              title: const Text('Favorit'),
              onTap: () {
                DefaultTabController.of(context).animateTo(1);
                Navigator.pop(context);
              },
            ),

            // MENU TENTANG
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Tentang'),
              onTap: () {
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TentangPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),

      // TAB BAR VIEW
      body: TabBarView(
        children: [
          // TAB KONTAK
          Column(
            children: [
              // TEXT FIELD PENCARIAN
              Padding(
                padding: const EdgeInsets.all(10),
                child: TextField(
                  onChanged: (teks) {
                    _searchController.add(teks);
                  },
                  decoration: const InputDecoration(
                    labelText: 'Cari kontak...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),

              // HASIL PENCARIAN
              Expanded(
                child: StreamBuilder<String>(
                  stream: _searchController.stream,
                  builder: (context, snapshot) {
                    String keyword = (snapshot.data ?? '').toLowerCase();

                    List<Kontak> hasilFilter = items.where((k) {
                      String nama = k.nama.toLowerCase();
                      String kategori = (k.kategori ?? '').toLowerCase();

                      return nama.contains(keyword) ||
                          kategori.contains(keyword);
                    }).toList();

                    return daftarKontak(hasilFilter);
                  },
                ),
              ),
            ],
          ),

          // TAB FAVORIT
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Annisa Kusumastuti'),
            subtitle: const Text(
              'nisak@gmail.com\n'
              '0812345678901',
            ),
          ),
        ],
      ),

      // FLOATING ACTION BUTTON
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          tambahKontak();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // WIDGET DAFTAR KONTAK
  Widget daftarKontak(List<Kontak> daftar) {
    if (daftar.isEmpty) {
      return const Center(
        child: Text(
          'Belum ada kontak',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      itemCount: daftar.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: CircleAvatar(
            child: Text(daftar[index].inisial),
          ),
          title: Text(
            daftar[index].nama,
          ),
          subtitle: Text(
            '${daftar[index].email}\n'
            '${daftar[index].noHandphone}\n'
            '${daftar[index].kategori ?? "Tanpa kategori"}',
          ),
        );
      },
    );
  }
}

// HALAMAN TAMBAH KONTAK
class TambahKontakPage extends StatefulWidget {
  const TambahKontakPage({super.key});

  @override
  State<TambahKontakPage> createState() => _TambahKontakPageState();
}

class _TambahKontakPageState extends State<TambahKontakPage> {
  // Controller untuk mengambil input
  final TextEditingController namaController = TextEditingController();

  final TextEditingController emailController = TextEditingController();

  final TextEditingController noHandphoneController = TextEditingController();

  final TextEditingController kategoriController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    namaController.dispose();
    emailController.dispose();
    noHandphoneController.dispose();
    kategoriController.dispose();
    super.dispose();
  }

  // FUNGSI SIMPAN KONTAK
  void simpanKontak() {
    // Membuat objek kontak dari input
    Kontak kontak = Kontak(
      nama: namaController.text,
      email: emailController.text,
      noHandphone: noHandphoneController.text,
      kategori:
          kategoriController.text.isEmpty ? null : kategoriController.text,
    );

    // Mengirim data kontak kembali ke halaman sebelumnya
    Navigator.pop(context, kontak);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: const Text('Tambah Kontak'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // NAMA
              TextFormField(
                controller: namaController,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama tidak boleh kosong';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 15),

              // EMAIL
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email tidak boleh kosong';
                  }
                  if (!value.contains('@')) {
                    return 'Email harus menggunakan @';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 15),

              // NOMOR HANDPHONE
              TextFormField(
                controller: noHandphoneController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'No Handphone',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'No HP wajib diisi';
                  }

                  if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                    return 'No HP hanya boleh angka';
                  }

                  if (value.length < 10) {
                    return 'No HP minimal 10 digit';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 15),

              TextField(
                controller: kategoriController,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                ),
              ),

              const SizedBox(height: 20),

              // TOMBOL SIMPAN
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    simpanKontak();
                  }
                },
                child: const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// HALAMAN TENTANG
class TentangPage extends StatelessWidget {
  const TentangPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: const Text('Tentang'),
      ),
      body: const Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/images/profile.png'),
                ),
                const SizedBox(height: 20),
                Text(
                  'Annisa Kusumastuti',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  'XII RPL B',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                Text(
                  'SMK Negeri 5 Surakarta',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// CLASS KONTAK
class Kontak {
  String nama;
  String email;
  String noHandphone;
  String? kategori;

  Kontak({
    required this.nama,
    required this.email,
    required this.noHandphone,
    this.kategori,
  });
  String get inisial => nama.isNotEmpty ? nama[0].toUpperCase() : '?';
}
