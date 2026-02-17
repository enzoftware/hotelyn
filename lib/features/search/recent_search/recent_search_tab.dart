import 'package:clarity_flutter/clarity_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotelyn/components/app_bar.dart';
import 'package:hotelyn/components/text_input/hotelyn_search_input.dart';
import 'package:hotelyn/features/search/recent_search/cubit/search_cubit.dart';
import 'package:hotelyn/features/search/recent_search/cubit/search_state.dart';

class RecentSearchTab extends StatelessWidget {
  const RecentSearchTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HotelynHomeAppBar(
        title: 'Search',
        iconData: Icons.notifications,
      ),
      body: BlocConsumer<SearchCubit, SearchState>(
        listener: (context, state) {
          if (state is SearchLoadSuccess) {
            Clarity.setCustomTag('hotel_search', 'search_loaded');
          }
        },
        builder: (context, state) {
          return Builder(
            builder: (context) {
              return switch (state) {
                SearchInitial() => const SearchInitialScreen(),
                SearchError() => const SearchErrorScreen(),
                SearchLoading() => const SearchLoadingScreen(),
                SearchLoadSuccess() => const SearchLoadSuccessScreen()
              };
            },
          );
        },
      ),
    );
  }
}

class SearchLoadSuccessScreen extends StatelessWidget {
  const SearchLoadSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Hero(
          tag: SearchCubit.searchTag,
          child: HotelynSearchInput(hintText: 'Search hotel'),
        ),
      ],
    );
  }
}

class SearchLoadingScreen extends StatelessWidget {
  const SearchLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class SearchErrorScreen extends StatelessWidget {
  const SearchErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class SearchInitialScreen extends StatelessWidget {
  const SearchInitialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
