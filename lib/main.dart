import 'dart:async';
import 'package:material_design/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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

  final StreamController<String> _searchController =
      StreamController<String>.broadcast();

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

  Future<void> editKontak(int index) async {
    final hasil = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TambahKontakPage(
          kontak: items[index],
        ),
      ),
    );
    if (hasil != null) {
      setState(() {
        items[index] = hasil;
      });
    }
  }

  Future<void> hapusKontak(int index) async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Kontak'),
          content: Text(
            'Apakah Anda yakin ingin menghapus kontak '
            '${items[index].nama}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (konfirmasi == true) {
      setState(() {
        items.removeAt(index);
      });
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

              // child: StreamBuilder<String>(
              //   stream: _searchController.stream,
              //   builder: (context, snapshot) {
              //     String keyword = (snapshot.data ?? '').toLowerCase();

              //     List<Kontak> hasilFilter = items.where((k) {
              //       String nama = k.nama.toLowerCase();
              //       String kategori = (k.kategori ?? '').toLowerCase();

              //       return nama.contains(keyword) ||
              //           kategori.contains(keyword);
              //     }).toList();

              //     return daftarKontak(hasilFilter);
              //   },
              // ),
              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('kontak')
                      .snapshots(),
                  builder: (context, snapshot) {
                    // Loading
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    // Error
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Terjadi kesalahan: ${snapshot.error}',
                        ),
                      );
                    }

                    // Stream pencarian
                    return StreamBuilder<String>(
                      stream: _searchController.stream,
                      initialData: '',
                      builder: (context, searchSnapshot) {
                        final keyword =
                            (searchSnapshot.data ?? '').toLowerCase();

                        // Ambil data Firestore
                        final daftarKontakFirestore =
                            snapshot.data!.docs.map((doc) {
                          final data = doc.data();

                          return Kontak(
                            id: doc.id,
                            nama: data['nama'] ?? '',
                            email: data['email'] ?? '',
                            noHandphone: data['noHandphone'] ?? '',
                            kategori: data['kategori'],
                          );
                        }).toList();

                        // Filter
                        final hasilFilter =
                            daftarKontakFirestore.where((kontak) {
                          final nama = kontak.nama.toLowerCase();

                          final kategori =
                              (kontak.kategori ?? '').toLowerCase();

                          return nama.contains(keyword) ||
                              kategori.contains(keyword);
                        }).toList();

                        return daftarKontak(hasilFilter);
                      },
                    );
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
        return Card(
          margin: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
          elevation: 2,
          child: ListTile(
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
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    int posisiAsli = items.indexOf(daftar[index]);
                    editKontak(posisiAsli);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    int posisiAsli = items.indexOf(daftar[index]);
                    hapusKontak(posisiAsli);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// HALAMAN TAMBAH KONTAK
class TambahKontakPage extends StatefulWidget {
  final Kontak? kontak;
  const TambahKontakPage({
    super.key,
    this.kontak,
  });

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
  void initState() {
    super.initState();
    if (widget.kontak != null) {
      namaController.text = widget.kontak!.nama;
      emailController.text = widget.kontak!.email;
      noHandphoneController.text = widget.kontak!.noHandphone;
      kategoriController.text = widget.kontak!.kategori ?? '';
    }
  }

  @override
  void dispose() {
    namaController.dispose();
    emailController.dispose();
    noHandphoneController.dispose();
    kategoriController.dispose();
    super.dispose();
  }

  // FUNGSI SIMPAN KONTAK
  // void simpanKontak() {
  //   Kontak kontak = Kontak(
  //     nama: namaController.text,
  //     email: emailController.text,
  //     noHandphone: noHandphoneController.text,
  //     kategori:
  //         kategoriController.text.isEmpty ? null : kategoriController.text,
  //   );

  //   // Mengirim data kontak kembali ke halaman sebelumnya
  //   Navigator.pop(context, kontak);
  // }

  Future<void> simpanKontak() async {
    try {
      await FirebaseFirestore.instance.collection('kontak').add({
        'nama': namaController.text,
        'email': emailController.text,
        'noHandphone': noHandphoneController.text,
        'kategori':
            kategoriController.text.isEmpty ? null : kategoriController.text,
      });

      // Bersihkan form
      namaController.clear();
      emailController.clear();
      noHandphoneController.clear();
      kategoriController.clear();

      // Tampilkan SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data berhasil disimpan'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan kontak: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: Text(widget.kontak == null ? 'Tambah Kontak' : 'Edit Kontak'),
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
                child: Text(widget.kontak == null
                    ? 'Simpan Kontak'
                    : 'Simpan Perubahan'),
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
  String id;
  String nama;
  String email;
  String noHandphone;
  String? kategori;

  Kontak({
    this.id = '',
    required this.nama,
    required this.email,
    required this.noHandphone,
    this.kategori,
  });

  String get inisial => nama.isNotEmpty ? nama[0].toUpperCase() : '?';
}
