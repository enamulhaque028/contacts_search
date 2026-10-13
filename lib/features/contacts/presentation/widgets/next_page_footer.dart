import 'package:contacts_search/features/contacts/presentation/bloc/contacts_bloc.dart';
import 'package:flutter/material.dart';

class NextPageFooter extends StatelessWidget {
  const NextPageFooter({
    required this.status,
    required this.onRetry,
    this.errorMessage,
    super.key,
  });

  final NextPageStatus status;
  final String? errorMessage;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: switch (status) {
        NextPageStatus.idle => const SizedBox.shrink(),
        NextPageStatus.loading => const Center(
          child: SizedBox.square(
            dimension: 24,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
        ),
        NextPageStatus.failure => Column(
          children: [
            Text(
              errorMessage ?? 'Could not load more contacts.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      },
    );
  }
}
