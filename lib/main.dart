import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/main_menu_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  // TODO: Replace with your Supabase credentials
  await Supabase.initialize(
    url: 'https://zxixsaxepynkyocjinjx.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inp4aXhzYXhlcHlua3lvY2ppbmp4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzAxNjg2MTAsImV4cCI6MjA4NTc0NDYxMH0.aywIjCL2VvzyUO1pcdbd0hr1ddoZwl2ufrx-JC3CN2E',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Survey Kepuasan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const MainMenuScreen(),
    );
  }
}
