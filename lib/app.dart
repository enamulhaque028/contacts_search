import 'package:contacts_search/core/theme/app_theme.dart';
import 'package:contacts_search/features/contacts/presentation/screens/contacts_screen.dart';
import 'package:flutter/material.dart';

class ContactsApp extends StatelessWidget {
  const ContactsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contacts Search',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: const ContactsScreen(),
    );
  }
}
