import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prueba_tecnica/bloc/service_bloc.dart';
import 'package:prueba_tecnica/bloc/service_event.dart';
import 'package:prueba_tecnica/bloc/service_state.dart';
import 'package:prueba_tecnica/models/service.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  CalendarScreenState createState() => CalendarScreenState();
}

class CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.week;

  @override
  void initState() {
    super.initState();
    BlocProvider.of<ServiceBloc>(context).add(LoadServices());
  }

  List<Service> _getBookingsForDay(DateTime day, List<Map<String, dynamic>> bookings) {
  final selectedWeekday = DateFormat('EEEE').format(day);

  return bookings
      .where((booking) => booking['day'] == selectedWeekday)
      .map((booking) {
    return Service(
      name: booking['serviceName'] ?? 'Unnamed Service',
      price: booking['price'] ?? 0,
      day: selectedWeekday,
      startTime: booking['startTime'] ?? '00:00',
      endTime: booking['endTime'] ?? '23:59',
      minDuration: booking['minDuration'] ?? 0,
      maxDuration: booking['maxDuration'] ?? 0,
    );
  }).toList();
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Admin Calendar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: BlocBuilder<ServiceBloc, ServiceState>(
        builder: (context, state) {
          if (state is ServicesLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ServicesLoaded) {
            final bookingsForDay =
                _getBookingsForDay(_selectedDate, state.bookings);

            return Column(
              children: [
                TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2100, 12, 31),
                  focusedDay: _selectedDate,
                  calendarFormat: _calendarFormat,
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  onFormatChanged: (format) =>
                      setState(() => _calendarFormat = format),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDate = selectedDay;
                    });
                  },
                  selectedDayPredicate: (day) => isSameDay(day, _selectedDate),
                ),
                Expanded(
                  child: _buildGrid(bookingsForDay),
                ),
              ],
            );
          } else {
            return const Center(child: Text('Failed to load services'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newService = await Navigator.pushNamed(context, '/addService');
          if (newService != null && newService is Service) {
            BlocProvider.of<ServiceBloc>(context).add(AddService(newService));
          }
        },
        tooltip: 'Add Service',
        child: const Icon(Icons.add),
      ),
    );
  }

Widget _buildGrid(List<Service> servicesForDay) {
  List<Widget> gridChildren = [];

  for (int i = 0; i < 24; i++) {
    final currentTime = TimeOfDay(hour: i, minute: 0);

    bool isBooked = servicesForDay.any((service) {
      final bookingStart = TimeOfDay(
        hour: int.parse(service.startTime.split(':')[0]),
        minute: int.parse(service.startTime.split(':')[1]),
      );
      final bookingEnd = TimeOfDay(
        hour: int.parse(service.endTime.split(':')[0]),
        minute: int.parse(service.endTime.split(':')[1]),
      );

      return currentTime.hour >= bookingStart.hour &&
             currentTime.hour < bookingEnd.hour;
    });

    final serviceForTime = servicesForDay.firstWhere(
      (service) {
        final bookingStart = TimeOfDay(
          hour: int.parse(service.startTime.split(':')[0]),
          minute: int.parse(service.startTime.split(':')[1]),
        );
        final bookingEnd = TimeOfDay(
          hour: int.parse(service.endTime.split(':')[0]),
          minute: int.parse(service.endTime.split(':')[1]),
        );
        return currentTime.hour >= bookingStart.hour &&
               currentTime.hour < bookingEnd.hour;
      },
      orElse: () => Service(
        name: '',
        price: 0,
        day: '',
        startTime: '',
        endTime: '',
        minDuration: 0,
        maxDuration: 0,
      ),
    );

    gridChildren.add(
      Row(
        children: [
          Container(
            width: 60,
            padding: const EdgeInsets.all(8.0),
            alignment: Alignment.centerRight,
            child: Text('${currentTime.hour}:00'),
          ),
          Expanded(
            child: Container(
              height: 60.0,
              margin: const EdgeInsets.symmetric(vertical: 5),
              color: isBooked
                  ? Colors.redAccent.withOpacity(0.6) 
                  : Colors.grey.withOpacity(0.3),
              child: serviceForTime.name.isNotEmpty
                  ? ListTile(
                      title: Text(serviceForTime.name,
                          style: const TextStyle(color: Colors.white)),
                      subtitle: Text(
                        '${serviceForTime.startTime} - ${serviceForTime.endTime}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  return SingleChildScrollView(
    child: Column(
      children: gridChildren,
    ),
  );
}

}

extension DateTimeCompare on DateTime {
  bool isSameDay(DateTime other) {
    return year == other.year &&
        month == other.month &&
        day == other.day;
  }
}
