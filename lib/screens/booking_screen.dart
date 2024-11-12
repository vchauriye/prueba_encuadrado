import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:prueba_tecnica/bloc/service_state.dart';
import 'package:prueba_tecnica/models/service.dart';
import 'package:prueba_tecnica/bloc/service_bloc.dart';
import 'package:prueba_tecnica/bloc/service_event.dart';

class BookingScreen extends StatefulWidget {
  final Service service;

  const BookingScreen({super.key, required this.service});

  @override
  BookingScreenState createState() => BookingScreenState();
}

class BookingScreenState extends State<BookingScreen> {
  String? _selectedStartTime;
  String? _selectedEndTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Book ${widget.service.name} (${widget.service.day})'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Service is available on: ${widget.service.day}'),

            // Start Time Dropdown
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Select Start Time'),
              value: _selectedStartTime,
              items: _getAvailableTimes()
                  .map((time) => DropdownMenuItem(
                        value: time,
                        child: Text(time),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedStartTime = value;
                  _selectedEndTime = null;
                });
              },
              validator: (value) =>
                  value == null ? 'Please select a start time' : null,
            ),

            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Select End Time'),
              value: _selectedEndTime,
              items: _getAvailableTimes(startFrom: _selectedStartTime)
                  .map((time) => DropdownMenuItem(
                        value: time,
                        child: Text(time),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedEndTime = value;
                });
              },
              validator: (value) =>
                  value == null ? 'Please select an end time' : null,
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed:
                  (_selectedStartTime == null || _selectedEndTime == null)
                      ? null
                      : _bookService,
              child: const Text('Confirm Booking'),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _getAvailableTimes({String? startFrom}) {
    List<String> times = [];
    DateTime start = DateFormat('HH:mm').parse(widget.service.startTime);
    DateTime end = DateFormat('HH:mm').parse(widget.service.endTime);

    if (startFrom != null) {
      start =
          DateFormat('HH:mm').parse(startFrom).add(const Duration(hours: 1));
    }

    while (start.isBefore(end)) {
      final timeString = DateFormat('HH:mm').format(start);

      if (!_isTimeBooked(timeString)) {
        times.add(timeString);
      }
      start = start.add(const Duration(hours: 1));
    }

    return times;
  }

  bool _isTimeBooked(String time) {
    final blocState = BlocProvider.of<ServiceBloc>(context).state;
    if (blocState is ServicesLoaded) {
      final existingBookings = blocState.bookings;
      final selectedTime = DateTime.parse("1970-01-01 $time:00");
      final serviceDay = widget.service.day;

      for (var booking in existingBookings) {
        if (booking['day'] == serviceDay) {
          final start = DateTime.parse("1970-01-01 ${booking['startTime']}:00");
          final end = DateTime.parse("1970-01-01 ${booking['endTime']}:00");

          if (selectedTime.isAtSameMomentAs(start) ||
              (selectedTime.isAfter(start) && selectedTime.isBefore(end))) {
            return true;
          }
        }
      }
    }
    return false;
  }

  void _bookService() {
    if (_selectedStartTime == null || _selectedEndTime == null) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Confirm Booking',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Service Details',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.blueAccent),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.calendar_today,
                      color: Colors.blueAccent, size: 20),
                  const SizedBox(width: 8),
                  Text(widget.service.day,
                      style: const TextStyle(fontSize: 16)),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.access_time,
                      color: Colors.blueAccent, size: 20),
                  const SizedBox(width: 8),
                  Text('$_selectedStartTime - $_selectedEndTime',
                      style: const TextStyle(fontSize: 16)),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.monetization_on,
                      color: Colors.blueAccent, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '\$${_calculateTotalPrice().toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const Divider(height: 30, thickness: 1),
              const Center(
                child: Text(
                  'Do you want to confirm this booking?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); 
              },
              child: const Text('Cancel',
                  style: TextStyle(color: Colors.red, fontSize: 16)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _confirmBooking(); 
              },
              child: const Text('Confirm',
                  style: TextStyle(color: Colors.green, fontSize: 16)),
            ),
          ],
        );
      },
    );
  }

  double _calculateTotalPrice() {
    final start = DateFormat('HH:mm').parse(_selectedStartTime!);
    final end = DateFormat('HH:mm').parse(_selectedEndTime!);

    final duration = end.difference(start).inMinutes / 60.0;

    return widget.service.price * duration;
  }

  void _confirmBooking() {
    BlocProvider.of<ServiceBloc>(context).add(
      BookService(
        service: widget.service,
        day: widget.service.day,
        startTime: _selectedStartTime!,
        endTime: _selectedEndTime!,
      ),
    );

    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Booking Confirmed'),
        content: Text(
          'You have successfully booked ${widget.service.name} every ${widget.service.day} '
          'from $_selectedStartTime to $_selectedEndTime.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
