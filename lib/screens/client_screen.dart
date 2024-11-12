import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prueba_tecnica/screens/booking_screen.dart';
import 'package:prueba_tecnica/bloc/service_bloc.dart';
import 'package:prueba_tecnica/bloc/service_state.dart';

class ClientScreen extends StatefulWidget {
  const ClientScreen({super.key});

  @override
  ClientScreenState createState() => ClientScreenState();
}

class ClientScreenState extends State<ClientScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Client - Services'),
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
          if (state is ServicesLoaded) {
            final services = state.services;
            if (services.isEmpty) {
              return const Center(
                child: Text(
                  'No services available at the moment.',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              );
            }
            return ListView.builder(
              itemCount: services.length,
              itemBuilder: (context, index) {
                final service = services[index];
                return ListTile(
                  title: Text(service.name),
                  subtitle: Text('Price: \$${service.price}'),
                  trailing: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookingScreen(service: service),
                        ),
                      );
                    },
                    child: const Text('Book Now'),
                  ),
                );
              },
            );
          } else if (state is ServicesLoading) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return const Center(child: Text('Failed to load services'));
          }
        },
      ),
    );
  }
}
