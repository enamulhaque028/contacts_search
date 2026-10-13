import 'package:contacts_search/core/error/app_exception.dart';
import 'package:contacts_search/features/contacts/data/models/contacts_response_model.dart';

/// A real implementation would call `GET /contacts?page=&limit=&search=` and
/// throw an [AppException] when it fails.
abstract interface class ContactsRemoteDataSource {
  Future<ContactsResponseModel> fetchContacts({
    required int page,
    required int limit,
    String? search,
  });
}
