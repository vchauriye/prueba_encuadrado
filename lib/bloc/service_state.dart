import 'package:equatable/equatable.dart';
import 'package:prueba_tecnica/models/service.dart';

abstract class ServiceState extends Equatable {
  @override
  List<Object> get props => [];
}

class ServicesLoading extends ServiceState {}

class ServicesLoaded extends ServiceState {
  final List<Service> services;
  final List<Map<String, dynamic>> bookings;

  ServicesLoaded(this.services, this.bookings);

  @override
  List<Object> get props => [services, bookings];
}

class ServicesError extends ServiceState {}
