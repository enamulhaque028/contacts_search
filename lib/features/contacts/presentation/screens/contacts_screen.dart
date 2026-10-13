import 'package:contacts_search/core/di/injection.dart';
import 'package:contacts_search/features/contacts/presentation/bloc/contacts_bloc.dart';
import 'package:contacts_search/features/contacts/presentation/widgets/contacts_results_sliver.dart';
import 'package:contacts_search/features/contacts/presentation/widgets/contacts_search_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ContactsBloc>()..add(const ContactsEvent.started()),
      child: const ContactsView(),
    );
  }
}

class ContactsView extends HookWidget {
  const ContactsView({super.key});

  /// Pixels left to the bottom when the next page is requested.
  static const _loadMoreThreshold = 300.0;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ContactsBloc>();
    final searchController = useTextEditingController();
    final scrollController = useScrollController();

    void loadMoreIfNeeded() {
      if (!context.mounted || !scrollController.hasClients) return;

      final nearBottom =
          scrollController.position.extentAfter < _loadMoreThreshold;

      if (nearBottom && bloc.state.canLoadNextPage) {
        bloc.add(const ContactsEvent.nextPageRequested());
      }
    }

    useEffect(() {
      scrollController.addListener(loadMoreIfNeeded);
      return () => scrollController.removeListener(loadMoreIfNeeded);
    }, [scrollController]);

    return Scaffold(
      appBar: AppBar(title: const Text('Contacts')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: ContactsSearchField(
              controller: searchController,
              onChanged: (query) => bloc.add(ContactsEvent.queryChanged(query)),
            ),
          ),
          Expanded(
            // If a page doesn't fill the screen there's nothing to scroll,
            // so check again whenever the list changes.
            child: BlocListener<ContactsBloc, ContactsState>(
              listenWhen: (_, current) => current is ContactsLoaded,
              listener: (_, _) => WidgetsBinding.instance.addPostFrameCallback(
                (_) => loadMoreIfNeeded(),
              ),
              child: RefreshIndicator(
                onRefresh: () => _refresh(context, bloc),
                child: CustomScrollView(
                  controller: scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  slivers: const [ContactsResultsSliver()],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// The indicator keeps spinning until this completes.
  Future<void> _refresh(BuildContext context, ContactsBloc bloc) async {
    final refreshed = bloc.stream.firstWhere(
      (state) => !(state is ContactsLoaded && state.isRefreshing),
      orElse: () => bloc.state,
    );

    bloc.add(const ContactsEvent.refreshRequested());

    final result = await refreshed;
    if (!context.mounted) return;

    if (result case ContactsLoaded(:final refreshErrorMessage?)) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(refreshErrorMessage)));
    }
  }
}
