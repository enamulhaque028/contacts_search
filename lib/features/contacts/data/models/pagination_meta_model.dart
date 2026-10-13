import 'package:freezed_annotation/freezed_annotation.dart';

part 'pagination_meta_model.freezed.dart';
part 'pagination_meta_model.g.dart';

@freezed
abstract class PaginationMetaModel with _$PaginationMetaModel {
  const factory PaginationMetaModel({
    required int page,
    required int limit,
    required int total,
  }) = _PaginationMetaModel;

  const PaginationMetaModel._();

  factory PaginationMetaModel.fromJson(Map<String, dynamic> json) =>
      _$PaginationMetaModelFromJson(json);

  bool get hasMore => page * limit < total;
}
