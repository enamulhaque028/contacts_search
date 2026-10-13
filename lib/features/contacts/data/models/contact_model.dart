import 'package:contacts_search/features/contacts/domain/entities/contact.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'contact_model.freezed.dart';
part 'contact_model.g.dart';

@freezed
abstract class ContactModel with _$ContactModel {
  const factory ContactModel({
    required String id,
    required String name,
    required String phone,
  }) = _ContactModel;

  const ContactModel._();

  factory ContactModel.fromJson(Map<String, dynamic> json) =>
      _$ContactModelFromJson(json);

  Contact toEntity() => Contact(id: id, name: name, phone: phone);
}
