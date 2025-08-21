import 'package:flutter/material.dart';
import 'package:himtika_mobile_information/features/calendar/presentation/pages/calendar_screen.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:collection';

// ===========================================================================
// HALAMAN 2: DETAIL JADWAL & KALENDER (FINAL DENGAN DIALOG)
// ===========================================================================

class ScheduleDetailScreen extends StatefulWidget {
  final String workspaceId;
  final String workspaceTitle;

  const ScheduleDetailScreen({
    super.key,
    required this.workspaceId,
    required this.workspaceTitle,
  });

  @override
  State<ScheduleDetailScreen> createState() => _ScheduleDetailScreenState();
}

class _ScheduleDetailScreenState extends State<ScheduleDetailScreen> {
  late final ValueNotifier<List<Map>> _selectedEvents;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final Map<DateTime, List<Map>> _dummySchedules = LinkedHashMap(
    equals: isSameDay,
    hashCode: (key) => key.day * 1000000 + key.month * 10000 + key.year,
  )..addAll({
    DateTime.utc(DateTime.now().year, DateTime.now().month, DateTime.now().day): [
      {'time': 'All Day', 'title': 'Basis Data', 'detail': '10.00 - 12.30 | Ruang 77'},
      {'time': '15.00\n17.30', 'title': 'Algoritma', 'detail': '15.00 - 17.30 | Ruang Lab'},
    ],
    DateTime.now().add(const Duration(days: 2)): [
       {'time': '07.30\n10.00', 'title': 'Kalkulus', 'detail': '07.30 - 10.00 | Ruang 80'},
    ],
  });

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  List<Map> _getEventsForDay(DateTime day) {
    DateTime normalizedDay = DateTime.utc(day.year, day.month, day.day);
    return _dummySchedules[normalizedDay] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }
  
  // Fungsi untuk menampilkan dialog "Tambah Event"
  void _showCreateEventDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return const _CreateEventDialog();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: 80,
        title: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            widget.workspaceTitle,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 32,
            ),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 72,
        leading: Padding(
          padding: const EdgeInsets.only(top: 8, left: 4),
          child: IconButton(
            icon: Image.asset(
              "src/features/login&register/images/arrow_back.png",
              width: 32,
              height: 32,
              color: const Color(0xFF31b7fe),
            ),
            onPressed: () {
              Navigator.pop(
                context,
                MaterialPageRoute(builder: (context) => const CalendarScreen()),
              );
            },
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF333C66), Color(0xFF2D365E)
            ],
          ),
          image: DecorationImage(
            image: AssetImage("src/features/calendar/images/pattern.png"),
            fit: BoxFit.cover,
            opacity: 0.5, // biar motifnya halus
          ),
        ),
        child: Padding(
          // ini yang bikin konten turun ke bawah header
          padding: EdgeInsets.only(
            top: kToolbarHeight + MediaQuery.of(context).padding.top,
          ),
          child: Stack(
            children: [
              _TopContent(
                focusedDay: _focusedDay,
                selectedDay: _selectedDay,
                onDaySelected: _onDaySelected,
                eventLoader: _getEventsForDay,
                onPageChanged: (focusedDay) {
                  setState(() {
                    _focusedDay = focusedDay;
                  });
                },
                onAddEventPressed: () => _showCreateEventDialog(context),
              ),
              _ScheduleSheet(selectedEvents: _selectedEvents),
            ],
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// WIDGET-WIDGET LOKAL
// ===========================================================================

// -- Widget untuk Konten Bagian Atas --
class _TopContent extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final Function(DateTime, DateTime) onDaySelected;
  final List<Map> Function(DateTime) eventLoader;
  final Function(DateTime) onPageChanged;
  final VoidCallback onAddEventPressed;

  const _TopContent({
    required this.focusedDay,
    required this.selectedDay,
    required this.onDaySelected,
    required this.eventLoader,
    required this.onPageChanged,
    required this.onAddEventPressed,
  });
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          const SizedBox(height: 45),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.share, size: 16),
                label: const Text("Bagikan"),
                style: ElevatedButton.styleFrom(foregroundColor: Colors.white, backgroundColor: Color(0xFF199df5).withValues(alpha:0.8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), elevation: 0),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.info_outline, size: 16),
                label: const Text("Informasi"),
                style: ElevatedButton.styleFrom(foregroundColor: Colors.white, backgroundColor: Color(0xFF8f8e92).withValues(alpha:0.8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), elevation: 0),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: focusedDay,
              selectedDayPredicate: (day) => isSameDay(selectedDay, day),
              onDaySelected: onDaySelected,
              eventLoader: eventLoader,
              onPageChanged: onPageChanged,
              headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true, titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(color: Colors.blue.withValues(alpha:0.5), shape: BoxShape.circle),
                selectedDecoration: BoxDecoration(color: Colors.blue.shade600, shape: BoxShape.circle),
                weekendTextStyle: const TextStyle(color: Colors.red),
                markerDecoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
              ),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onAddEventPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF1e9cf0),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Tambah Event"),
            ),
          ),
          const SizedBox(height: 150), // Jarak aman
        ],
      ),
    );
  }
}

// -- Widget untuk Panel Jadwal yang Bisa Digeser --
class _ScheduleSheet extends StatelessWidget {
  final ValueNotifier<List<Map>> selectedEvents;

  const _ScheduleSheet({required this.selectedEvents});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.15,
      minChildSize: 0.15,
      maxChildSize: 0.8,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha:0.15),
                blurRadius: 10,
                spreadRadius: 2,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: ValueListenableBuilder<List<Map>>(
            valueListenable: selectedEvents,
            builder: (context, value, _) {
              return ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(24),
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      "Jadwal Kegiatan Kamu",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Center(
                    child: Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  if (value.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40.0),
                      child: Center(
                        child: Text(
                          "Tidak ada kegiatan pada tanggal ini.",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    ...value.map((schedule) {
                      return _ScheduleEventCard(
                        time: schedule['time'] as String,
                        title: schedule['title'] as String,
                        detail: schedule['detail'] as String,
                      );
                    }),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

// -- Widget untuk Kartu Jadwal Kegiatan --
class _ScheduleEventCard extends StatelessWidget {
  final String time;
  final String title;
  final String detail;

  const _ScheduleEventCard({required this.time, required this.title, required this.detail});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.2), // warna shadow
            offset: const Offset(0, 4),
            blurRadius: 6, // seberapa blur
            spreadRadius: 0, // seberapa luas
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Row(
          children: [
            SizedBox(
              width: 60,
              child: Text(
                time,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
            Container(
              height: 50,
              width: 1,
              color: Colors.grey.shade300,
              margin: const EdgeInsets.symmetric(horizontal: 16),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    detail,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -- WIDGET BARU: Dialog untuk Tambah Event --
class _CreateEventDialog extends StatelessWidget {
  const _CreateEventDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.all(24),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Tambah Event', style: TextStyle(fontWeight: FontWeight.bold)),
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
            decoration: InputDecoration(
              hintText: 'Masukkan Judul Event',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.blue)),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Deskripsi', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              hintText: 'Masukkan Deskripsi Event',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.blue)),
            ),
          ),
        ],
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      actions: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text('Buat Event'),
          ),
        ),
      ],
    );
  }
}