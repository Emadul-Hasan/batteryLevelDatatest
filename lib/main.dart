import 'package:flutter/material.dart';

import 'screen/HomePage.dart';
import 'screen/discover.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: DiscoverPage.id,
      routes: {
        DiscoverPage.id: (context) => DiscoverPage(),
        Homepage.id: (context) => Homepage(),
      },
    );
  }
}
