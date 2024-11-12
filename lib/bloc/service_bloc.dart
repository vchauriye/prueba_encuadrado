import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'service_event.dart';
import 'service_state.dart';
import 'package:prueba_tecnica/models/service.dart';

class ServiceBloc extends Bloc<ServiceEvent, ServiceState> {
  ServiceBloc() : super(ServicesLoading()) {
    on<LoadServices>(_onLoadServices);
    on<AddService>(_onAddService);
    on<DeleteService>(_onDeleteService);
    on<BookService>(_onBookService);
  }

  Future<void> _onLoadServices(LoadServices event, Emitter<ServiceState> emit) async {
    emit(ServicesLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final servicesList = prefs.getStringList('services') ?? [];
      final services = servicesList.map((e) => Service.fromJson(e)).toList();
      final bookingsList = prefs.getStringList('bookings') ?? [];
      final bookings = bookingsList.map((e) => json.decode(e) as Map<String, dynamic>).toList();

      emit(ServicesLoaded(services, bookings));
    } catch (e) {
      emit(ServicesError());
    }
  }

  Future<void> _onAddService(AddService event, Emitter<ServiceState> emit) async {
    if (state is ServicesLoaded) {
      final updatedServices = List<Service>.from((state as ServicesLoaded).services)..add(event.service);
      final updatedBookings = List<Map<String, dynamic>>.from((state as ServicesLoaded).bookings);

      await _saveServices(updatedServices);
      await _saveBookings(updatedBookings);

      emit(ServicesLoaded(updatedServices, updatedBookings));
    }
  }

  Future<void> _onDeleteService(DeleteService event, Emitter<ServiceState> emit) async {
    if (state is ServicesLoaded) {
      final updatedServices = List<Service>.from((state as ServicesLoaded).services)..remove(event.service);
      final updatedBookings = List<Map<String, dynamic>>.from((state as ServicesLoaded).bookings);

      await _saveServices(updatedServices);
      await _saveBookings(updatedBookings);

      emit(ServicesLoaded(updatedServices, updatedBookings));
    }
  }

  Future<void> _onBookService(BookService event, Emitter<ServiceState> emit) async {
    if (state is ServicesLoaded) {
      final updatedBookings = List<Map<String, dynamic>>.from((state as ServicesLoaded).bookings);

      bool hasConflict = updatedBookings.any((booking) {
        return booking['serviceName'] == event.service.name &&
               booking['day'] == event.day && 
               _timesOverlap(event.startTime, event.endTime, booking['startTime'], booking['endTime']);
      });

      if (!hasConflict) {
        updatedBookings.add({
          'serviceName': event.service.name,
          'day': event.day,
          'startTime': event.startTime,
          'endTime': event.endTime,
        });

        await _saveBookings(updatedBookings);
        emit(ServicesLoaded((state as ServicesLoaded).services, updatedBookings));
      } else {
        emit(ServicesError());
      }
    }
  }

  bool _timesOverlap(String startA, String endA, String startB, String endB) {
    final startATime = DateTime.parse("1970-01-01 $startA:00");
    final endATime = DateTime.parse("1970-01-01 $endA:00");
    final startBTime = DateTime.parse("1970-01-01 $startB:00");
    final endBTime = DateTime.parse("1970-01-01 $endB:00");

    return startATime.isBefore(endBTime) && endATime.isAfter(startBTime);
  }

  Future<void> _saveServices(List<Service> services) async {
    final prefs = await SharedPreferences.getInstance();
    final servicesList = services.map((service) => service.toJson()).toList();
    await prefs.setStringList('services', servicesList);
  }

  Future<void> _saveBookings(List<Map<String, dynamic>> bookings) async {
    final prefs = await SharedPreferences.getInstance();
    final bookingsList = bookings.map((booking) => json.encode(booking)).toList();
    await prefs.setStringList('bookings', bookingsList);
  }
}

