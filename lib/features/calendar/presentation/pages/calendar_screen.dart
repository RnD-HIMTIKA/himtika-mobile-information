import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:himtika_mobile_information/features/calendar/domain/entities/workspace.dart';
import 'package:himtika_mobile_information/features/home/presentation/pages/home.dart';
import '../../../../core/injection_container.dart';
import '../bloc/workspace/workspace_bloc.dart';
import 'schedule_detail_screen.dart';
import '../../../auth/domain/entities/user.dart';
import '../../domain/entities/workspace_with_members.dart';

// ===========================================================================
// HALAMAN 1: CALENDAR SCREEN
// ===========================================================================
class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<WorkspaceBloc>()..add(LoadMyWorkspaces()),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: CircleAvatar(
            backgroundColor: Colors.transparent,
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: Image.asset(
                "src/features/login&register/images/arrow_back.png",
                color: const Color(0xFF31b7fe),
                width: 24,
                height: 24,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              },
            ),
          ),
        ),
        extendBodyBehindAppBar: true,
        body: const Stack(
          children: [
            _BackgroundContent(),
            _WorkspaceSheet(),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// WIDGET-WIDGET LOKAL
// ===========================================================================
class _BackgroundContent extends StatelessWidget {
  const _BackgroundContent();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF333C66), Color(0xFF2D365E)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        image: DecorationImage(
          image: AssetImage('src/features/calendar/images/pattern.png'),
          fit: BoxFit.cover,
          opacity: 0.5,
        ),
      ),
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: kToolbarHeight + MediaQuery.of(context).padding.top),
            const Text(
              'Plan Your Days, Own Your Time',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Easily create, manage, and share your schedule—stay organized and never miss a thing.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Image.asset('src/features/calendar/images/assets.png'),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkspaceSheet extends StatelessWidget {
  const _WorkspaceSheet();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.2,
      minChildSize: 0.2,
      maxChildSize: 0.9,
      builder: (BuildContext context, ScrollController scrollController) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          child: Container(
            color: Colors.white,
            child: BlocBuilder<WorkspaceBloc, WorkspaceState>(
              builder: (context, state) {
                if (state.status == WorkspaceStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.status == WorkspaceStatus.failure) {
                  return Center(child: Text('Gagal memuat data: ${state.errorMessage}'));
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final isExpanded = constraints.maxHeight > MediaQuery.of(context).size.height * 0.3;

                    return Stack(
                      children: [
                        CustomScrollView(
                          controller: scrollController,
                          slivers: [
                            SliverPersistentHeader(
                              pinned: true,
                              delegate: _StickyHeaderDelegate(
                                minHeight: 92,
                                maxHeight: 92,
                                child: Container(
                                  padding: const EdgeInsets.only(top: 12, bottom: 8),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 4,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      const Text(
                                        "Workspace Kamu",
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            if (isExpanded && state.workspaces.isEmpty)
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 40.0),
                                  child: Center(
                                    child: Text(
                                      "Kamu belum punya workspace",
                                      style: TextStyle(color: Colors.grey, fontSize: 16),
                                    ),
                                  ),
                                ),
                              )
                            else if (isExpanded)
                              SliverPadding(
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                sliver: SliverList.separated(
                                  itemCount: state.workspaces.length,
                                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                                  itemBuilder: (context, index) {
                                    return _WorkspaceCard(
                                      workspaceWithMembers: state.workspaces[index],
                                    );
                                  },
                                ),
                              ),
                            const SliverToBoxAdapter(child: SizedBox(height: 100)),
                          ],
                        ),
                        if (isExpanded)
                          Positioned(
                            bottom: 30,
                            left: 24,
                            right: 24,
                            child: Center(
                              child: FloatingActionButton(
                                onPressed: () => showDialog(
                                  context: context,
                                  builder: (dialogContext) {
                                    return BlocProvider.value(
                                      value: BlocProvider.of<WorkspaceBloc>(context),
                                      child: const _ModifyWorkspaceDialog(),
                                    );
                                  },
                                ),
                                backgroundColor: Colors.blue.shade600,
                                foregroundColor: Colors.white,
                                shape: const CircleBorder(),
                                elevation: 10,
                                child: const Icon(Icons.add, size: 32),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _StickyHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final bool pinned = shrinkOffset > 0 || overlapsContent;
    return Container(
      decoration: BoxDecoration(
        color: pinned ? Colors.white : Colors.transparent,
        boxShadow: pinned
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      alignment: Alignment.center,
      child: child,
    );
  }

  @override
  bool shouldRebuild(_StickyHeaderDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}

class _WorkspaceCard extends StatelessWidget {
  final WorkspaceWithMembers workspaceWithMembers;

  const _WorkspaceCard({
    required this.workspaceWithMembers,
  });

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return BlocProvider.value(
          value: context.read<WorkspaceBloc>(),
          child: _WorkspaceOptions(workspace: workspaceWithMembers.workspace),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final workspace = workspaceWithMembers.workspace;
    final members = workspaceWithMembers.members;

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            offset: const Offset(0, 4),
            blurRadius: 6,
            spreadRadius: 0,
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ScheduleDetailScreen(
                workspaceId: workspace.id,
                workspaceTitle: workspace.title,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      workspace.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () => _showOptions(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                workspace.description,
                style: const TextStyle(color: Colors.black54, fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              _buildMembersRow(members),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMembersRow(List<User> members) {
    if (members.isEmpty) {
      return const Text(
        "Hanya Anda di workspace ini",
        style: TextStyle(color: Colors.grey, fontSize: 12),
      );
    }

    const maxAvatars = 3;
    final displayedMembers = members.take(maxAvatars).toList();
    final remainingCount = members.length - maxAvatars;

    return Row(
      children: [
        SizedBox(
          width: (displayedMembers.length * 18.0),
          height: 24,
          child: Stack(
            children: List.generate(displayedMembers.length, (index) {
              final member = displayedMembers[index];
              return Positioned(
                left: (index * 14.0),
                child: CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 10,
                    backgroundImage: (member.profileUrl != null && member.profileUrl!.isNotEmpty)
                        ? NetworkImage(member.profileUrl!)
                        : null,
                    child: (member.profileUrl == null || member.profileUrl!.isEmpty)
                        ? const Icon(Icons.person, size: 12)
                        : null,
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            remainingCount > 0
                ? "dan ${remainingCount} lainnya"
                : "${members.length} kolaborator",
            style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _WorkspaceOptions extends StatelessWidget {
  final Workspace workspace;
  const _WorkspaceOptions({required this.workspace});

  void _showEditDialog(BuildContext context) {
    Navigator.of(context).pop();
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<WorkspaceBloc>(),
        child: _ModifyWorkspaceDialog(workspaceToEdit: workspace),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    // PERBAIKAN: Ambil referensi BLoC sebelum menampilkan dialog
    final bloc = context.read<WorkspaceBloc>();
    Navigator.of(context).pop(); // Tutup bottom sheet

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Workspace'),
        content: Text('Anda yakin ingin menghapus "${workspace.title}"? Semua event di dalamnya juga akan terhapus.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Batal')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              // Gunakan referensi BLoC yang sudah disimpan
              bloc.add(DeleteWorkspacePressed(workspace.id));
              Navigator.of(ctx).pop();
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Workspace'),
            onTap: () => _showEditDialog(context),
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: const Text('Hapus Workspace', style: TextStyle(color: Colors.red)),
            onTap: () => _showDeleteConfirmation(context),
          ),
        ],
      ),
    );
  }
}

class _ModifyWorkspaceDialog extends StatefulWidget {
  final Workspace? workspaceToEdit;
  const _ModifyWorkspaceDialog({this.workspaceToEdit});

  @override
  State<_ModifyWorkspaceDialog> createState() => _ModifyWorkspaceDialogState();
}

class _ModifyWorkspaceDialogState extends State<_ModifyWorkspaceDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool get isEditing => widget.workspaceToEdit != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _titleController.text = widget.workspaceToEdit!.title;
      _descriptionController.text = widget.workspaceToEdit!.description;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (isEditing) {
      context.read<WorkspaceBloc>().add(
            UpdateWorkspaceSubmitted(
              workspaceId: widget.workspaceToEdit!.id,
              title: _titleController.text,
              description: _descriptionController.text,
            ),
          );
    } else {
      context.read<WorkspaceBloc>().add(
            CreateWorkspaceSubmitted(
              title: _titleController.text,
              description: _descriptionController.text,
            ),
          );
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.all(24),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(isEditing ? 'Edit Workspace' : 'Buat Workspace', style: const TextStyle(fontWeight: FontWeight.bold)),
          IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Judul', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              hintText: 'Masukkan Judul Workspace',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Deskripsi', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          TextField(
            controller: _descriptionController,
            decoration: InputDecoration(
              hintText: 'Masukkan Deskripsi Workspace',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      actions: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(isEditing ? 'Simpan Perubahan' : 'Buat Workspace'),
          ),
        ),
      ],
    );
  }
}