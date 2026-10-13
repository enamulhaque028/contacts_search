import 'package:contacts_search/features/contacts/domain/entities/contact.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'paginated_contacts.freezed.dart';

@freezed
abstract class PaginatedContacts with _$PaginatedContacts {
  const factory PaginatedContacts({
    required List<Contact> contacts,
    required int page,
    required bool hasMore,
  }) = _PaginatedContacts;
}
