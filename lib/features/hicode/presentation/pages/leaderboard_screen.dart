import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:himtika_mobile_information/features/hicode/presentation/bloc/leaderboard/leaderboard_bloc.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LeaderboardBloc()..add(FetchLeaderboard()),
      child: Scaffold(
        backgroundColor: Colors.blue,
        body: SafeArea(
          top: false,
          child: Stack(
            children: [
              // Lapisan 1: Background Pattern
              Positioned.fill(
                child: Opacity(
                  opacity: 1.0, // Atur transparansi sesuai selera
                  child: Image.asset(
                    'src/features/hicode/rank/pattern_rank.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              // Lapisan 2: Konten Utama Anda (tidak berubah)
              BlocBuilder<LeaderboardBloc, LeaderboardState>(
                builder: (context, state) {
                  if (state.status == LeaderboardStatus.loading && state.users.isEmpty) {
                    return const Center(child: CircularProgressIndicator(color: Colors.white));
                  }

                  final topThree = state.users.length > 2 ? state.users.sublist(0, 3) : state.users;
                  final others = state.users.length > 3 ? state.users.sublist(3) : [];

                  // Struktur Column Anda tetap sama persis
                  return Stack(
                    children: [
                      // Lapisan 1: Bagian Atas (Top Bar, Filter, Podium)
                      Column(
                        children: [
                          const _TopBar(),
                          _FilterButtons(selectedFilter: state.selectedFilter),
                          const SizedBox(height: 24),
                          _Podium(topThree: topThree),
                        ],
                      ),
                      // Lapisan 2: Bagian Bawah (Daftar Pengguna)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: _UserListSection(users: others.cast<Map<String, dynamic>>()),
                      ),
                    ],
                  );
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
                context
                    .read<LeaderboardBloc>()
                    .add(const FilterChanged(filter: LeaderboardFilter.allTime));
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
  final List<Map<String, dynamic>> topThree;
  const _Podium({required this.topThree});

  @override
  Widget build(BuildContext context) {
    if (topThree.isEmpty) return const SizedBox.shrink();

    final rank2 = topThree.length > 1 ? topThree[1] : null;
    final rank1 = topThree.isNotEmpty ? topThree[0] : null;
    final rank3 = topThree.length > 2 ? topThree[2] : null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (rank2 != null) _PodiumPlace(user: rank2, rank: 2),
        if (rank1 != null) _PodiumPlace(user: rank1, rank: 1),
        if (rank3 != null) _PodiumPlace(user: rank3, rank: 3),
      ],
    );
  }
}

class _UserListSection extends StatelessWidget {
  final List<Map<String, dynamic>> users;
  const _UserListSection({required this.users});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.41,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0), 
        decoration: BoxDecoration(
          color: Colors.blue.shade800,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: _UserList(users: users),
      ),
    );
  }
}

class _UserList extends StatelessWidget {
  final List<Map<String, dynamic>> users;
  const _UserList({required this.users});

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
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return _UserListTile(user: user, rank: index + 4);
            },
            separatorBuilder: (context, index) => const SizedBox(height: 12),
          ),
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
  final Map<String, dynamic> user;
  final int rank;

  const _PodiumPlace({required this.user, required this.rank});

  String _getCrownAsset() {
    return 'src/features/hicode/rank/crown$rank.png';
  }

  @override
  Widget build(BuildContext context) {
    final double height = rank == 1 ? 180 : (rank == 2 ? 140 : 120);
    final double width = rank == 1 ? 110 : 100;

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
                backgroundImage: AssetImage(user['avatar']),
              ),
              Positioned(
                top: rank == 1 ? -15 : null,
                bottom: rank != 1 ? -5 : null,
                right: rank != 1 ? -5 : null,
                child: Image.asset(_getCrownAsset(), width: rank == 1 ? 30 : 20, height: rank == 1 ? 30 : 20),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(user['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(user['score'], style: const TextStyle(color: Colors.white, fontSize: 12)),
          ),
          const SizedBox(height: 8),
          Container(
            height: height,
            width: width,
            decoration: BoxDecoration(
              // Warna dasar podium
              color: Colors.white.withOpacity(0.2),
              // Border atas untuk efek 3D
              border: Border(
                top: BorderSide(
                  color: Colors.white.withOpacity(0.4),
                  width: 8,
                ),
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Center(
              child: Text(
                '$rank',
                style: const TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      offset: Offset(2, 2),
                      blurRadius: 3.0,
                      color: Color.fromRGBO(0, 0, 0, 0.2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UserListTile extends StatelessWidget {
  final Map<String, dynamic> user;
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
          Text('$rank', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(width: 16),
          CircleAvatar(
            backgroundImage: AssetImage(user['avatar']),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(user['name'],
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Text(user['score'],
              style: const TextStyle(
                  color: Colors.blue, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}