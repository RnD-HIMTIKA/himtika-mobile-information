import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/adminpanel_bloc.dart';
import '../bloc/adminpanel_event.dart';
import '../bloc/adminpanel_state.dart';
import 'sidebar.dart';

class RolesPage extends StatefulWidget {
  const RolesPage({super.key});

  @override
  State<RolesPage> createState() => _RolesPageState();
}

class _RolesPageState extends State<RolesPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();

    // Panggil event ke bloc
    context.read<AdminPanelBloc>().add(LoadAdminPanel());

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String searchQuery = '';

  // Dummy data
  final List<Map<String, dynamic>> dummyRoles = List.generate(5, (index) {
    final usernames = ['Mishiee', 'Adriane', 'Pierro', 'Panjul', 'Menrey'];
    final roleGroups = [
      ['Angkatan 23', 'Kelas E'],
      ['Angkatan 24', 'Kelas F', 'Sekretaris', 'Sekpel'],
      ['Angkatan 24', 'Kelas A'],
      ['Angkatan 23', 'Kelas B'],
    ];

    return {
      'username': usernames[index % usernames.length],
      'roles': roleGroups[index % roleGroups.length],
    };
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminPanelBloc, AdminPanelState>(
      builder: (context, state) {
        // Hanya trigger state meski belum digunakan
        return Scaffold(
          backgroundColor: const Color(0xFF0175C8),
          drawer: const Sidebar(),
          appBar: AppBar(
            foregroundColor: Colors.white,
            title: const Text('Roles'),
            centerTitle: true,
            backgroundColor: const Color(0xFF0175C8),
            actions: const [
              Padding(
                padding: EdgeInsets.only(right: 16),
                child: Icon(Icons.account_circle, size: 32),
              )
            ],
            bottom: const PreferredSize(
              preferredSize: Size.fromHeight(1.0),
              child: Divider(height: 1, thickness: 1, color: Colors.white),
            ),
          ),
          body: FadeTransition(
            opacity: _fade,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildRoleSection('Hima Roles'),
                  const SizedBox(height: 24),
                  _buildRoleSection('General Roles'),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRoleSection(String title) {
    final filtered = dummyRoles
        .where((item) => item['username']
            .toString()
            .toLowerCase()
            .contains(searchQuery.toLowerCase()))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFC8FFE0),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildSearchBox(),
              const SizedBox(height: 16),
              _buildDataTable(filtered),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBox() {
    return TextField(
      onChanged: (value) => setState(() => searchQuery = value),
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintText: 'Search',
        fillColor: Colors.white,
        filled: true,
        prefixIcon: const Icon(Icons.search),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildDataTable(List<Map<String, dynamic>> data) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        border: TableBorder.all(color: Colors.black),
        columnWidths: const {
          0: FixedColumnWidth(180),
          1: FixedColumnWidth(350),
          2: FixedColumnWidth(140),
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          TableRow(
            decoration: const BoxDecoration(color: Color(0xFFBEE3F8)),
            children: const [
              Padding(
                padding: EdgeInsets.all(12),
                child: Text('Username', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              ),
              Padding(
                padding: EdgeInsets.all(12),
                child: Text('Roles', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              ),
              Padding(
                padding: EdgeInsets.all(12),
                child: Text('Action', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              ),
            ],
          ),
          ...data.map((item) => TableRow(
                decoration: const BoxDecoration(color: Color(0xFFD2F8D2)),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.black26,
                          child: Icon(Icons.person, size: 14, color: Colors.white),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item['username'],
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(
                          (item['roles'] as List).length,
                          (i) => Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: Chip(
                              label: Text(item['roles'][i]),
                              backgroundColor: i.isEven
                                  ? Colors.pink.shade100
                                  : Colors.green.shade100,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: ElevatedButton.icon(
                      onPressed: () => _showEditUsernameDialog(item),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      ),
                      icon: const Icon(Icons.edit, size: 14),
                      label: const Text('Edit', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                ],
              )),
        ],
      ),
    );
  }

  void _showEditUsernameDialog(Map<String, dynamic> user) {
    final controller = TextEditingController(text: user['username']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Username'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'New Username'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                user['username'] = controller.text;
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
