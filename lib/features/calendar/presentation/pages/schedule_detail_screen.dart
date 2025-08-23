import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'dart:collection';

import 'package:himtika_mobile_information/core/injection_container.dart';
import 'package:himtika_mobile_information/features/roles/domain/entities/role.dart';
import 'package:himtika_mobile_information/features/roles/domain/usecases/get_my_roles.dart';
import '../bloc/share_workspace/share_workspace_bloc.dart'; // Import BLoC baru
import '../bloc/event/event_bloc.dart';
import '../../domain/entities/event.dart';

// ===========================================================================
// HALAMAN 2: DETAIL JADWAL & KALENDER
// ===========================================================================

class ScheduleDetailScreen extends StatelessWidget {
  final String workspaceId;
  final String workspaceTitle;

  const ScheduleDetailScreen({
    super.key,
    required this.workspaceId,
    required this.workspaceTitle,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<EventBloc>()..add(LoadEvents(workspaceId)),
      child: _ScheduleDetailView(
        workspaceId: workspaceId,
        workspaceTitle: workspaceTitle,
      ),
    );
  }
}

class _ScheduleDetailView extends StatefulWidget {
  final String workspaceId;
  final String workspaceTitle;

  const _ScheduleDetailView({
    required this.workspaceId,
    required this.workspaceTitle,
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
            workspaceId: widget.workspaceId,
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
            workspaceId: widget.workspaceId,
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
              Navigator.of(context).pop();
            },
          ),
        ),
      ),
      body: BlocListener<EventBloc, EventState>(
        listener: (context, state) {
          if (state.status == EventStatus.loaded) {
            final newMap = LinkedHashMap<DateTime, List<Event>>(
              equals: isSameDay,
              hashCode: (key) =>
                  key.day * 1000000 + key.month * 10000 + key.year,
            );
            for (var event in state.events) {
              final day = DateTime.utc(event.startTime.year,
                  event.startTime.month, event.startTime.day);
              if (newMap[day] == null) newMap[day] = [];
              newMap[day]!.add(event);
            }
            setState(() {
              _eventsMap = newMap;
              _selectedEvents.value = _getEventsForDay(_selectedDay!);
            });
          } else if (state.status == EventStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Error: ${state.errorMessage}'),
                  backgroundColor: Colors.red),
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
            padding: EdgeInsets.only(
                top: kToolbarHeight + MediaQuery.of(context).padding.top + 40),
            child: Stack(
              children: [
                _TopContent(
                  focusedDay: _focusedDay,
                  selectedDay: _selectedDay,
                  onDaySelected: _onDaySelected,
                  eventLoader: _getEventsForDay,
                  onPageChanged: (focusedDay) =>
                      setState(() => _focusedDay = focusedDay),
                  onAddEventPressed: () =>
                      _showCreateEventDialog(context, _selectedDay!),
                ),
                _ScheduleSheet(
                  selectedEvents: _selectedEvents,
                  onEventTap: (event) => _showEditEventDialog(context, event),
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
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final Function(DateTime, DateTime) onDaySelected;
  final List<Event> Function(DateTime) eventLoader;
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

  // Fungsi untuk menampilkan dialog "Bagikan" dipindahkan ke sini agar rapi
  void _showShareDialog(BuildContext context, String workspaceId, String workspaceTitle) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return BlocProvider(
          create: (_) => sl<ShareWorkspaceBloc>(),
          child: _ShareWorkspaceDialog(workspaceId: workspaceId, workspaceTitle: workspaceTitle),
        );
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    // Pindahkan logika untuk mendapatkan state dan info lain ke dalam build method
    final eventState = context.watch<EventBloc>().state;
    final workspaceId = eventState.events.isNotEmpty ? eventState.events.first.workspaceId : context.findAncestorWidgetOfExactType<_ScheduleDetailView>()!.workspaceId;
    final workspaceTitle = context.findAncestorWidgetOfExactType<_ScheduleDetailView>()!.workspaceTitle;

    // Untuk sementara, kita asumsikan peran adalah 'owner' sampai data peran dinamis diimplementasikan
    const currentUserRole = 'owner';

    return SingleChildScrollView(
       padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Row(
            children: [
              ElevatedButton.icon(
                // PERBAIKAN 2: Perbaiki syntax ternary operator di sini
                onPressed: currentUserRole == 'owner'
                    ? () => _showShareDialog(context, workspaceId, workspaceTitle)
                    : null, // Tombol akan dinonaktifkan jika bukan owner
                icon: const Icon(Icons.share, size: 16),
                label: const Text("Bagikan"),
                style: ElevatedButton.styleFrom(foregroundColor: Colors.white, backgroundColor: const Color(0xFF199df5).withOpacity(0.8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), elevation: 0),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () {},
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
              onPressed: onAddEventPressed,
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

  const _ScheduleSheet(
      {required this.selectedEvents, required this.onEventTap});

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
                    // PERBAIKAN 1: Panggil _ScheduleEventCard dengan parameter yang benar
                    ...value.map((event) {
                      return _ScheduleEventCard(
                        event: event,
                        onTap: () => onEventTap(event),
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
    // PERBAIKAN 2: Ambil data dari objek 'event'
    final startTime = DateFormat.Hm().format(event.startTime);
    final endTime = DateFormat.Hm().format(event.endTime);
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
                  time, // Gunakan variabel yang sudah didefinisikan
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
                      title, // Gunakan variabel yang sudah didefinisikan
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      detail, // Gunakan variabel yang sudah didefinisikan
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

  bool get isEditing => widget.eventToEdit != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _titleController.text = widget.eventToEdit!.title;
      _descriptionController.text = widget.eventToEdit!.description ?? '';
      _startTime = TimeOfDay.fromDateTime(widget.eventToEdit!.startTime);
      _endTime = TimeOfDay.fromDateTime(widget.eventToEdit!.endTime);
    } else {
      _startTime = TimeOfDay.now();
      _endTime =
          TimeOfDay.fromDateTime(DateTime.now().add(const Duration(hours: 1)));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context,
      {required bool isStartTime}) async {
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

  void _onDeletePressed() {
    showDialog(
      context: context,
      builder: (alertDialogContext) => AlertDialog(
        title: const Text('Hapus Event'),
        content: const Text(
            'Anda yakin ingin menghapus event ini? Aksi ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(alertDialogContext).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              context.read<EventBloc>().add(DeleteEventPressed(
                  widget.eventToEdit!.id, widget.workspaceId));
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
          Text(isEditing ? 'Edit Event' : 'Tambah Event',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop()),
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
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Deskripsi',
                style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLength: 60,
              inputFormatters: [LengthLimitingTextInputFormatter(60)],
              maxLines: null,
              decoration: InputDecoration(
                hintText: 'Masukkan Deskripsi Event',
                counterText: "",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTimePickerField(context, 'Mulai', _startTime,
                      isStartTime: true),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTimePickerField(context, 'Selesai', _endTime,
                      isStartTime: false),
                ),
              ],
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
                    final startDateTime = DateTime(
                        widget.selectedDate.year,
                        widget.selectedDate.month,
                        widget.selectedDate.day,
                        _startTime.hour,
                        _startTime.minute);
                    final endDateTime = DateTime(
                        widget.selectedDate.year,
                        widget.selectedDate.month,
                        widget.selectedDate.day,
                        _endTime.hour,
                        _endTime.minute);

                    final updatedEvent = Event(
                      id: widget.eventToEdit!.id,
                      workspaceId: widget.eventToEdit!.workspaceId,
                      createdBy: widget.eventToEdit!.createdAt
                          .toString(), // createdBy tidak berubah
                      title: _titleController.text,
                      description: _descriptionController.text,
                      startTime: startDateTime,
                      endTime: endDateTime,
                      createdAt: widget.eventToEdit!.createdAt,
                    );
                    context
                        .read<EventBloc>()
                        .add(UpdateEventSubmitted(updatedEvent));
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
                final startDateTime = DateTime(
                    widget.selectedDate.year,
                    widget.selectedDate.month,
                    widget.selectedDate.day,
                    _startTime.hour,
                    _startTime.minute);
                final endDateTime = DateTime(
                    widget.selectedDate.year,
                    widget.selectedDate.month,
                    widget.selectedDate.day,
                    _endTime.hour,
                    _endTime.minute);

                context.read<EventBloc>().add(
                      CreateEventSubmitted(
                        workspaceId: widget.workspaceId,
                        title: _titleController.text,
                        description: _descriptionController.text,
                        startTime: startDateTime,
                        endTime: endDateTime,
                      ),
                    );
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Buat Event'),
            ),
          ),
      ],
    );
  }

  Widget _buildTimePickerField(
      BuildContext context, String label, TimeOfDay time,
      {required bool isStartTime}) {
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
                            hintText: 'Emails, atau username',
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
                      email: user.email,
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
