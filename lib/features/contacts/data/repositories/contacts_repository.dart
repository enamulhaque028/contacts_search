import 'package:contacts_search/core/error/app_exception.dart';
import 'package:contacts_search/features/contacts/data/datasources/contacts_remote_data_source.dart';
import 'package:contacts_search/features/contacts/domain/entities/paginated_contacts.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class ContactsRepository {
  const ContactsRepository(this._remoteDataSource);

  final ContactsRemoteDataSource _remoteDataSource;

  /// [page] starts from 1. An empty [search] returns everyone.
  /// Throws an [AppException] when the request fails.
  Future<PaginatedContacts> getContacts({
    required int page,
    required int limit,
    String? search,
  }) async {
    final query = search?.trim();

    final response = await _remoteDataSource.fetchContacts(
      page: page,
      limit: limit,
      search: (query == null || query.isEmpty) ? null : query,
    );

    return response.toEntity();
  }
}
