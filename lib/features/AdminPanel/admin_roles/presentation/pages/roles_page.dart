import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../presentation/pages/sidebar.dart';
import '../../application/admin_roles_controller.dart';
import '../../domain/entities/user_with_roles.dart';
import '../bloc/admin_roles_bloc.dart';
import '../bloc/admin_roles_event.dart';
import '../bloc/admin_roles_state.dart';

class RolesPage extends StatefulWidget {
  const RolesPage({super.key});

  @override
  State<RolesPage> createState() => _RolesPageState();
}

class _RolesPageState extends State<RolesPage> {
  String searchQuery = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.read<AdminRolesBloc>().add(LoadUsersWithRoles()); // ✅ aman di sini
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminRolesBloc, AdminRolesState>(
      builder: (context, state) {
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
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: switch (state) {
              AdminRolesLoading => const Center(child: CircularProgressIndicator()),
              AdminRolesError() => Center(child: Text(state.message)),
              AdminRolesLoaded() => _buildRoleSection(state.users),
              _ => const SizedBox(),
            },
          ),
        );
      },
    );
  }

  Widget _buildRoleSection(List<UserWithRoles> users) {
    final filtered = users
        .where((user) =>
            user.username.toLowerCase().contains(searchQuery.toLowerCase()) ||
            user.npm.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSearchBox(),
        const SizedBox(height: 16),
        _buildDataTable(filtered),
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

  Widget _buildDataTable(List<UserWithRoles> users) {
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
          const TableRow(
            decoration: BoxDecoration(color: Color(0xFFBEE3F8)),
            children: [
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
          ...users.map((user) => TableRow(
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
                            user.username,
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
                          user.roles.length,
                          (i) => Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: Chip(
                              label: Text(user.roles[i].name),
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
                      onPressed: () => _showEditDialog(user),
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

  void _showEditDialog(UserWithRoles user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Roles for ${user.username}'),
        content: const Text('Nanti muncul dropdown + checkbox roles di sini'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }
}