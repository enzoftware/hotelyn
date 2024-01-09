import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotelyn/components/app_bar.dart';
import 'package:hotelyn/features/search/search_cubit.dart';
import 'package:hotelyn/features/search/search_state.dart';

class SearchTab extends StatelessWidget {
  const SearchTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HotelynHomeAppBar(
        title: 'Search',
        iconData: Icons.notifications,
      ),
      body: BlocConsumer<SearchCubit, SearchState>(
        listener: (context, state) {
          // TODO: implement listener
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
    return const Placeholder();
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
