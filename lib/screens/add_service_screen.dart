import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prueba_tecnica/bloc/service_state.dart';
import 'package:prueba_tecnica/models/service.dart';
import 'package:prueba_tecnica/bloc/service_bloc.dart';
import 'package:prueba_tecnica/bloc/service_event.dart';

class AddServiceScreen extends StatefulWidget {
  const AddServiceScreen({super.key});

  @override
  AddServiceScreenState createState() => AddServiceScreenState();
}

class AddServiceScreenState extends State<AddServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _serviceNameController = TextEditingController();
  final _servicePriceController = TextEditingController();

  String _dayOfWeek = 'Monday';
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 17, minute: 0);

  void _submitForm() {
  if (_formKey.currentState!.validate()) {
    final blocState = BlocProvider.of<ServiceBloc>(context).state;

    if (blocState is ServicesLoaded) {
      final existingServiceForDay = blocState.services.any((service) => service.day == _dayOfWeek);

      if (existingServiceForDay) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('A service is already scheduled on $_dayOfWeek.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    final newService = Service(
      name: _serviceNameController.text,
      price: double.tryParse(_servicePriceController.text) ?? 10.0,
      day: _dayOfWeek,
      startTime: _startTime.format(context),
      endTime: _endTime.format(context),
      minDuration: 30,
      maxDuration: 60,
    );

    BlocProvider.of<ServiceBloc>(context).add(AddService(newService));
    Navigator.pop(context);
  }
}

  Future<void> _pickTimeRange() async {
    final pickedStart = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );

    if (pickedStart != null) {
      final pickedEnd = await showTimePicker(
        context: context,
        initialTime: _endTime,
      );

      if (pickedEnd != null) {
        setState(() {
          _startTime = pickedStart;
          _endTime = pickedEnd;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Add Service'),
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
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _serviceNameController,
                decoration: const InputDecoration(labelText: 'Service Name'),
                validator: (value) => value == null || value.isEmpty ? 'Enter a service name' : null,
              ),
              TextFormField(
                controller: _servicePriceController,
                decoration: const InputDecoration(labelText: 'Service Price'),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty ? 'Enter a price' : null,
              ),
              DropdownButtonFormField<String>(
                value: _dayOfWeek,
                decoration: const InputDecoration(labelText: 'Day of the Week'),
                items: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday']
                    .map((day) => DropdownMenuItem(value: day, child: Text(day)))
                    .toList(),
                onChanged: (value) => setState(() => _dayOfWeek = value!),
              ),
              ListTile(
                title: const Text('Time Range'),
                subtitle: Text('${_startTime.format(context)} to ${_endTime.format(context)}'),
                trailing: const Icon(Icons.access_time),
                onTap: _pickTimeRange,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Add Service'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
