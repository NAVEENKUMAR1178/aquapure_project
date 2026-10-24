import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/app_state.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // uses android/app/google-services.json
  final state = AppState();
  await state.loadProfile();
  runApp(ChangeNotifierProvider.value(value: state, child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'AquaPure',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            colorSchemeSeed: const Color(0xFF1E88E5), useMaterial3: true),
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (_, s) =>
              s.data == null ? const AuthScreen() : const HomeScreen(),
        ),
      );
}
