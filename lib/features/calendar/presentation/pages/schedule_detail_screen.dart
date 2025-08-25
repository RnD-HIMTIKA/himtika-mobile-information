import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:himtika_mobile_information/core/injection_container.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:collection';
import 'package:intl/intl.dart';

import 'package:himtika_mobile_information/features/roles/domain/entities/role.dart';
import 'package:himtika_mobile_information/features/roles/domain/usecases/get_my_roles.dart';
import 'package:himtika_mobile_information/features/auth/domain/entities/user.dart';
import '../bloc/event/event_bloc.dart';
import '../bloc/share_workspace/share_workspace_bloc.dart';
import '../bloc/workspace/workspace_bloc.dart';
import '../../domain/entities/event.dart';
import '../../domain/entities/workspace.dart';
import '../../domain/entities/workspace_with_members.dart';


// ===========================================================================
// HALAMAN 2: DETAIL JADWAL & KALENDER
// ===========================================================================

class ScheduleDetailScreen extends StatelessWidget {
  final WorkspaceWithMembers workspaceWithMembers;

  const ScheduleDetailScreen({
    super.key,
    required this.workspaceWithMembers,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        // Tentukan rentang tanggal default (bulan saat ini)
        final now = DateTime.now();
        final firstDay = DateTime(now.year, now.month, 1);
        final lastDay = DateTime(now.year, now.month + 1, 0);

        // PERBAIKAN DI SINI: Gunakan event LoadEventsInRange
        return sl<EventBloc>()
          ..add(LoadEventsInRange(
            workspaceId: workspaceWithMembers.workspace.id,
            startDate: firstDay,
            endDate: lastDay,
          ));
      },
      child: _ScheduleDetailView(
        workspaceWithMembers: workspaceWithMembers,
      ),
    );
  }
}

class _ScheduleDetailView extends StatefulWidget {
  final WorkspaceWithMembers workspaceWithMembers;

  const _ScheduleDetailView({
    required this.workspaceWithMembers,
  });

  @override
  State<_ScheduleDetailView> createState() => _ScheduleDetailViewState();
}

