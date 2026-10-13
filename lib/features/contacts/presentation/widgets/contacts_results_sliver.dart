import 'package:contacts_search/features/contacts/presentation/bloc/contacts_bloc.dart';
import 'package:contacts_search/features/contacts/presentation/widgets/contact_list_tile.dart';
import 'package:contacts_search/features/contacts/presentation/widgets/contacts_message_view.dart';
import 'package:contacts_search/features/contacts/presentation/widgets/next_page_footer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Has its own BlocBuilder so the scroll view around it isn't rebuilt.
class ContactsResultsSliver extends StatelessWidget {
  const ContactsResultsSliver({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ContactsBloc>();

    return BlocBuilder<ContactsBloc, ContactsState>(
      builder: (context, state) => switch (state) {
        ContactsLoading() => const SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: CircularProgressIndicator()),
        ),
        ContactsFailure(:final message) => SliverFillRemaining(
          hasScrollBody: false,
          child: ContactsMessageView(
            icon: Icons.cloud_off_outlined,
            message: message,
            actionLabel: 'Try again',
            onAction: () => bloc.add(const ContactsEvent.retryRequested()),
          ),
        ),
        ContactsLoaded(:final contacts, :final query) when contacts.isEmpty =>
          SliverFillRemaining(
            hasScrollBody: false,
            child: ContactsMessageView(
              icon: Icons.person_search_outlined,
              message: query.isEmpty
                  ? 'No contacts yet'
                  : 'No contacts found for "$query"',
            ),
          ),
        ContactsLoaded(
          :final contacts,
          :final nextPageStatus,
          :final nextPageErrorMessage,
        ) =>
          SliverMainAxisGroup(
            slivers: [
              SliverList.builder(
                itemCount: contacts.length,
                itemBuilder: (_, index) {
                  final contact = contacts[index];
                  return ContactListTile(
                    key: ValueKey(contact.id),
                    contact: contact,
                  );
                },
              ),
              SliverToBoxAdapter(
                child: NextPageFooter(
                  status: nextPageStatus,
                  errorMessage: nextPageErrorMessage,
                  onRetry: () =>
                      bloc.add(const ContactsEvent.nextPageRequested()),
                ),
              ),
            ],
          ),
      },
    );
  }
}
