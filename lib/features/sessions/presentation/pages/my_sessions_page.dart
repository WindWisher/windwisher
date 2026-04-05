import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/features/sessions/presentation/models/my_sessions_models.dart';
import 'package:windwisher/features/sessions/presentation/widgets/my_sessions/my_sessions_empty_state_card.dart';
import 'package:windwisher/features/sessions/presentation/widgets/my_sessions/my_sessions_search_field.dart';

class MySessionsPage extends StatelessWidget {
  const MySessionsPage({
    super.key,
    required this.searchController,
    required this.data,
    required this.onSearchChanged,
    required this.onClearSearchPressed,
    required this.sessionCards,
    this.emptyStateTextStyle,
  });

  final TextEditingController searchController;
  final MySessionsPageData data;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearchPressed;
  final List<Widget> sessionCards;
  final TextStyle? emptyStateTextStyle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.sm),
        MySessionsSearchField(
          controller: searchController,
          data: data.searchFieldData,
          onChanged: onSearchChanged,
          onClearPressed: onClearSearchPressed,
        ),
        const SizedBox(height: AppSpacing.sm),
        if (!data.hasSessions)
          MySessionsEmptyStateCard(
            data: data.emptyStateData,
            textStyle: emptyStateTextStyle,
            onClearSearchPressed: onClearSearchPressed,
          )
        else
          ...sessionCards,
      ],
    );
  }
}