class _ScheduleDetailViewState extends State<_ScheduleDetailView> {
  late final ValueNotifier<List<Event>> _selectedEvents;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  LinkedHashMap<DateTime, List<Event>> _eventsMap = LinkedHashMap(
    equals: isSameDay,
    hashCode: (key) => key.day * 1000000 + key.month * 10000 + key.year,
  );

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
    // Panggil LoadEventsInRange saat pertama kali halaman dibuka
    _loadEventsForMonth(_focusedDay); 
  }

  void _loadEventsForMonth(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    context.read<EventBloc>().add(LoadEventsInRange(
      workspaceId: widget.workspaceWithMembers.workspace.id,
      startDate: firstDay,
      endDate: lastDay,
    ));
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  List<Event> _getEventsForDay(DateTime day) {
    return _eventsMap[day] ?? [];
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
  
  void _showCreateEventDialog(BuildContext context, DateTime selectedDate) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: BlocProvider.of<EventBloc>(context),
          child: _ModifyEventDialog(
            selectedDate: selectedDate, 
            workspaceId: widget.workspaceWithMembers.workspace.id,
          ),
        );
      },
    );
  }

  void _showEditEventDialog(BuildContext context, Event event) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: BlocProvider.of<EventBloc>(context),
          child: _ModifyEventDialog(
            selectedDate: event.startTime, 
            workspaceId: widget.workspaceWithMembers.workspace.id,
            eventToEdit: event,
          ),
        );
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
            widget.workspaceWithMembers.workspace.title,
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
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      body: BlocListener<EventBloc, EventState>(
        listener: (context, state) {
          if (state.status == EventStatus.loaded) {
            final newMap = LinkedHashMap<DateTime, List<Event>>(
              equals: isSameDay,
              hashCode: (key) => key.day * 1000000 + key.month * 10000 + key.year,
            );
            for (var event in state.events) {
              final day = DateTime.utc(event.startTime.year, event.startTime.month, event.startTime.day);
              if (newMap[day] == null) newMap[day] = [];
              newMap[day]!.add(event);
            }
            setState(() {
              _eventsMap = newMap;
              _selectedEvents.value = _getEventsForDay(_selectedDay!);
            });
          } else if (state.status == EventStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.errorMessage}'), backgroundColor: Colors.red),
            );
          }
        },
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF333C66), Color(0xFF2D365E)],
            ),
            image: DecorationImage(
              image: AssetImage("src/features/calendar/images/pattern.png"),
              fit: BoxFit.cover,
              opacity: 0.5,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(top: kToolbarHeight + MediaQuery.of(context).padding.top + 40),
            child: Stack(
              children: [
                _TopContent(
                  workspaceWithMembers: widget.workspaceWithMembers,
                  focusedDay: _focusedDay,
                  selectedDay: _selectedDay,
                  onDaySelected: _onDaySelected,
                  eventLoader: _getEventsForDay,
                  onPageChanged: (focusedDay) {
                    setState(() => _focusedDay = focusedDay);
                    _loadEventsForMonth(focusedDay); // Panggil saat bulan diganti
                  },
                  onAddEventPressed: () => _showCreateEventDialog(context, _selectedDay!),
                ),
                _ScheduleSheet(
                  selectedEvents: _selectedEvents, 
                  onEventTap: (event) => _showEditEventDialog(context, event),
                  currentUserRole: widget.workspaceWithMembers.currentUserRole,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopContent extends StatelessWidget {
  final WorkspaceWithMembers workspaceWithMembers;
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final Function(DateTime, DateTime) onDaySelected;
  final List<Event> Function(DateTime) eventLoader;
  final Function(DateTime) onPageChanged;
  final VoidCallback onAddEventPressed;

  const _TopContent({
    required this.workspaceWithMembers,
    required this.focusedDay,
    required this.selectedDay,
    required this.onDaySelected,
    required this.eventLoader,
    required this.onPageChanged,
    required this.onAddEventPressed,
  });

  void _showShareDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return BlocProvider(
          create: (_) => sl<ShareWorkspaceBloc>(),
          child: _ShareWorkspaceDialog(
            workspaceId: workspaceWithMembers.workspace.id, 
            workspaceTitle: workspaceWithMembers.workspace.title
          ),
        );
      },
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return _WorkspaceInfoDialog(workspaceWithMembers: workspaceWithMembers);
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final currentUserRole = workspaceWithMembers.currentUserRole;

    return SingleChildScrollView(
       padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: currentUserRole == 'owner'
                    ? () => _showShareDialog(context)
                    : null,
                icon: const Icon(Icons.share, size: 16),
                label: const Text("Bagikan"),
                style: ElevatedButton.styleFrom(foregroundColor: Colors.white, backgroundColor: const Color(0xFF199df5).withOpacity(0.8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), elevation: 0),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => _showInfoDialog(context),
                icon: const Icon(Icons.info_outline, size: 16),
                label: const Text("Informasi"),
                style: ElevatedButton.styleFrom(foregroundColor: Colors.white, backgroundColor: const Color(0xFF8f8e92).withOpacity(0.8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), elevation: 0),
              ),
            ],
          ),
          const SizedBox(height: 24),
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
                todayDecoration: BoxDecoration(color: Colors.blue.withOpacity(0.5), shape: BoxShape.circle),
                selectedDecoration: BoxDecoration(color: Colors.blue.shade600, shape: BoxShape.circle),
                weekendTextStyle: const TextStyle(color: Colors.red),
                markerDecoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: currentUserRole == 'viewer' ? null : onAddEventPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1e9cf0),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Tambah Event"),
            ),
          ),
          const SizedBox(height: 150),
        ],
      ),
    );
  }
}

