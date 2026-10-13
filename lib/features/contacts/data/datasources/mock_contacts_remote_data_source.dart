import 'dart:math';

import 'package:contacts_search/core/error/app_exception.dart';
import 'package:contacts_search/features/contacts/data/datasources/contacts_remote_data_source.dart';
import 'package:contacts_search/features/contacts/data/datasources/mock_contacts_seed.dart';
import 'package:contacts_search/features/contacts/data/models/contacts_response_model.dart';
import 'package:injectable/injectable.dart';

/// Fake backend for the task dataset. Requests are slow and sometimes fail on
/// purpose, so the loading and error states can be checked.
@LazySingleton(as: ContactsRemoteDataSource)
class MockContactsRemoteDataSource implements ContactsRemoteDataSource {
  /// Out of 100 requests. Run with `--dart-define=MOCK_FAILURE_PERCENT=0`
  /// to turn errors off.
  static const failurePercent = int.fromEnvironment(
    'MOCK_FAILURE_PERCENT',
    defaultValue: 20,
  );

  static final _phoneLike = RegExp(r'^\+?[\d ]+$');

  final _random = Random();

  @override
  Future<ContactsResponseModel> fetchContacts({
    required int page,
    required int limit,
    String? search,
  }) async {
    // 500–1000 ms
    await Future<void>.delayed(
      Duration(milliseconds: 500 + _random.nextInt(501)),
    );

    if (_random.nextInt(100) < failurePercent) {
      throw const ServerException(statusCode: 500);
    }

    final matches = _filter(search);
    final pageItems = matches.skip((page - 1) * limit).take(limit).toList();

    // Parse it like a real response instead of building models directly.
    final json = <String, dynamic>{
      'data': pageItems,
      'meta': {'page': page, 'limit': limit, 'total': matches.length},
    };

    return ContactsResponseModel.fromJson(json);
  }

  List<Map<String, dynamic>> _filter(String? search) {
    final query = search?.trim().toLowerCase() ?? '';
    if (query.isEmpty) return mockContactsSeed;

    // So that "901 234" also finds "+421901234567".
    final isPhoneQuery = _phoneLike.hasMatch(query);
    final phoneQuery = query.replaceAll(' ', '');

    return mockContactsSeed.where((contact) {
      final name = (contact['name'] as String).toLowerCase();
      final phone = contact['phone'] as String;

      return name.contains(query) ||
          (isPhoneQuery && phone.contains(phoneQuery));
    }).toList();
  }
}
