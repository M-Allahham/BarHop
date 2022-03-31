//@dart=2.9
import 'package:barhop/map.dart';
import 'package:barhop/places.dart';
import 'package:barhop/deals.dart';
import 'package:barhop/social.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    Phoenix(
      child: MyApp(),
    ),
  );
}

Map<int, Color> colorCodes = {
  50: const Color.fromRGBO(255, 255, 255, .1),
  100: const Color.fromRGBO(255, 255, 255, .2),
  200: const Color.fromRGBO(255, 255, 255, .3),
  300: const Color.fromRGBO(255, 255, 255, .4),
  400: const Color.fromRGBO(255, 255, 255, .5),
  500: const Color.fromRGBO(255, 255, 255, .6),
  600: const Color.fromRGBO(255, 255, 255, .7),
  700: const Color.fromRGBO(255, 255, 255, .8),
  800: const Color.fromRGBO(255, 255, 255, .9),
  900: const Color.fromRGBO(255, 255, 255, 1),
};

Map<int, Color> colorCodesGrey900 = {
  50: const Color.fromARGB(0xFF, 0x21, 0x21, 0x21),
  100: const Color.fromARGB(0xFF, 0x21, 0x21, 0x21),
  200: const Color.fromARGB(0xFF, 0x21, 0x21, 0x21),
  300: const Color.fromARGB(0xFF, 0x21, 0x21, 0x21),
  400: const Color.fromARGB(0xFF, 0x21, 0x21, 0x21),
  500: const Color.fromARGB(0xFF, 0x21, 0x21, 0x21),
  600: const Color.fromARGB(0xFF, 0x21, 0x21, 0x21),
  700: const Color.fromARGB(0xFF, 0x21, 0x21, 0x21),
  800: const Color.fromARGB(0xFF, 0x21, 0x21, 0x21),
  900: const Color.fromARGB(0xFF, 0x21, 0x21, 0x21),
};

class MyApp extends StatelessWidget {
  final MaterialColor whiteColor = MaterialColor(0xFF212121, colorCodesGrey900);

  MyApp({Key key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BarHop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: whiteColor,
      ),
      home: const MyHomePage(title: 'BarHop'),
      routes: {
        '/success': (_) => const MyHomePage(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({Key key, this.title}) : super(key: key);
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  MaterialColor whiteColor = MaterialColor(0xFFFFFFFF, colorCodes);
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.map_outlined,
            ),
            label: "Map",
          ),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
              ),
              label: "Places"),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.file_copy_outlined,
              ),
              label: "Deals"),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.person,
              ),
              label: "Social"),
        ],
        currentIndex: _selectedIndex,
        backgroundColor: Colors.grey.shade900,
        selectedItemColor: Colors.yellow.withOpacity(0.65),
        unselectedItemColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
      ),
      body: IndexedStack(
        children: <Widget>[
          GMap(),
          const Places(),
          const Deals(),
          const Social(),
        ],
        index: _selectedIndex,
      ),
    );
  }
}
