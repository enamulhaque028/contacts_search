part of 'contacts_bloc.dart';

enum NextPageStatus { idle, loading, failure }

@freezed
sealed class ContactsState with _$ContactsState {
  const factory ContactsState.loading({@Default('') String query}) =
      ContactsLoading;

  const factory ContactsState.failure({
    required String query,
    required String message,
  }) = ContactsFailure;

  /// [contacts] can be empty, that's the "no results" case.
  const factory ContactsState.loaded({
    required String query,
    required List<Contact> contacts,
    required int page,
    required bool hasReachedEnd,
    @Default(NextPageStatus.idle) NextPageStatus nextPageStatus,
    String? nextPageErrorMessage,
    @Default(false) bool isRefreshing,
    String? refreshErrorMessage,
  }) = ContactsLoaded;

  const ContactsState._();

  bool get canLoadNextPage => switch (this) {
    ContactsLoaded(
      :final hasReachedEnd,
      :final isRefreshing,
      :final nextPageStatus,
    ) =>
      !hasReachedEnd &&
          !isRefreshing &&
          nextPageStatus != NextPageStatus.loading,
    _ => false,
  };
}
