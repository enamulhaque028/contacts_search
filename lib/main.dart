import 'package:flutter/material.dart';

void main() {
  runApp(const ContactsApp());
}

class ContactsApp extends StatelessWidget {
  const ContactsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Contacts Search',
      home: Scaffold(
        body: Center(
          child: Text('Contacts Search'),
        ),
      ),
    );
  }
}
