import 'package:contacts_search/core/utils/phone_formatter.dart';
import 'package:contacts_search/features/contacts/domain/entities/contact.dart';
import 'package:flutter/material.dart';

class ContactListTile extends StatelessWidget {
  const ContactListTile({required this.contact, super.key});

  final Contact contact;

  @override
  Widget build(BuildContext context) {
    final phone = formatPhoneNumber(contact.phone);

    return ListTile(
      leading: CircleAvatar(child: Text(_initials(contact.name))),
      title: Text(contact.name),
      subtitle: Text(phone),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    return parts
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();
  }
}
