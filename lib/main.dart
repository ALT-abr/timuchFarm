
import 'package:flutter/material.dart';
import 'package:timuchmilk/database/app_database.dart';
import 'package:timuchmilk/screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppDatabase.instance.initialize();
  runApp(const TimuchMilk());
}

class TimuchMilk extends StatelessWidget {
  const TimuchMilk({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Timuch Milk',
      home: const HomePage(),
    );
  }
}
