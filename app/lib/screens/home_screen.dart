import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import 'catalog_screen.dart';
import 'cart_screen.dart';
import 'orders_screen.dart';
import 'service_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int i = 0;
  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    if (s.profile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (s.isDealer && !s.dealerApproved) {
      return Scaffold(
        appBar: AppBar(title: const Text('Dealer account')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.hourglass_top, size: 64),
              const SizedBox(height: 12),
              const Text('Your dealer account is awaiting admin approval.',
                  textAlign: TextAlign.center),
              TextButton(onPressed: s.loadProfile, child: const Text('Refresh')),
              TextButton(onPressed: s.logout, child: const Text('Logout')),
            ]),
          ),
        ),
      );
    }
    final pages = [
      const CatalogScreen(), const CartScreen(), const OrdersScreen(),
      const ServiceScreen(), const ProfileScreen()
    ];
    return Scaffold(
      body: pages[i],
      bottomNavigationBar: NavigationBar(
        selectedIndex: i,
        onDestinationSelected: (v) => setState(() => i = v),
        destinations: [
          const NavigationDestination(icon: Icon(Icons.store), label: 'Shop'),
          NavigationDestination(
              icon: Badge(
                  isLabelVisible: s.cart.isNotEmpty,
                  label: Text('${s.cart.length}'),
                  child: const Icon(Icons.shopping_cart)),
              label: 'Cart'),
          const NavigationDestination(icon: Icon(Icons.receipt_long), label: 'Orders'),
          const NavigationDestination(icon: Icon(Icons.build), label: 'Service'),
          const NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
