import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:tradie/core/theme/app_text_styles.dart';
import 'package:tradie/features/schedule/widgets/add_event_sheet.dart';
import '../models/schedule_model.dart';
import '../viewmodels/schedule_viewmodel.dart';

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime(
      _focusedDay.year,
      _focusedDay.month,
      _focusedDay.day,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheduleState = ref.watch(scheduleViewModelProvider);

    // Group schedules by date
    Map<DateTime, List<ScheduleModel>> events = {};
    for (var appt in scheduleState.schedules) {
      final date = DateTime(
        appt.startDate.year,
        appt.startDate.month,
        appt.startDate.day,
      );
      events[date] = (events[date] ?? [])..add(appt);
    }

    // Events for selected day
    final selectedEvents = events[_selectedDay] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text('Schedules', style: AppTextStyles.appBarTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (scheduleState.isLoading) const LinearProgressIndicator(),

            /// 📅 Calendar
            SizedBox(
              height: 400,
              child: TableCalendar<ScheduleModel>(
                firstDay: DateTime(2000, 1, 1),
                lastDay: DateTime.utc(2100, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
                eventLoader: (day) =>
                    events[DateTime(day.year, day.month, day.day)] ?? [],
                startingDayOfWeek: StartingDayOfWeek.monday,
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = DateTime(
                      selectedDay.year,
                      selectedDay.month,
                      selectedDay.day,
                      
                    );
                    _focusedDay = focusedDay;
                  });
                },
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  leftChevronIcon: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.chevron_left,
                      color: Colors.black87,
                      size: 22,
                    ),
                  ),
                  rightChevronIcon: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.chevron_right,
                      color: Colors.black87,
                      size: 22,
                    ),
                  ),
                ),
                daysOfWeekStyle: const DaysOfWeekStyle(
                  weekdayStyle: TextStyle(color: Color(0xFFB3B3B3)),
                  weekendStyle: TextStyle(
                    color: Color(0xFFFF0000),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                calendarStyle: const CalendarStyle(
                  outsideDaysVisible: false,
                  markerDecoration: BoxDecoration(
                    color: Color(0xFF17A1FA),
                    shape: BoxShape.circle,
                  ),
                ),
                calendarBuilders: CalendarBuilders(
                  todayBuilder: (context, day, focused) {
                    return Center(
                      child: Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                          color: const Color(0xFF3066BE),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${day.day}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                  defaultBuilder: (context, day, focusedDay) {
                    final isWeekend =
                        day.weekday == DateTime.saturday ||
                        day.weekday == DateTime.sunday;

                    return Center(
                      child: Text(
                        '${day.day}',
                        style: TextStyle(
                          color: isWeekend
                              ? const Color(0xFFFF0000)
                              : const Color(0xFFB3B3B3),
                          fontWeight: isWeekend
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: selectedEvents.isEmpty
                  ? const Center(
                      child: Text(
                        'No events for this day',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: selectedEvents.length,
                      itemBuilder: (context, index) {
                        final event = selectedEvents[index];
                        final color = Color(
                          int.parse(event.color.replaceFirst('#', '0xff')),
                        );

                        return Column(
                          children: [
                            Row(
                              children: [
                                Text(DateFormat('hh:mm a').format(event.startDate)),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10,),
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: color, // dynamic color here
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 20,),
                                Expanded(
                                  child: Card(
                                  color: color,
                                  margin: const EdgeInsets.symmetric(vertical: 6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ListTile(
                                    title: Text(event.title),
                                    subtitle: Text(event.description),
                                    trailing: event.rescheduledAt != null
                                      ? Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.blue[800],
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Text(
                                            'Rescheduled',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        )
                                      : null,
                                      onTap: () {
                                        context.push('/job-details', extra: event);
                                      },
                                  ),
                                )
                                )
                              ],
                            )
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        backgroundColor: const Color(0xFF090C9B),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            builder: (context) => const AddEventSheet(),
          );
        },
        child: const Icon(Icons.add, size: 28, color: Colors.white),
      ),
    );
  }
}
