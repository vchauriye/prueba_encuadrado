import 'package:equatable/equatable.dart';
import 'package:prueba_tecnica/models/service.dart';

abstract class ServiceEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadServices extends ServiceEvent {}

class AddService extends ServiceEvent {
  final Service service;

  AddService(this.service);

  @override
  List<Object> get props => [service];
}

class DeleteService extends ServiceEvent {
  final Service service;

  DeleteService(this.service);

  @override
  List<Object> get props => [service];
}

class BookService extends ServiceEvent {
  final Service service;
  final String day;
  final String startTime;
  final String endTime;

  BookService({
    required this.service,
    required this.day, 
    required this.startTime,
    required this.endTime,
  });

  @override
  List<Object> get props => [service, day, startTime, endTime];
}
