import 'package:clarity_flutter/clarity_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotelyn/components/navigation_bar/navigation_bar.dart';
import 'package:hotelyn/components/navigation_bar/navigation_bar_cubit.dart';
import 'package:hotelyn/components/navigation_bar/navigation_bar_state.dart';
import 'package:hotelyn/features/home/widgets/featured_hotels_section.dart';
import 'package:hotelyn/features/home/widgets/home_header.dart';
import 'package:hotelyn/features/messages/messages_cubit.dart';
import 'package:hotelyn/features/messages/messages_tab.dart';
import 'package:hotelyn/features/profile/profile_cubit.dart';
import 'package:hotelyn/features/profile/profile_tab.dart';
import 'package:hotelyn/features/search/recent_search/cubit/search_cubit.dart';
import 'package:hotelyn/features/search/recent_search/recent_search_tab.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const route = '/home';

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => NavigationBarCubit(),
        ),
        BlocProvider(
          create: (_) => ProfileCubit(),
        ),
        BlocProvider(
          create: (_) => MessagesCubit(),
        ),
        BlocProvider(
          create: (_) => SearchCubit(),
        ),
      ],
      child: BlocConsumer<NavigationBarCubit, NavigationBarState>(
        listener: (context, state) {
          const screenNames = ['home', 'search', 'messages', 'profile'];
          Clarity.setCurrentScreenName(screenNames[state.selectedTabIndex]);
        },
        builder: (context, state) {
          final index = state.selectedTabIndex;
          return Scaffold(
            bottomNavigationBar: const HotelynNavigationBar(),
            body: SafeArea(
              child: <Widget>[
                const HomeTab(),
                const RecentSearchTab(),
                const MessagesTab(),
                const ProfileTab(),
              ].elementAt(index),
            ),
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
        const FeaturedHotelsSection(),
      ],
    );
  }
}
