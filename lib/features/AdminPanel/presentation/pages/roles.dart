import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:himtika_mobile_information/core/injection_container.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/entities/admin_user.dart';
import 'package:himtika_mobile_information/features/AdminPanel/presentation/bloc/adminpanel_bloc.dart';
import 'package:himtika_mobile_information/features/AdminPanel/presentation/bloc/adminpanel_state.dart';
import 'package:himtika_mobile_information/features/AdminPanel/presentation/bloc/roles_management/roles_management_bloc.dart';
import 'package:himtika_mobile_information/features/AdminPanel/presentation/bloc/roles_management/roles_management_event.dart';
import 'package:himtika_mobile_information/features/AdminPanel/presentation/bloc/roles_management/roles_management_state.dart';
import 'package:himtika_mobile_information/features/roles/domain/entities/role.dart';
import 'sidebar.dart';

class RolesPage extends StatelessWidget {
  const RolesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<RolesManagementBloc>()..add(const SearchUsersChanged('')),
      child: const _RolesView(),
    );
  }
}

class _RolesView extends StatefulWidget {
  const _RolesView();

  @override
  State<_RolesView> createState() => _RolesViewState();
}

class _RolesViewState extends State<_RolesView> {
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<RolesManagementBloc>().add(SearchUsersChanged(query));
    });
  }

  void _showEditRolesDialog(AdminUser user, RolesManagementState state, bool isGeneral) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: BlocProvider.of<RolesManagementBloc>(context),
          child: _EditRolesDialog(
            user: user,
            state: state,
            isGeneralScope: isGeneral,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final adminState = context.watch<AdminPanelBloc>().state;
    final roles = adminState is AdminPanelLoaded ? adminState.currentUserRoles : [];
    final isRnD = roles.any((r) => r.name == 'RnD');

    return Scaffold(
      backgroundColor: const Color(0xFF0175C8),
      drawer: const Sidebar(),
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text('Kelola Roles'),
        centerTitle: true,
        backgroundColor: const Color(0xFF0175C8),
        actions: [
          // Widget Profile Picture Dinamis
          BlocBuilder<AdminPanelBloc, AdminPanelState>(
            builder: (context, state) {
              String? profileUrl;
              if (state is AdminPanelLoaded) {
                profileUrl = state.dashboardInfo.profilePictureUrl;
              }
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.white,
                  backgroundImage:
                      profileUrl != null ? NetworkImage(profileUrl) : null,
                  child: profileUrl == null
                      ? const Icon(Icons.account_circle,
                          size: 32, color: Colors.grey)
                      : null,
                ),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<RolesManagementBloc, RolesManagementState>(
        listener: (context, state) {
          if (state.status == RolesManagementStatus.failure &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRoleSection(
                  'HIMA Roles',
                  state,
                  (user) => _showEditRolesDialog(user, state, false),
                ),
                if (isRnD) ...[
                  const SizedBox(height: 24),
                  _buildRoleSection(
                    'General Roles',
                    state,
                    (user) => _showEditRolesDialog(user, state, true),
                  ),
                ]
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRoleSection(String title, RolesManagementState state,
      Function(AdminUser) onEdit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
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
              if (state.status == RolesManagementStatus.loading)
                const Center(child: CircularProgressIndicator())
              else
                _buildDataTable(state.users, onEdit),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBox() {
    return TextField(
      onChanged: _onSearchChanged,
      decoration: InputDecoration(
        hintText: 'Cari Nama, Username, NPM, atau Email...',
        fillColor: Colors.white,
        filled: true,
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildDataTable(List<AdminUser> users, Function(AdminUser) onEdit) {
    if (users.isEmpty) {
      return const Center(
          child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Text('Pengguna tidak ditemukan.'),
      ));
    }
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        border: TableBorder.all(color: Colors.black.withOpacity(0.3)),
        columnWidths: const {
          0: FixedColumnWidth(180),
          1: FixedColumnWidth(350),
          2: FixedColumnWidth(100),
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          _buildHeaderRow(),
          ...users.map((user) => _buildDataRow(user, onEdit)),
        ],
      ),
    );
  }

  TableRow _buildHeaderRow() {
    return TableRow(
      decoration: const BoxDecoration(color: Color(0xFFBEE3F8)),
      children: const [
        _TableHeader('Username'),
        _TableHeader('Roles'),
        _TableHeader('Action'),
      ],
    );
  }

  TableRow _buildDataRow(AdminUser user, Function(AdminUser) onEdit) {
    return TableRow(
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
                child: Text(user.username, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Wrap(
            spacing: 6.0,
            runSpacing: 4.0,
            children: (user.roles)
                .map((role) => Chip(
                      label:
                          Text(role.name, style: const TextStyle(fontSize: 10)),
                      backgroundColor: role.groupName == 'Pengurus'
                          ? Colors.pink.shade100
                          : Colors.green.shade100,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 2),
                    ))
                .toList(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: ElevatedButton(
            onPressed: () => onEdit(user),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Edit', style: TextStyle(fontSize: 12)),
          ),
        ),
      ],
    );
  }
}

class _TableHeader extends StatelessWidget {
  final String text;
  const _TableHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _EditRolesDialog extends StatefulWidget {
  final AdminUser user;
  final RolesManagementState state;
  final bool isGeneralScope;

  const _EditRolesDialog(
      {required this.user,
      required this.state,
      required this.isGeneralScope});

  @override
  State<_EditRolesDialog> createState() => _EditRolesDialogState();
}

class _EditRolesDialogState extends State<_EditRolesDialog> {
  late Set<String> _selectedRoleIds;

  @override
  void initState() {
    super.initState();
    _selectedRoleIds = widget.user.roles.map((r) => r.id).toSet();
    if (widget.isGeneralScope && widget.state.allGroupedRoles.isEmpty) {
      context.read<RolesManagementBloc>().add(const LoadAllGroupedRoles());
    }
  }

  void _onSimpanPressed() {
    context.read<RolesManagementBloc>().add(UpdateUserRolesSubmitted(
        widget.user.userId, _selectedRoleIds.toList()));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text('Edit Role untuk ${widget.user.username}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      content: SizedBox(
        width: double.maxFinite,
        child: widget.isGeneralScope
            ? _buildGeneralRolesContent()
            : _buildHimaRolesContent(),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal')),
        ElevatedButton(
            onPressed: _onSimpanPressed, child: const Text('Simpan')),
      ],
    );
  }

  Widget _buildHimaRolesContent() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: widget.state.assignableRoles.length,
      itemBuilder: (context, index) {
        final role = widget.state.assignableRoles[index];
        return SwitchListTile(
          title: Text(role.name),
          value: _selectedRoleIds.contains(role.id),
          onChanged: (value) => setState(() {
            if (value) _selectedRoleIds.add(role.id);
            else _selectedRoleIds.remove(role.id);
          }),
        );
      },
    );
  }

  Widget _buildGeneralRolesContent() {
    final groupedRoles = widget.state.allGroupedRoles;
    if (groupedRoles.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    final groupNames = groupedRoles.keys.toList();

    return ListView.builder(
      shrinkWrap: true,
      itemCount: groupNames.length,
      itemBuilder: (context, index) {
        final groupName = groupNames[index];
        final rolesInGroup = groupedRoles[groupName]!;
        return ExpansionTile(
          title: Text(groupName, style: const TextStyle(fontWeight: FontWeight.bold)),
          children: rolesInGroup.map((role) {
            return SwitchListTile(
              title: Text(role.name),
              value: _selectedRoleIds.contains(role.id),
              onChanged: (value) => setState(() {
                if (value) _selectedRoleIds.add(role.id);
                else _selectedRoleIds.remove(role.id);
              }),
            );
          }).toList(),
        );
      },
    );
  }
}