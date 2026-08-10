import 'package:bkkpet/blank_page/appbar.dart';
import 'package:bkkpet/blank_page/app_loading.dart';
import 'package:bkkpet/blank_page/date_format.dart';
import 'package:bkkpet/mock_data.dart';
import 'package:bkkpet/pages/sterilization/sterilization_booking_storage.dart';
import 'package:bkkpet/pages/vaccine/vaccine_booking_storage.dart';
import 'package:bkkpet/services/app_route_observer.dart';
import 'package:bkkpet/services/mock_user_store.dart';
import 'package:bkkpet/style_theme.dart';
import 'package:flutter/material.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key, required this.onTabChange});
  final void Function(int index) onTabChange;

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> with RouteAware {
  DateTime focusedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime selectedDate = DateTime.now();
  PageRoute<dynamic>? _currentRoute;
  List<Map<String, dynamic>> _appointments = [];
  bool _loading = true;

  List<Map<String, dynamic>> get appointments => _appointments;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute && route != _currentRoute) {
      if (_currentRoute != null) {
        appRouteObserver.unsubscribe(this);
      }
      _currentRoute = route;
      appRouteObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    if (mounted) setState(() => _loading = true);

    final vaccineBookings = await VaccineBookingStorage.getAll();
    final sterilizationBookings = await SterilizationBookingStorage.getAll();

    final loaded = <Map<String, dynamic>>[
      ...mockAppointments,
      for (final booking in vaccineBookings)
        for (final pet in booking.pets)
          {
            'id': '${booking.id}-${pet['id'] ?? pet['name'] ?? 'pet'}',
            'petId': pet['id'],
            'petName': pet['name'],
            'petSpecies': pet['species'],
            'service': 'ฉีดวัคซีน',
            'date': booking.dateIso,
            'time': booking.timeSlot,
            'status': booking.status,
            'detail': '${booking.pointName} • ${booking.district}',
          },
      for (final booking in sterilizationBookings)
        {
          'id': booking.id,
          'petId': booking.petId,
          'petName': booking.petName,
          'petSpecies': booking.species,
          'petGender': booking.gender,
          'service': 'ทำหมัน',
          'date': booking.dateIso,
          'time': booking.timeSlot,
          'status': booking.status,
          'detail': '${booking.pointName} • ${booking.district}',
        },
    ];

    loaded.sort((a, b) {
      final dateA =
          DateTime.tryParse(a['date'] as String? ?? '') ?? DateTime(0);
      final dateB =
          DateTime.tryParse(b['date'] as String? ?? '') ?? DateTime(0);
      return dateA.compareTo(dateB);
    });

    if (!mounted) return;
    setState(() {
      _appointments = loaded;
      _loading = false;
    });
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  List<Map<String, dynamic>> eventsOnDay(DateTime selectedDay) {
    return appointments.where((appointment) {
      final appointmentDate = DateTime.parse(appointment['date']);

      return isSameDay(appointmentDate, selectedDay);
    }).toList();
  }

  List<Map<String, dynamic>> get appointmentsForSelectedDate {
    return eventsOnDay(selectedDate);
  }

  void changeMonth(int delta) {
    setState(() {
      focusedMonth = DateTime(focusedMonth.year, focusedMonth.month + delta);
    });
  }

  List<DateTime?> buildMonthCells() {
    final firstDayOfMonth = DateTime(focusedMonth.year, focusedMonth.month, 1);
    final daysInMonth =
        DateTime(focusedMonth.year, focusedMonth.month + 1, 0).day;
    final leadingEmpty = firstDayOfMonth.weekday - 1;

    final cells = <DateTime?>[];
    cells.addAll(List.filled(leadingEmpty, null));
    for (int d = 1; d <= daysInMonth; d++) {
      cells.add(DateTime(focusedMonth.year, focusedMonth.month, d));
    }
    return cells;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarMainApp(
        title: 'นัดหมาย',
        onBack: () => widget.onTabChange(0),
      ),
      body: AppRefreshIndicator(
        onRefresh: _loadAppointments,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: buildCalendar(),
              ),
              const SizedBox(height: 20),
              _loading
                  ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: AppLoadingIndicator(),
                  )
                  : buildAppointmentList(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  buildCalendar() {
    final cells = buildMonthCells();

    final List<List<DateTime?>> weeks = [];
    for (int i = 0; i < cells.length; i += 7) {
      final chunk = cells.sublist(
        i,
        i + 7 > cells.length ? cells.length : i + 7,
      );
      while (chunk.length < 7) {
        chunk.add(null);
      }
      weeks.add(chunk);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => changeMonth(-1),
              ),
              Text(
                DateFormatTH.monthYear(focusedMonth),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => changeMonth(1),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: const Divider(height: 1, color: Color(0xffF1F3F5)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children:
                DateFormatTH.thaiWeekdays
                    .map(
                      (weekday) => Text(
                        weekday,
                        style: TextStyle(
                          color: AppColors.greyscale_400,
                          fontSize: 14,
                        ),
                      ),
                    )
                    .toList(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Column(
            children: weeks.map<Widget>((week) => buildWeekRow(week)).toList(),
          ),
        ),
      ],
    );
  }

  buildWeekRow(List<DateTime?> week) {
    return Row(
      children:
          week.map((day) {
            if (day == null) {
              return const Expanded(child: SizedBox(height: 48));
            }

            final isSelected = isSameDay(day, selectedDate);
            final appointmentsOnSelectedDay = eventsOnDay(day);
            final dotCount =
                appointmentsOnSelectedDay.length > 3
                    ? 3
                    : appointmentsOnSelectedDay.length;

            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() => selectedDate = day);
                },
                child: SizedBox(
                  height: 48,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? AppColors.greenlight
                                  : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${day.day}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight:
                                isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      SizedBox(
                        height: 5,
                        child:
                            dotCount == 0
                                ? null
                                : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    dotCount,
                                    (i) => Container(
                                      width: 5,
                                      height: 5,
                                      margin: EdgeInsets.symmetric(
                                        horizontal: dotCount > 1 ? 1.5 : 0,
                                      ),
                                      decoration: const BoxDecoration(
                                        color: AppColors.primarySecondary,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  buildAppointmentList() {
    final selectedAppointments = appointmentsForSelectedDate;

    if (selectedAppointments.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Text(
          'ไม่มีนัดหมายในวันที่เลือก',
          style: TextStyle(color: Colors.grey[500], fontSize: 15),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children:
            selectedAppointments
                .map(
                  (a) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: buildAppointmentCard(a),
                  ),
                )
                .toList(),
      ),
    );
  }

  buildAppointmentCard(Map<String, dynamic> appointment) {
    final DateTime date = DateTime.parse(appointment['date']);
    final pet = MockUserStore.findPetById(appointment['petId'] as String?);
    final petName =
        pet?.name ?? appointment['petName'] as String? ?? 'สัตว์เลี้ยง';
    final petGender =
        pet?.gender ??
        appointment['petGender'] as String? ??
        appointment['petSpecies'] as String? ??
        'ไม่ระบุ';
    final petImage = pet?.image;
    final detail = appointment['detail'] as String? ?? '';
    final status = appointment['status'] as String? ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.greyscale_200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.primaryLight.withValues(alpha: 0.45),
                backgroundImage:
                    petImage == null || petImage.isEmpty
                        ? null
                        : AssetImage(petImage),
                child:
                    petImage == null || petImage.isEmpty
                        ? const Icon(
                          Icons.pets_rounded,
                          color: AppColors.primary,
                        )
                        : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      petName,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      petGender,
                      style: TextStyle(color: Colors.grey[500], fontSize: 13),
                    ),
                  ],
                ),
              ),
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Image.asset('assets/icons/icon_syringe.png', height: 20),
                // Icon(Icons.vaccines, color: AppColors.primary, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.greyscale_25,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'บริการ',
                        style: TextStyle(
                          color: AppColors.greyscale_300,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        appointment['service'],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 34, color: Colors.grey.shade300),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormatTH.shortDate(date),
                        style: TextStyle(color: Colors.grey[500], fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        appointment['time'],
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (status.isNotEmpty || detail.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (status.isNotEmpty)
                  _AppointmentInfoChip(
                    icon: Icons.verified_rounded,
                    label: status,
                    color: AppColors.primary,
                  ),
                if (detail.isNotEmpty)
                  _AppointmentInfoChip(
                    icon: Icons.notes_rounded,
                    label: detail,
                    color: AppColors.greyscale_800,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _AppointmentInfoChip extends StatelessWidget {
  const _AppointmentInfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width - 64,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
