import 'package:contacts_search/features/contacts/data/models/contact_model.dart';
import 'package:contacts_search/features/contacts/data/models/pagination_meta_model.dart';
import 'package:contacts_search/features/contacts/domain/entities/paginated_contacts.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'contacts_response_model.freezed.dart';
part 'contacts_response_model.g.dart';

/// `GET /contacts` response:
///
/// ```json
/// {
///   "data": [{ "id": "1", "name": "...", "phone": "..." }],
///   "meta": { "page": 1, "limit": 20, "total": 30 }
/// }
/// ```
@freezed
abstract class ContactsResponseModel with _$ContactsResponseModel {
  const factory ContactsResponseModel({
    @JsonKey(name: 'data') required List<ContactModel> contacts,
    required PaginationMetaModel meta,
  }) = _ContactsResponseModel;

  const ContactsResponseModel._();

  factory ContactsResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ContactsResponseModelFromJson(json);

  PaginatedContacts toEntity() => PaginatedContacts(
    contacts: contacts.map((model) => model.toEntity()).toList(),
    page: meta.page,
    hasMore: meta.hasMore,
  );
}
