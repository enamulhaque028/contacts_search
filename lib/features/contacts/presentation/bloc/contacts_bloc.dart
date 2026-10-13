import 'package:contacts_search/core/error/app_exception.dart';
import 'package:contacts_search/features/contacts/data/repositories/contacts_repository.dart';
import 'package:contacts_search/features/contacts/domain/entities/contact.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'contacts_bloc.freezed.dart';
part 'contacts_event.dart';
part 'contacts_state.dart';

const _genericErrorMessage = 'Something went wrong. Please try again.';

@injectable
class ContactsBloc extends Bloc<ContactsEvent, ContactsState> {
  ContactsBloc({
    required this._repository,
    @ignoreParam this.pageSize = 20,
    @ignoreParam this.searchDebounce = const Duration(milliseconds: 400),
  }) : super(const ContactsState.loading()) {
    on<ContactsStarted>(_onStarted);
    on<ContactsQueryChanged>(_onQueryChanged);
    on<ContactsRefreshRequested>(_onRefreshRequested);
    on<ContactsRetryRequested>(_onRetryRequested);
    on<ContactsNextPageRequested>(_onNextPageRequested);
  }

  final ContactsRepository _repository;
  final int pageSize;
  final Duration searchDebounce;

  /// Increased on every first-page load (start, search, refresh, retry).
  /// A response from an older load is ignored, e.g. a slow "al" search
  /// finishing after "alex", or page 2 of a query that's no longer shown.
  int _generation = 0;

  /// Increased on every keystroke, used for the search debounce.
  int _latestQueryId = 0;

  Future<void> _onStarted(ContactsStarted event, Emitter<ContactsState> emit) {
    return _loadFirstPage(emit, query: state.query);
  }

  Future<void> _onQueryChanged(
    ContactsQueryChanged event,
    Emitter<ContactsState> emit,
  ) async {
    // Wait a bit and continue only if nothing newer was typed meanwhile.
    final queryId = ++_latestQueryId;
    await Future<void>.delayed(searchDebounce);
    if (queryId != _latestQueryId || isClosed) return;

    final query = event.query.trim();
    final alreadyShown = query == state.query && state is! ContactsFailure;
    if (alreadyShown) return;

    await _loadFirstPage(emit, query: query);
  }

  Future<void> _onRefreshRequested(
    ContactsRefreshRequested event,
    Emitter<ContactsState> emit,
  ) {
    return _loadFirstPage(emit, query: state.query, isRefresh: true);
  }

  Future<void> _onRetryRequested(
    ContactsRetryRequested event,
    Emitter<ContactsState> emit,
  ) {
    return _loadFirstPage(emit, query: state.query);
  }

  Future<void> _loadFirstPage(
    Emitter<ContactsState> emit, {
    required String query,
    bool isRefresh = false,
  }) async {
    final generation = ++_generation;

    final current = state;
    if (isRefresh && current is ContactsLoaded) {
      // Keep the list visible while refreshing.
      emit(
        current.copyWith(
          isRefreshing: true,
          nextPageStatus: NextPageStatus.idle,
          refreshErrorMessage: null,
        ),
      );
    } else {
      // Don't keep showing results of the previous query.
      emit(ContactsState.loading(query: query));
    }

    try {
      final result = await _repository.getContacts(
        page: 1,
        limit: pageSize,
        search: query,
      );
      if (generation != _generation) return;

      emit(
        ContactsState.loaded(
          query: query,
          contacts: result.contacts,
          page: result.page,
          hasReachedEnd: !result.hasMore,
        ),
      );
    } catch (error, stackTrace) {
      if (generation != _generation) return;
      addError(error, stackTrace);

      final message = _messageFor(error);
      final latest = state;
      if (latest is ContactsLoaded) {
        emit(
          latest.copyWith(isRefreshing: false, refreshErrorMessage: message),
        );
      } else {
        emit(ContactsState.failure(query: query, message: message));
      }
    }
  }

  Future<void> _onNextPageRequested(
    ContactsNextPageRequested event,
    Emitter<ContactsState> emit,
  ) async {
    // Runs before any await and the emit below marks the page as loading,
    // so fast scrolling can't start a second request.
    final current = state;
    if (current is! ContactsLoaded || !current.canLoadNextPage) return;

    final generation = _generation;

    emit(
      current.copyWith(
        nextPageStatus: NextPageStatus.loading,
        nextPageErrorMessage: null,
      ),
    );

    try {
      final result = await _repository.getContacts(
        page: current.page + 1,
        limit: pageSize,
        search: current.query,
      );

      final latest = state;
      if (generation != _generation || latest is! ContactsLoaded) return;

      emit(
        latest.copyWith(
          contacts: [...latest.contacts, ...result.contacts],
          page: result.page,
          hasReachedEnd: !result.hasMore,
          nextPageStatus: NextPageStatus.idle,
        ),
      );
    } catch (error, stackTrace) {
      final latest = state;
      if (generation != _generation || latest is! ContactsLoaded) return;
      addError(error, stackTrace);

      emit(
        latest.copyWith(
          nextPageStatus: NextPageStatus.failure,
          nextPageErrorMessage: _messageFor(error),
        ),
      );
    }
  }

  String _messageFor(Object error) {
    return error is AppException ? error.message : _genericErrorMessage;
  }
}
