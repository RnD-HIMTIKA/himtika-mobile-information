import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:himtika_mobile_information/features/hilecturer/presentation/bloc/lecturer_bloc.dart';
import '/../core/shared_widgets/custom_app_bar.dart';

import '../widgets/home/home_header.dart';
import '../widgets/home/filter_section.dart';
import '../widgets/home/list_section.dart';
import '../widgets/home/sticky_header_delegate.dart';

class HiLecturerPage extends StatelessWidget {
  const HiLecturerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LecturerBloc(),
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: const Color(0xFFF5F7FA),
            appBar:
                CustomAppBar(title: "HiLecturer", showBackButton: true),

            // KONTEN UTAMA
            body: Stack(
              children: [
                // 1. LAPISAN BELAKANG: BACKGROUND PATTERN
                Positioned.fill(
                  child: Opacity(
                    opacity: 1.0,
                    child: Image.asset(
                      'src/features/hilecturer/pattern_bg.png', // Pastikan path benar
                      repeat: ImageRepeat.repeat,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                // 2. LAPISAN DEPAN: CUSTOM SCROLL VIEW
                CustomScrollView(
                  slivers: [
                    // A. HEADER BIRU
                    const SliverToBoxAdapter(
                      child: HomeHeader(),
                    ),

                    // B. STICKY HEADER
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: StickyHeaderDelegate(
                        child: Column(
                          children: [
                            // Search Bar
                            Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 18),
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: const [
                                  BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 10,
                                      offset: Offset(0, 5)),
                                ],
                              ),
                              child: TextField(
                                onChanged: (val) => context
                                    .read<LecturerBloc>()
                                    .add(LecturerSearchChanged(val)),
                                decoration: const InputDecoration(
                                  hintText: "Search by name...",
                                  prefixIcon: Icon(Icons.search),
                                  border: InputBorder.none,
                                  contentPadding:
                                      EdgeInsets.symmetric(vertical: 15),
                                ),
                              ),
                            ),

                            const SizedBox(height: 15),

                            // Filter Section
                            BlocBuilder<LecturerBloc, LecturerState>(
                              builder: (context, state) {
                                return LecturerFilterSection(
                                  selectedCategory: state.selectedCategory,
                                  onCategorySelected: (cat) {
                                    context
                                        .read<LecturerBloc>()
                                        .add(LecturerCategoryChanged(cat));
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    // C. JUDUL
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(24, 10, 24, 10),
                        child: Text("Our Lecturer",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),

                    // D. LIST DOSEN
                    SliverToBoxAdapter(
                      child: BlocBuilder<LecturerBloc, LecturerState>(
                        builder: (context, state) {
                          return ListSection(
                              lecturers: state.filteredLecturers);
                        },
                      ),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 40)),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}