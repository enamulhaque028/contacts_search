final _slovakNumber = RegExp(r'^\+(\d{3})(\d{3})(\d{3})(\d{3})$');

/// `+421901234567` -> `+421 901 234 567`. Anything else is returned unchanged.
String formatPhoneNumber(String phone) {
  final match = _slovakNumber.firstMatch(phone);
  if (match == null) return phone;

  return '+${match[1]} ${match[2]} ${match[3]} ${match[4]}';
}
