import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prueba_tecnica/bloc/service_bloc.dart';
import 'package:prueba_tecnica/bloc/service_event.dart';
import 'package:prueba_tecnica/screens/add_service_screen.dart';
import 'package:prueba_tecnica/screens/client_screen.dart';
import 'package:prueba_tecnica/screens/login_screen.dart';

void main() {
  runApp(
    BlocProvider(
      create: (context) => ServiceBloc()..add(LoadServices()),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Service App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/client': (context) => const ClientScreen(),
        '/addService' :(context) => const AddServiceScreen(),
      },
    );
  }
}
