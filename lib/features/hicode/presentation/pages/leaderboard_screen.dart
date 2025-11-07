import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:himtika_mobile_information/features/hicode/presentation/bloc/leaderboard/leaderboard_bloc.dart';
import '../../domain/entities/leaderboard_entry.dart';
import 'package:himtika_mobile_information/core/injection_container.dart';
import 'package:himtika_mobile_information/core/helpers/image_optimizer.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // Perhatikan: Inject GetLeaderboard ke Bloc
      create: (context) => sl<LeaderboardBloc>()..add(FetchLeaderboard()),
      child: Scaffold(
        backgroundColor: Colors.blue,
        body: SafeArea(
          top: false,
          child: Stack(
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: 1.0,
                  child: Image.asset(
                    'src/features/hicode/rank/pattern_rank.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              BlocConsumer<LeaderboardBloc, LeaderboardState>(
                // Ganti ke BlocConsumer
                listener: (context, state) {
                  if (state.status == LeaderboardStatus.failure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            state.errorMessage ?? 'Gagal memuat leaderboard.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  // Tampilkan loading di tengah jika data awal belum ada
                  if (state.status == LeaderboardStatus.loading &&
                      state.users.isEmpty) {
                    return const Center(
                        child: CircularProgressIndicator(color: Colors.white));
                  }
                  // Tampilkan pesan jika data kosong setelah load
                  if (state.status == LeaderboardStatus.success &&
                      state.users.isEmpty) {
                    return Column(
                      // Bungkus dalam Column agar bisa menempatkan TopBar dll.
                      children: [
                        const _TopBar(),
                        _FilterButtons(selectedFilter: state.selectedFilter),
                        const Expanded(
                          child: Center(
                            child: Text(
                              'Belum ada data peringkat untuk filter ini.', // Pesan lebih jelas
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  // Ambil data top 3 dan lainnya dari state.users (List<LeaderboardEntry>)
                  final topThree = state.users.length > 2
                      ? state.users.sublist(0, 3)
                      : state.users;
                  final others =
                      state.users.length > 3 ? state.users.sublist(3) : [];

                  return Column(
                    children: [
                      // 1. Bagian Statis (Tidak Berubah)
                      const _TopBar(),
                      _FilterButtons(selectedFilter: state.selectedFilter),
                      const SizedBox(height: 24),
                      _Podium(topThree: topThree),

                      // 2. Bagian Scrollable (Sekarang menggunakan Expanded)
                      Expanded(
                        child: _UserListSection(
                          users: others.cast<LeaderboardEntry>(),
                          onRefresh: () async {
                            context
                                .read<LeaderboardBloc>()
                                .add(RefreshLeaderboard());
                          },
                        ),
                      ),
                    ],
                  );
                  // --- AKHIR STRUKTUR UI BARU ---
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//==================================================================
// WIDGET-WIDGET KOMPONEN UTAMA
//==================================================================

class _TopBar extends StatelessWidget {
  const _TopBar();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 8,
        right: 8,
        bottom: 8,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Image.asset(
              'src/features/hicode/icon/kembali.png', // Sesuaikan path
              width: 32,
              height: 32,
              color: Colors.white,
            ),
          ),
          const Expanded(
            child: Text('Leaderboard',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ),
          const SizedBox(width: 48), // Placeholder
        ],
      ),
    );
  }
}

class _FilterButtons extends StatelessWidget {
  final LeaderboardFilter selectedFilter;
  const _FilterButtons({required this.selectedFilter});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Expanded(
            child: _FilterButton(
              text: 'All Time',
              isSelected: selectedFilter == LeaderboardFilter.allTime,
              onPressed: () {
                context.read<LeaderboardBloc>().add(
                    const FilterChanged(filter: LeaderboardFilter.allTime));
              },
            ),
          ),
          Expanded(
            child: _FilterButton(
              text: 'Weekly',
              isSelected: selectedFilter == LeaderboardFilter.weekly,
              onPressed: () {
                context
                    .read<LeaderboardBloc>()
                    .add(const FilterChanged(filter: LeaderboardFilter.weekly));
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Podium extends StatelessWidget {
  final List<LeaderboardEntry> topThree;
  const _Podium({required this.topThree});

  @override
  Widget build(BuildContext context) {
    // Tetap siapkan placeholder meskipun data kurang dari 3
    final LeaderboardEntry? rank2 = topThree.length > 1 ? topThree[1] : null;
    final LeaderboardEntry? rank1 = topThree.isNotEmpty ? topThree[0] : null;
    final LeaderboardEntry? rank3 = topThree.length > 2 ? topThree[2] : null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Gunakan _PodiumPlace dengan data atau null (untuk placeholder)
        _PodiumPlace(user: rank2, rank: 2), // Kirim null jika rank2 tidak ada
        _PodiumPlace(user: rank1, rank: 1), // Kirim null jika rank1 tidak ada
        _PodiumPlace(user: rank3, rank: 3), // Kirim null jika rank3 tidak ada
      ],
    );
  }
}

class _UserListSection extends StatelessWidget {
  final List<LeaderboardEntry> users;
  final Future<void> Function() onRefresh;

  const _UserListSection(
      {required this.users, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    // HAPUS 'screenHeight' dan 'availableHeight'
    // HAPUS 'Positioned'
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0),
        decoration: BoxDecoration(
          color: Colors.blue.shade800,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: _UserList(users: users, onRefresh: onRefresh),
      );
    // );
  }
}

class _UserList extends StatelessWidget {
  final List<LeaderboardEntry> users;
  final Future<void> Function() onRefresh; // <-- Tambahkan ini

  const _UserList(
      {required this.users, required this.onRefresh}); // <-- Tambahkan ini

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 5,
          margin: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.blue.shade600,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: onRefresh, // <-- Gunakan callback
            edgeOffset: 10.0, // Agar indikator muncul di atas
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(), // Wajib
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                // Kirim LeaderboardEntry ke _UserListTile
                // Rank dihitung dari index + 4 (karena top 3 di podium)
                return _UserListTile(user: user, rank: index + 4);
              },
              separatorBuilder: (context, index) => const SizedBox(height: 12),
            ),
          ),
          // --- AKHIR PERUBAHAN ---
        ),
      ],
    );
  }
}

//==================================================================
// WIDGET-WIDGET PEMBANTU KECIL
//==================================================================

class _FilterButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onPressed;

  const _FilterButton(
      {required this.text, required this.isSelected, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.white : Colors.transparent,
        foregroundColor: isSelected ? Colors.blue : Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: Text(text),
    );
  }
}

class _PodiumPlace extends StatelessWidget {
  // Ubah user menjadi nullable
  final LeaderboardEntry? user;
  final int rank;

  const _PodiumPlace({required this.user, required this.rank});

  String _getCrownAsset() {
    return 'src/features/hicode/rank/crown$rank.png';
  }

  @override
  Widget build(BuildContext context) {
    final double height = rank == 1 ? 180 : (rank == 2 ? 140 : 120);
    final double width = rank == 1 ? 110 : 100;
    final bool hasUser = user != null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: (hasUser &&
                        user!.profileUrl != null &&
                        user!.profileUrl!.isNotEmpty)
                    ? NetworkImage(ImageOptimizer.getOptimizedUrl(
                        user!.profileUrl,
                        width: 120,
                        quality: 75))
                    : null,
                backgroundColor: Colors.white.withOpacity(0.2),
                // Tampilkan ikon placeholder jika tidak ada user atau tidak ada gambar
                child: (!hasUser ||
                        user!.profileUrl == null ||
                        user!.profileUrl!.isEmpty)
                    ? Icon(Icons.person,
                        size: 30,
                        color: Colors.white
                            .withOpacity(0.5)) // Ikon placeholder abu-abu
                    : null, // Background fallback
              ),
              // Tampilkan mahkota hanya jika ada user
              if (hasUser)
                Positioned(
                  top: rank == 1 ? -15 : null,
                  bottom: rank != 1 ? -5 : null,
                  right: rank != 1 ? -5 : null,
                  child: Image.asset(_getCrownAsset(),
                      width: rank == 1 ? 30 : 20, height: rank == 1 ? 30 : 20),
                ),
            ],
          ),
          const SizedBox(height: 8),
          // Tampilkan nama atau placeholder
          Text(
            hasUser ? user!.fullName : '-', // Tampilkan '-' jika tidak ada user
            style: TextStyle(
                color: Colors.white,
                fontWeight: hasUser
                    ? FontWeight.bold
                    : FontWeight.normal, // Sedikit bedakan style
                fontSize: hasUser ? 14 : 12 // Sedikit bedakan style
                ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(
                  hasUser ? 0.2 : 0.1), // Buat lebih transparan jika kosong
              borderRadius: BorderRadius.circular(20),
            ),
            // Tampilkan skor atau placeholder
            child: Text(hasUser ? '${user!.highestScore} PTS' : '- PTS',
                style: TextStyle(
                    color: Colors.white.withOpacity(hasUser ? 1.0 : 0.5),
                    fontSize: 12)),
          ),
          const SizedBox(height: 8),
          Container(
            height: height,
            width: width,
            decoration: BoxDecoration(
              // Buat warna lebih transparan jika tidak ada user
              color: const Color.fromARGB(255, 139, 197, 245)
                  .withOpacity(hasUser ? 1.0 : 0.5),
              border: Border(
                  top: BorderSide(
                      color: Colors.white.withOpacity(hasUser ? 0.4 : 0.2),
                      width: 8)),
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10), topRight: Radius.circular(10)),
            ),
            child: Center(
              child: Text(
                '$rank',
                style: TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withOpacity(hasUser ? 1.0 : 0.5),
                    shadows: hasUser
                        ? [
                            Shadow(
                                offset: Offset(2, 2),
                                blurRadius: 3.0,
                                color: Color.fromRGBO(0, 0, 0, 0.2))
                          ]
                        : null),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UserListTile extends StatelessWidget {
  final LeaderboardEntry user;
  final int rank;

  const _UserListTile({required this.user, required this.rank});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Text('$rank',
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey)),
          const SizedBox(width: 16),
          CircleAvatar(
            backgroundImage: (user.profileUrl != null &&
                    user.profileUrl!.isNotEmpty)
                ? NetworkImage(ImageOptimizer.getOptimizedUrl(user.profileUrl,
                    width: 100, quality: 75))
                : null,
            backgroundColor: Colors.grey.shade400,
            child: (user.profileUrl == null || user.profileUrl!.isEmpty)
                ? Icon(Icons.person,
                    size: 20,
                    color: Colors.white.withOpacity(0.7)) // Ikon default
                : null, // Background default
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(user.fullName,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Text('${user.highestScore} PTS',
              style: const TextStyle(
                  color: Colors.blue, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
