import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// these are the other screens you created
import 'login_page.dart';
import 'home_page.dart';

Future<void> main() async {
  // Make sure Flutter is ready before we call async stuff
  WidgetsFlutterBinding.ensureInitialized();

  // YOUR Supabase project details
  const supabaseUrl = 'https://jgdbcbqmmewvrfyiekwx.supabase.co';
  const supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpnZGJjYnFtbWV3dnJmeWlla3d4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ1OTgxODQsImV4cCI6MjA4MDE3NDE4NH0.BITzvmKe9vPOoiPx7Xb0JEoRLsmMXrKd9L-B3jQkcvY'; // paste from Supabase → Settings → API (anon public key)

  // Initialize Supabase for the app
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if user is already logged in
    final session = Supabase.instance.client.auth.currentSession;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Stick Parent',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      // If no session -> show LoginPage, otherwise go directly to HomePage
      home: session == null ? const LoginPage() : const HomePage(),
    );
  }
}
