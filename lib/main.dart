import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:loginapp/firebase/firebase_options.dart';
import 'package:loginapp/screens/home.dart';
import 'package:loginapp/screens/signup_signin.dart';
import 'package:loginapp/utils/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: SignUpSignIn(),
      routes: {
        AppRoutes.logincad: (ctx) => SignUpSignIn(),
        AppRoutes.home: (ctx) => Home(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
