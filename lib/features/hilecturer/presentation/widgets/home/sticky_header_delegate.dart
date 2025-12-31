import 'package:flutter/material.dart';

class StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  StickyHeaderDelegate({required this.child});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    // Logic Lengkungan Biru (Hilang saat scroll)
    double blueOpacity = (1 - shrinkOffset / 50).clamp(0.0, 1.0);

    // Logic Background Solid (Muncul saat scroll/sticky)
    double backgroundOpacity = (shrinkOffset / 100).clamp(0.0, 1.0);

    return Container(
      height: maxExtent,
      color: const Color(0xFFF5F7FA).withOpacity(backgroundOpacity),
      padding: const EdgeInsets.only(top: 10),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // --- LAPIS 1: LENGKUNGAN BIRU PALSU ---
          Positioned(
            top: -20,
            left: 0,
            right: 0,
            height: 50, // Tinggi lengkungan
            child: Opacity(
              opacity: blueOpacity,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
              ),
            ),
          ),

          // --- LAPIS 2: KONTEN ASLI ---
          Positioned.fill(child: child),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 135;

  @override
  double get minExtent => 135;

  @override
  bool shouldRebuild(StickyHeaderDelegate oldDelegate) {
    return child != oldDelegate.child;
  }
}
