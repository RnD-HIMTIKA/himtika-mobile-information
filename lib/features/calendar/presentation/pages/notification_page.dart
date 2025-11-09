import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:himtika_mobile_information/core/injection_container.dart';
import 'package:intl/intl.dart';
import '../bloc/invitation/invitation_bloc.dart';
import '../../domain/entities/invitation.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pusat Notifikasi'),
        backgroundColor: const Color(0xFF0175C8),
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<InvitationBloc, InvitationState>(
        builder: (context, state) {
          if (state.status == InvitationStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == InvitationStatus.failure) {
            return Center(
                child: Text('Gagal memuat notifikasi: ${state.errorMessage}'));
          }
          // HAPUS logic 'if (state.invitations.isEmpty)' dari sini

          // --- PERBAIKAN DIMULAI DI SINI ---
          // Langsung return RefreshIndicator
          return RefreshIndicator(
            onRefresh: () async {
              context.read<InvitationBloc>().add(LoadMyInvitations());
            },
            // Tentukan child berdasarkan state.invitations.isEmpty
            child: state.invitations.isEmpty
                // JIKA KOSONG: Tampilkan pesan di dalam ListView agar tetap bisa di-refresh
                ? LayoutBuilder(
                    // Gunakan LayoutBuilder untuk mendapatkan tinggi
                    builder: (context, constraints) {
                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16.0),
                            height: constraints
                                .maxHeight, // Set tinggi agar Center bekerja
                            child: const Center(
                              child: Text(
                                'Tidak ada notifikasi baru.',
                                style:
                                    TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  )
                // JIKA ADA DATA: Tampilkan ListView.separated seperti sebelumnya
                : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16.0),
                    itemCount: state.invitations.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final invitation = state.invitations[index];
                      return _InvitationCard(invitation: invitation);
                    },
                  ),
          );
          // --- AKHIR PERBAIKAN ---
        },
      ),
    );
  }
}

class _InvitationCard extends StatelessWidget {
  final Invitation invitation;
  const _InvitationCard({required this.invitation});

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        DateFormat('d MMMM yyyy, HH:mm').format(invitation.createdAt);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFDBF6BF), Color(0xFFDBF6BF)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  // PERBAIKAN DI SINI: Ganti Image.asset menjadi SvgPicture.asset
                  child: SvgPicture.asset(
                    "src/features/home/icons/hiagenda.svg",
                    width: 24,
                    height: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Undangan Workspace',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Dari: ${invitation.inviterName}',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Text.rich(
              TextSpan(
                style: const TextStyle(fontSize: 14, color: Colors.black87),
                children: [
                  const TextSpan(
                      text: 'Anda diundang untuk bergabung ke workspace '),
                  TextSpan(
                    text: '"${invitation.workspaceTitle}"',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(text: ' sebagai '),
                  TextSpan(
                    text: invitation.roleToGrant,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(text: '.'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () {
                    context
                        .read<InvitationBloc>()
                        .add(DeclineInvitationPressed(invitation.id));
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                  child: const Text('Tolak'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    context
                        .read<InvitationBloc>()
                        .add(AcceptInvitationByIdPressed(invitation.id));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Terima'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
