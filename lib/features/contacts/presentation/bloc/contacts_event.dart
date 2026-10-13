part of 'contacts_bloc.dart';

@freezed
sealed class ContactsEvent with _$ContactsEvent {
  const factory ContactsEvent.started() = ContactsStarted;

  /// Debounced in the bloc, so it's fine to send on every keystroke.
  const factory ContactsEvent.queryChanged(String query) = ContactsQueryChanged;

  const factory ContactsEvent.refreshRequested() = ContactsRefreshRequested;

  /// From the full-screen error.
  const factory ContactsEvent.retryRequested() = ContactsRetryRequested;

  /// Also sent by the retry button under the list.
  const factory ContactsEvent.nextPageRequested() = ContactsNextPageRequested;
}
