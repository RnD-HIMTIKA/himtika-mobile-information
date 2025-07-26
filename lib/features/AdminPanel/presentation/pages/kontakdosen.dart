import 'package:flutter/material.dart';
import 'package:himtika_mobile_information/features/AdminPanel/presentation/pages/sidebar.dart';

class Kontakdosen extends StatefulWidget {
  const Kontakdosen({super.key});

  @override
  State<Kontakdosen> createState() => _KontakdosenState();
}

class _KontakdosenState extends State<Kontakdosen> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _nipController = TextEditingController();
  final TextEditingController _nidnController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _waController = TextEditingController();

  String? _mataKuliah;
  final List<String> _listMatkul = [
    'Algoritma',
    'Pemrograman',
    'Basis Data',
    'Jaringan Komputer',
    'Kecerdasan Buatan',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Sidebar(),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0175C8),
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text('Kontak Dosen'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.account_circle, size: 32),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(height: 1, thickness: 1, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tambah Dosen',
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFc8ffe0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildTextField('Nama Dosen', 'Dr. Ade Maman Suherman', _namaController),
                  _buildTextField('NIP', '0192', _nipController),
                  _buildTextField('NIDN', '23019', _nidnController),
                  _buildFilePicker(),
                  _buildTextField('Email', 'nama@staff.unsika.ac.id', _emailController),
                  _buildTextField('Whatsapp', '0838..', _waController),
                  _buildDropdown(),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0175C8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () {},
                      child: const Text('Simpan', style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFF0175C8),
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildFilePicker() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Foto Profil',
                floatingLabelBehavior: FloatingLabelBehavior.always,
                hintText: 'Choose File',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: () {
              // handle upload action
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: 'Mengajar',
          floatingLabelBehavior: FloatingLabelBehavior.always,
          hintText: 'Pilih Mata Kuliah',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        value: _mataKuliah,
        items: _listMatkul.map((matkul) {
          return DropdownMenuItem(
            value: matkul,
            child: Text(matkul),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _mataKuliah = value;
          });
        },
      ),
    );
  }
}