class _ScheduleSheet extends StatelessWidget {
  final ValueNotifier<List<Event>> selectedEvents;
  final Function(Event) onEventTap;
  final String currentUserRole;

  const _ScheduleSheet({
    required this.selectedEvents,
    required this.onEventTap,
    required this.currentUserRole,
  });

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
                color: Colors.black.withOpacity(0.15),
                blurRadius: 10,
                spreadRadius: 2,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: ValueListenableBuilder<List<Event>>(
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
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
                    ...value.map((event) {
                      return _ScheduleEventCard(
                        event: event,
                        onTap: currentUserRole == 'viewer' ? () {} : () => onEventTap(event),
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

class _ScheduleEventCard extends StatelessWidget {
  final Event event;
  final VoidCallback onTap;

  const _ScheduleEventCard({required this.event, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // PERBAIKAN DI SINI: Konversi ke waktu lokal sebelum diformat
    final startTime = DateFormat.Hm().format(event.startTime.toLocal());
    final endTime = DateFormat.Hm().format(event.endTime.toLocal());
    
    final time = '$startTime\n$endTime';
    final title = event.title;
    final detail = event.description ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
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
      ),
    );
  }
}

// ===========================================================================
// DIALOG BUAT/EDIT EVENT (DIRKEMBANGKAN SECARA SIGNIFIKAN)
// ===========================================================================
class _ModifyEventDialog extends StatefulWidget {
  final DateTime selectedDate;
  final String workspaceId;
  final Event? eventToEdit;

  const _ModifyEventDialog({
    required this.selectedDate,
    required this.workspaceId,
    this.eventToEdit,
  });

  @override
  State<_ModifyEventDialog> createState() => _ModifyEventDialogState();
}

class _ModifyEventDialogState extends State<_ModifyEventDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  bool _isAllDay = false;
  bool _isRecurring = false;
  Set<String> _selectedDays = {};
  DateTime? _untilDate;
  
  // PERBAIKAN: Definisikan _reminderOptions di sini
  final Map<int, String> _reminderOptions = {
    15: '15 Menit', 30: '30 Menit', 45: '45 Menit',
    60: '1 Jam', 1440: '1 Hari', 4320: '3 Hari',
    10080: '7 Hari', 43200: '30 Hari'
  };
  Set<int> _selectedReminderMinutes = {}; 

  // Fungsi untuk membuka dialog multi-pilih
  void _showReminderDialog() async {
    final result = await showDialog<Set<int>>(
      context: context,
      builder: (_) => _ReminderSelectionDialog(initialSelection: _selectedReminderMinutes),
    );
    if (result != null) {
      setState(() {
        _selectedReminderMinutes = result;
      });
    }
  }

  bool get isEditing => widget.eventToEdit != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _titleController.text = widget.eventToEdit!.title;
      _descriptionController.text = widget.eventToEdit!.description ?? '';
      // PERBAIKAN DI SINI: Konversi ke waktu lokal sebelum diubah menjadi TimeOfDay
      _startTime = TimeOfDay.fromDateTime(widget.eventToEdit!.startTime.toLocal());
      _endTime = TimeOfDay.fromDateTime(widget.eventToEdit!.endTime.toLocal());
      _selectedReminderMinutes = widget.eventToEdit!.reminderMinutesBefore?.toSet() ?? {};
    } else {
      _startTime = TimeOfDay.now();
      _endTime = TimeOfDay.fromDateTime(DateTime.now().add(const Duration(hours: 1)));
      _untilDate = widget.selectedDate.add(const Duration(days: 30));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context, {required bool isStartTime}) async {
    final initialTime = isStartTime ? _startTime : _endTime;
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (pickedTime != null) {
      setState(() {
        if (isStartTime) {
          _startTime = pickedTime;
        } else {
          _endTime = pickedTime;
        }
      });
    }
  }

  // Fungsi untuk membuka dialog pemilihan perulangan
  void _showRecurrenceDialog() {
    showDialog(
      context: context,
      builder: (ctx) => _RecurrenceDialog(
        initialSelectedDays: _selectedDays,
        // Teruskan fungsi callback untuk memperbarui state
        onSave: (newSelectedDays) {
          setState(() {
            _selectedDays = newSelectedDays;
            _isRecurring = newSelectedDays.isNotEmpty;
          });
        },
      ),
    );
  }

  void _selectUntilDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _untilDate ?? DateTime.now(),
      firstDate: widget.selectedDate,
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (pickedDate != null) {
      setState(() {
        _untilDate = pickedDate;
      });
    }
  }

  void _onDeletePressed() {
    showDialog(
      context: context,
      builder: (alertDialogContext) => AlertDialog(
        title: const Text('Hapus Event'),
        content: const Text('Anda yakin ingin menghapus event ini? Aksi ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(alertDialogContext).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              context.read<EventBloc>().add(DeleteEventPressed(widget.eventToEdit!.id, widget.workspaceId));
              Navigator.of(alertDialogContext).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.all(24),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(isEditing ? 'Edit Event' : 'Tambah Event', style: const TextStyle(fontWeight: FontWeight.bold)),
          IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Judul', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              maxLength: 30,
              inputFormatters: [LengthLimitingTextInputFormatter(30)],
              decoration: InputDecoration(
                hintText: 'Masukkan Judul Event',
                counterText: "",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Deskripsi', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLength: 60,
              inputFormatters: [LengthLimitingTextInputFormatter(60)],
              maxLines: null,
              decoration: InputDecoration(
                hintText: 'Masukkan Deskripsi Event',
                counterText: "",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                FilterChip(
                  label: const Text('Seharian'),
                  selected: _isAllDay,
                  onSelected: (selected) {
                    setState(() {
                      _isAllDay = selected;
                    });
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Ulangi'),
                  selected: _isRecurring,
                  onSelected: (selected) {
                    if (selected) {
                      _showRecurrenceDialog();
                    } else {
                      setState(() {
                        _isRecurring = false;
                        _selectedDays.clear();
                      });
                    }
                  },
                ),
              ],
            ),
            if (!_isAllDay) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTimePickerField(context, 'Mulai', _startTime, isStartTime: true),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTimePickerField(context, 'Selesai', _endTime, isStartTime: false),
                  ),
                ],
              ),
            ],
              
            // Tampilkan pilihan tanggal "Sampai" jika perulangan aktif
            if (_isRecurring) ...[
              const SizedBox(height: 16),
              const Text('Ulangi Sampai', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectUntilDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(DateFormat('d MMMM yyyy').format(_untilDate!)),
                ),
              ),
            ],

            // --- UI BARU UNTUK NOTIFIKASI ---
            const SizedBox(height: 16),
            const Text('Tambahkan Notifikasi', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            InkWell(
              onTap: _showReminderDialog,
              child: InputDecorator(
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  _selectedReminderMinutes.isEmpty
                      ? 'Tidak ada pengingat'
                      : _selectedReminderMinutes.map((m) => _reminderOptions[m]).join(', '),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      actions: [
        if (isEditing)
          Row(
            children: [
              // Tombol Hapus
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _onDeletePressed,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Hapus'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Tombol Update
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final localStartDateTime = DateTime(
                      widget.selectedDate.year,
                      widget.selectedDate.month,
                      widget.selectedDate.day,
                      _startTime.hour,
                      _startTime.minute
                    );
                    final localEndDateTime = DateTime(
                      widget.selectedDate.year,
                      widget.selectedDate.month,
                      widget.selectedDate.day,
                      _endTime.hour,
                      _endTime.minute
                    );

                    final updatedEvent = Event(
                      id: widget.eventToEdit!.id,
                      workspaceId: widget.eventToEdit!.workspaceId,
                      createdBy: widget.eventToEdit!.createdBy,
                      title: _titleController.text,
                      description: _descriptionController.text,
                      // 2. Konversi ke UTC HANYA saat akan dikirim
                      startTime: localStartDateTime.toUtc(),
                      endTime: localEndDateTime.toUtc(),
                      createdAt: widget.eventToEdit!.createdAt,
                      recurrenceId: widget.eventToEdit!.recurrenceId,
                      reminderMinutesBefore: _selectedReminderMinutes.toList(),
                    );
                    context.read<EventBloc>().add(UpdateEventSubmitted(updatedEvent));
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Update'),
                ),
              ),
            ],
          )
        else
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final localStartDateTime = _isAllDay 
                    ? DateTime(widget.selectedDate.year, widget.selectedDate.month, widget.selectedDate.day) 
                    : DateTime(widget.selectedDate.year, widget.selectedDate.month, widget.selectedDate.day, _startTime.hour, _startTime.minute);
                
                final localEndDateTime = _isAllDay 
                    ? DateTime(widget.selectedDate.year, widget.selectedDate.month, widget.selectedDate.day, 23, 59) 
                    : DateTime(widget.selectedDate.year, widget.selectedDate.month, widget.selectedDate.day, _endTime.hour, _endTime.minute);
                
                if (_isRecurring) {
                  context.read<EventBloc>().add(
                        CreateRecurringEventSubmitted(
                          workspaceId: widget.workspaceId,
                          title: _titleController.text,
                          description: _descriptionController.text,
                          // 2. Konversi ke UTC HANYA saat akan dikirim
                          startTime: localStartDateTime.toUtc(),
                          endTime: localEndDateTime.toUtc(),
                          byDay: _selectedDays.toList(),
                          untilDate: _untilDate!,
                          reminderMinutesBefore: _selectedReminderMinutes.toList(),
                        ),
                      );
                } else {
                  context.read<EventBloc>().add(
                        CreateEventSubmitted(
                          workspaceId: widget.workspaceId,
                          title: _titleController.text,
                          description: _descriptionController.text,
                          // 2. Konversi ke UTC HANYA saat akan dikirim
                          startTime: localStartDateTime.toUtc(),
                          endTime: localEndDateTime.toUtc(),
                          reminderMinutesBefore: _selectedReminderMinutes.toList(),
                        ),
                      );
                }
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Buat Event'),
            ),
          ),
      ],
    );
  }

  Widget _buildTimePickerField(BuildContext context, String label, TimeOfDay time, {required bool isStartTime}) {
    return InkWell(
      onTap: () => _selectTime(context, isStartTime: isStartTime),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          time.format(context),
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}

class _ShareWorkspaceDialog extends StatefulWidget {
  final String workspaceId;
  final String workspaceTitle;
  const _ShareWorkspaceDialog(
      {required this.workspaceId, required this.workspaceTitle});

  @override
  State<_ShareWorkspaceDialog> createState() => _ShareWorkspaceDialogState();
}

class _ShareWorkspaceDialogState extends State<_ShareWorkspaceDialog> {
  final _searchController = TextEditingController();
  String _selectedRole = 'viewer'; // Default role
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return BlocListener<ShareWorkspaceBloc, ShareWorkspaceState>(
      listener: (context, state) {
        if (state.shareStatus == ShareStatus.success) {
          // Cek apakah ada data di clipboard untuk membedakan aksi
          Clipboard.getData(Clipboard.kTextPlain).then((value) {
            final message = (value?.text?.contains('himfo://') ?? false)
                ? 'Link undangan berhasil disalin!'
                : 'Undangan berhasil dikirim!';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message), backgroundColor: Colors.green),
            );
          });
          _searchController.clear();
          context.read<ShareWorkspaceBloc>().add(const ClearSearch());
        } else if (state.shareStatus == ShareStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text(state.shareErrorMessage ?? 'Gagal melakukan aksi.'),
                backgroundColor: Colors.red),
          );
        }
      },
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Share Workspace', style: TextStyle(fontWeight: FontWeight.bold)),
            IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Bar dan Dropdown Peran
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          onChanged: (query) {
                            context.read<ShareWorkspaceBloc>().add(SearchUserChanged(query));
                          },
                          decoration: InputDecoration(
                            hintText: 'Username...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // TAMBAHKAN DROPDOWN INI
                      SizedBox(
                        width: 110, // Atur lebar agar pas
                        child: DropdownButtonFormField<String>(
                          value: _selectedRole,
                          items: const [
                            DropdownMenuItem(value: 'viewer', child: Text('Viewer')),
                            DropdownMenuItem(value: 'editor', child: Text('Editor')),
                          ],
                          onChanged: (value) {
                            if (value != null) setState(() => _selectedRole = value);
                          },
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Hasil Pencarian akan muncul di sini sebagai overlay

                  const SizedBox(height: 24),
                  
                  // Bagikan pada Roles & Salin Link
                  const Text("Bagikan pada Roles", style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () {
                      // Tutup dialog saat ini, lalu buka dialog baru
                      Navigator.of(context).pop();
                      showDialog(
                        context: context,
                        builder: (ctx) {
                          // Teruskan BLoC yang sudah ada
                          return BlocProvider.value(
                            value: context.read<ShareWorkspaceBloc>(),
                            child: _ShareByRoleDialog(
                              workspaceId: widget.workspaceId,
                              roleToGrant: _selectedRole,
                            ),
                          );
                        },
                      );
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Bagikan pada roles yang sama"),
                        Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.read<ShareWorkspaceBloc>().add(
                              CreateAndCopyInvitationLink(
                                workspaceId: widget.workspaceId,
                                role: _selectedRole,
                              ),
                            );
                      },
                      icon: const Icon(Icons.link),
                      label: const Text("Salin Link"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade100,
                        foregroundColor: Colors.blue.shade800,
                      ),
                    ),
                  ),
                ],
              ),

              // HASIL PENCARIAN SEBAGAI OVERLAY
              BlocBuilder<ShareWorkspaceBloc, ShareWorkspaceState>(
                builder: (context, state) {
                  if (state.searchStatus == SearchStatus.initial ||
                      _searchController.text.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  // Tampilkan hasil di atas konten lain
                  return Positioned(
                    top: 60, // Posisi tepat di bawah search bar
                    left: 0,
                    right: 0,
                    child: Material(
                      elevation: 4.0,
                      borderRadius: BorderRadius.circular(12),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                            maxHeight:
                                MediaQuery.of(context).size.height * 0.25),
                        child: _buildSearchResults(state),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget pembantu baru untuk membangun hasil pencarian
  Widget _buildSearchResults(ShareWorkspaceState state) {
    if (state.searchStatus == SearchStatus.loading) {
      return const Center(
          child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator()));
    }
    if (state.searchResults.isEmpty) {
      return const ListTile(title: Text("Tidak ada pengguna ditemukan"));
    }
    return ListView.builder(
      shrinkWrap: true,
      itemCount: state.searchResults.length,
      itemBuilder: (context, index) {
        final user = state.searchResults[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage:
                (user.profileUrl != null && user.profileUrl!.isNotEmpty)
                    ? NetworkImage(user.profileUrl!)
                    : null,
            child: (user.profileUrl == null || user.profileUrl!.isEmpty)
                ? const Icon(Icons.person)
                : null,
          ),
          title: Text(user.fullName),
          subtitle: Text("@${user.username}"),
          trailing: ElevatedButton(
            child: const Text('Invite'),
            onPressed: () {
              context.read<ShareWorkspaceBloc>().add(
                    InviteUserSubmitted(
                      workspaceId: widget.workspaceId,
                      email: user.email, // Gunakan email dari hasil pencarian
                      role: _selectedRole,
                    ),
                  );
            },
          ),
        );
      },
    );
  }
}

class _ShareByRoleDialog extends StatefulWidget {
  final String workspaceId;
  final String roleToGrant;
  const _ShareByRoleDialog(
      {required this.workspaceId, required this.roleToGrant});

  @override
  State<_ShareByRoleDialog> createState() => _ShareByRoleDialogState();
}

class _ShareByRoleDialogState extends State<_ShareByRoleDialog> {
  // Gunakan GetIt untuk mengambil use case
  final GetMyRoles _getMyRoles = sl<GetMyRoles>();

  // State untuk menyimpan daftar role dan yang dipilih
  List<Role>? _myRoles;
  Set<Role> _selectedRoles = {};

  @override
  void initState() {
    super.initState();
    // Ambil daftar role milik pengguna saat ini
    _getMyRoles().then((roles) {
      if (mounted) {
        setState(() {
          _myRoles = roles;
        });
      }
    });
  }

  void _onSimpanPressed() {
    // Jalankan validasi: Jika Kelas dipilih, Angkatan wajib dipilih
    final hasKelas = _selectedRoles.any((r) => r.groupName == 'Kelas');
    final hasAngkatan = _selectedRoles.any((r) => r.groupName == 'Angkatan');

    if (hasKelas && !hasAngkatan) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Jika memilih Kelas, Anda juga wajib memilih Angkatan.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_selectedRoles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih minimal satu role untuk dibagikan.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Kirim event ke BLoC
    context.read<ShareWorkspaceBloc>().add(
          InviteByRoleSubmitted(
            workspaceId: widget.workspaceId,
            targetRoles: _selectedRoles.toList(),
            roleToGrant: widget.roleToGrant,
          ),
        );
    Navigator.of(context).pop(); // Tutup dialog "Bagikan ke Role"
  }

  @override
  Widget build(BuildContext context) {
    if (_myRoles == null) {
      return const Dialog(child: Center(child: CircularProgressIndicator()));
    }

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Text('Bagikan pada Roles',
          style: TextStyle(fontWeight: FontWeight.bold)),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: _myRoles!.length,
          itemBuilder: (context, index) {
            final role = _myRoles![index];
            final isSelected = _selectedRoles.contains(role);

            // Abaikan role 'Pengunjung'
            if (role.name == 'Pengunjung') return const SizedBox.shrink();

            return SwitchListTile(
              title: Text(role.name),
              subtitle: Text(role.groupName,
                  style: const TextStyle(color: Colors.grey)),
              value: isSelected,
              onChanged: (value) {
                setState(() {
                  if (value) {
                    _selectedRoles.add(role);
                  } else {
                    _selectedRoles.remove(role);
                  }
                });
              },
            );
          },
        ),
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
}

class _WorkspaceInfoDialog extends StatelessWidget {
  final WorkspaceWithMembers workspaceWithMembers;

  const _WorkspaceInfoDialog({required this.workspaceWithMembers});

  @override
  Widget build(BuildContext context) {
    // PERBAIKAN 1: Pindahkan logika untuk mendapatkan data ke dalam build method
    final workspace = workspaceWithMembers.workspace;
    final allMembers = workspaceWithMembers.members;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.all(24),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Info Workspace', style: TextStyle(fontWeight: FontWeight.bold)),
          IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildReadOnlyField("Judul", workspace.title),
              const SizedBox(height: 16),
              _buildReadOnlyField(
                "Tanggal Dibuat", 
                DateFormat('d MMMM yyyy').format(workspace.lastUpdated ?? DateTime.now())
              ),
              const SizedBox(height: 16),
              _buildReadOnlyField("Deskripsi", workspace.description, maxLines: 3),
              const SizedBox(height: 24),
              const Text("Yang Punya Akses", style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              if (allMembers.isEmpty)
                const Text("Tidak ada anggota lain.", style: TextStyle(color: Colors.grey))
              else
                // PERBAIKAN 2: Gunakan ListView.builder dengan logika yang benar
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: allMembers.length,
                  itemBuilder: (context, index) {
                    final member = allMembers[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        // PERBAIKAN 3: Akses properti melalui member.user
                        backgroundImage: (member.user.profileUrl != null && member.user.profileUrl!.isNotEmpty)
                            ? NetworkImage(member.user.profileUrl!)
                            : null,
                        child: (member.user.profileUrl == null || member.user.profileUrl!.isEmpty)
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      title: Text(member.user.fullName),
                      subtitle: Text("@${member.user.username}"),
                      trailing: Text(
                        // Kapitalisasi huruf pertama
                        member.role.substring(0, 1).toUpperCase() + member.role.substring(1),
                        style: TextStyle(color: Colors.grey.shade600, fontStyle: FontStyle.italic),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        TextFormField(
          initialValue: value,
          readOnly: true,
          maxLines: maxLines,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
        ),
      ],
    );
  }
}

// WIDGET BARU UNTUK DIALOG PEMILIHAN HARI
class _RecurrenceDialog extends StatefulWidget {
  final Set<String> initialSelectedDays;
  final Function(Set<String>) onSave;
  const _RecurrenceDialog({required this.initialSelectedDays, required this.onSave});

  @override
  State<_RecurrenceDialog> createState() => _RecurrenceDialogState();
}

class _RecurrenceDialogState extends State<_RecurrenceDialog> {
  late Set<String> _tempSelectedDays;
  final Map<String, String> _days = {
    'SU': 'Minggu', 'MO': 'Senin', 'TU': 'Selasa', 'WE': 'Rabu',
    'TH': 'Kamis', 'FR': 'Jumat', 'SA': 'Sabtu'
  };

  @override
  void initState() {
    super.initState();
    _tempSelectedDays = {...widget.initialSelectedDays};
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ulangi Setiap'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: _days.entries.map((entry) {
          final key = entry.key;
          final dayName = entry.value;
          return CheckboxListTile(
            title: Text(dayName),
            value: _tempSelectedDays.contains(key),
            onChanged: (isSelected) {
              setState(() {
                if (isSelected ?? false) {
                  _tempSelectedDays.add(key);
                } else {
                  _tempSelectedDays.remove(key);
                }
              });
            },
          );
        }).toList(),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Batal')),
        ElevatedButton(
          onPressed: () {
            widget.onSave(_tempSelectedDays);
            Navigator.of(context).pop();
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}

class _ReminderSelectionDialog extends StatefulWidget {
  final Set<int> initialSelection;
  const _ReminderSelectionDialog({required this.initialSelection});

  @override
  State<_ReminderSelectionDialog> createState() => _ReminderSelectionDialogState();
}

class _ReminderSelectionDialogState extends State<_ReminderSelectionDialog> {
  late Set<int> _selectedMinutes;
  final Map<int, String> _reminderOptions = {
    15: '15 Menit', 30: '30 Menit', 45: '45 Menit',
    60: '1 Jam', 1440: '1 Hari', 4320: '3 Hari',
    10080: '7 Hari', 43200: '30 Hari'
  };

  @override
  void initState() {
    super.initState();
    _selectedMinutes = {...widget.initialSelection};
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pilih Pengingat'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: _reminderOptions.entries.map((entry) {
            return CheckboxListTile(
              title: Text(entry.value),
              value: _selectedMinutes.contains(entry.key),
              onChanged: (isSelected) {
                setState(() {
                  if (isSelected ?? false) {
                    _selectedMinutes.add(entry.key);
                  } else {
                    _selectedMinutes.remove(entry.key);
                  }
                });
              },
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Batal')),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(_selectedMinutes),
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}