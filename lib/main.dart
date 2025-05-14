import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'screens/standby.dart';
import 'screens/rent.dart';
import 'screens/return.dart';
import 'screens/drying.dart';
import 'screens/after_rent.dart';
import 'screens/after_return.dart'; // ✅ 추가

void main() {
  runApp(const MyApp());
}

final GoRouter _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const StandbyScreen()),
    GoRoute(path: '/rent', builder: (context, state) => const RentScreen()),
    GoRoute(path: '/return', builder: (context, state) => const ReturnScreen()),
    GoRoute(path: '/drying', builder: (context, state) => const DryingScreen()),
    GoRoute(
      path: '/after_rent',
      pageBuilder: (context, state) => CustomTransitionPage(
        child: const AfterRentScreen(),
        transitionDuration: const Duration(milliseconds: 1000),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return child;
        },
      ),
    ),
    GoRoute(
      path: '/after_return',
      pageBuilder: (context, state) => CustomTransitionPage(
        child: const AfterReturnScreen(),
        transitionDuration: const Duration(milliseconds: 1000),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return child;
        },
      ),
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      title: 'Umbrella Rental App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
    );
  }
}
