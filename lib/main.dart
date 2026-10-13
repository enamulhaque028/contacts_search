import 'package:contacts_search/app.dart';
import 'package:contacts_search/core/di/injection.dart';
import 'package:flutter/material.dart';

void main() {
  configureDependencies();
  runApp(const ContactsApp());
}
