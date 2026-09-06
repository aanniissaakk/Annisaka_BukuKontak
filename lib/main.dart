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
          daftarKontak(),

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
  Widget daftarKontak() {
    if (items.isEmpty) {
      return const Center(
        child: Text(
          'Belum ada kontak',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: const Icon(Icons.person),
          title: Text(
            items[index].nama,
          ),
          subtitle: Text(
            '${items[index].email}\n'
            '${items[index].noHandphone}',
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

  @override
  void dispose() {
    namaController.dispose();
    emailController.dispose();
    noHandphoneController.dispose();
    super.dispose();
  }

  // FUNGSI SIMPAN KONTAK
  void simpanKontak() {
    // Membuat objek kontak dari input
    Kontak kontak = Kontak(
      nama: namaController.text,
      email: emailController.text,
      noHandphone: noHandphoneController.text,
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
        child: Column(
          children: [
            // NAMA
            TextField(
              controller: namaController,
              decoration: const InputDecoration(
                labelText: 'Nama Lengkap',
              ),
            ),

            const SizedBox(height: 15),

            // EMAIL
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
            ),

            const SizedBox(height: 15),

            // NOMOR HANDPHONE
            TextField(
              controller: noHandphoneController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'No Handphone',
              ),
            ),

            const SizedBox(height: 20),

            // TOMBOL SIMPAN
            ElevatedButton(
              onPressed: () {
                simpanKontak();
              },
              child: const Text('Simpan'),
            ),
          ],
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

  Kontak({
    required this.nama,
    required this.email,
    required this.noHandphone,
  });
}
