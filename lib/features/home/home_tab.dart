import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotelyn/components/navigation_bar/navigation_bar.dart';
import 'package:hotelyn/components/navigation_bar/navigation_bar_cubit.dart';
import 'package:hotelyn/components/navigation_bar/navigation_bar_state.dart';
import 'package:hotelyn/features/messages/messages_cubit.dart';
import 'package:hotelyn/features/messages/messages_tab.dart';
import 'package:hotelyn/features/profile/profile_cubit.dart';
import 'package:hotelyn/features/profile/profile_tab.dart';
import 'package:hotelyn/features/search/search_cubit.dart';
import 'package:hotelyn/features/search/search_tab.dart';

import 'widgets/home_header.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const route = '/home';

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<NavigationBarCubit>(
          create: (_) => NavigationBarCubit(),
        ),
        BlocProvider<ProfileCubit>(
          create: (_) => ProfileCubit(),
        ),
        BlocProvider<MessagesCubit>(
          create: (_) => MessagesCubit(),
        ),
        BlocProvider<SearchCubit>(
          create: (_) => SearchCubit(),
        ),
      ],
      child: BlocBuilder<NavigationBarCubit, NavigationBarState>(
        builder: (context, state) {
          final index = state.selectedTabIndex;
          return Scaffold(
            bottomNavigationBar: const HotelynNavigationBar(),
            body: <Widget>[
              const HomeTab(),
              const SearchTab(),
              const MessagesTab(),
              const ProfileTab()
            ].elementAt(index),
          );
        },
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPersistentHeader(
          pinned: true,
          delegate: HotelynHeader(),
        ),
        const SliverToBoxAdapter(),
      ],
    );
  }
}
