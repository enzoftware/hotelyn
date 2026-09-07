import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotelyn/components/navigation_bar/navigation_bar.dart';
import 'package:hotelyn/components/navigation_bar/navigation_bar_cubit.dart';
import 'package:hotelyn/components/navigation_bar/navigation_bar_state.dart';
import 'package:hotelyn/core/services/clarity_service.dart';
import 'package:hotelyn/features/filter/filter.dart';
import 'package:hotelyn/features/home/cubit/nearby_hotels_cubit.dart';
import 'package:hotelyn/features/home/cubit/recommended_hotels_cubit.dart';
import 'package:hotelyn/features/home/widgets/home_header.dart';
import 'package:hotelyn/features/home/widgets/nearby_hotels_section.dart';
import 'package:hotelyn/features/home/widgets/recommended_hotels_section.dart';
import 'package:hotelyn/features/location/location.dart';
import 'package:hotelyn/features/messages/messages_cubit.dart';
import 'package:hotelyn/features/messages/messages_tab.dart';
import 'package:hotelyn/features/profile/profile_cubit.dart';
import 'package:hotelyn/features/profile/profile_tab.dart';
import 'package:hotelyn/features/search/recent_search/cubit/search_cubit.dart';
import 'package:hotelyn/features/search/recent_search/recent_search_tab.dart';
import 'package:hotelyn_domain/hotelyn_domain.dart' as domain;

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    this.navigationBarCubit,
    this.profileCubit,
    this.messagesCubit,
    this.searchCubit,
    this.recommendedHotelsCubit,
    this.nearbyHotelsCubit,
    this.filterCubit,
  });

  static const route = '/home';

  final NavigationBarCubit? navigationBarCubit;
  final ProfileCubit? profileCubit;
  final MessagesCubit? messagesCubit;
  final SearchCubit? searchCubit;
  final RecommendedHotelsCubit? recommendedHotelsCubit;
  final NearbyHotelsCubit? nearbyHotelsCubit;
  final FilterCubit? filterCubit;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        if (navigationBarCubit != null)
          BlocProvider.value(value: navigationBarCubit!)
        else
          BlocProvider(
            create: (context) => NavigationBarCubit(
              clarityService: context.read<ClarityService>(),
            ),
          ),
        if (profileCubit != null)
          BlocProvider.value(value: profileCubit!)
        else
          BlocProvider(
            create: (_) => ProfileCubit(),
          ),
        if (messagesCubit != null)
          BlocProvider.value(value: messagesCubit!)
        else
          BlocProvider(
            create: (_) => MessagesCubit(),
          ),
        if (searchCubit != null)
          BlocProvider.value(value: searchCubit!)
        else
          BlocProvider(
            create: (context) => SearchCubit(
              clarityService: context.read<ClarityService>(),
            ),
          ),
        if (recommendedHotelsCubit != null)
          BlocProvider.value(value: recommendedHotelsCubit!)
        else
          BlocProvider(
            create: (context) {
              final hotelRepo = context.read<domain.HotelRepository?>();
              if (hotelRepo == null) {
                // In isolated tests without HotelRepository, emit initial
                // state.
                return RecommendedHotelsCubit.uninitialized();
              }
              final cubit = RecommendedHotelsCubit(
                hotelRepository: hotelRepo,
              );
              final location = context.read<LocationCubit>().state.userLocation;
              unawaited(
                cubit.loadRecommendedHotels(
                  latitude: location.latitude,
                  longitude: location.longitude,
                ),
              );
              return cubit;
            },
          ),
        if (nearbyHotelsCubit != null)
          BlocProvider.value(value: nearbyHotelsCubit!)
        else
          BlocProvider(
            create: (context) {
              final hotelRepo = context.read<domain.HotelRepository?>();
              if (hotelRepo == null) {
                return NearbyHotelsCubit.uninitialized();
              }
              final cubit = NearbyHotelsCubit(
                hotelRepository: hotelRepo,
              );
              final location = context.read<LocationCubit>().state.userLocation;
              unawaited(
                cubit.loadNearbyHotels(
                  latitude: location.latitude,
                  longitude: location.longitude,
                ),
              );
              return cubit;
            },
          ),
        if (filterCubit != null)
          BlocProvider.value(value: filterCubit!)
        else
          BlocProvider(
            create: (_) => FilterCubit(),
          ),
      ],
      child: const HomeView(),
    );
  }
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationBarCubit, NavigationBarState>(
      builder: (context, state) {
        final index = state.selectedTabIndex;
        return PopScope(
          canPop: index == 0,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            if (index != 0) {
              context.read<NavigationBarCubit>().updateSelectedIndex(0);
            }
          },
          child: Scaffold(
            bottomNavigationBar: const HotelynNavigationBar(),
            body: SafeArea(
              child: IndexedStack(
                index: index,
                children: const [
                  HomeTab(),
                  RecentSearchTab(),
                  MessagesTab(),
                  ProfileTab(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({
    this.userName = 'Katherine',
    this.onNotificationTap,
    this.onSearchTap,
    this.onFilterTap,
    super.key,
  });

  final String userName;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onSearchTap;
  final VoidCallback? onFilterTap;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPersistentHeader(
          pinned: true,
          delegate: HotelynHeader(
            userName: userName,
            onNotificationTap: onNotificationTap,
            onSearchTap: onSearchTap,
            onFilterTap:
                onFilterTap ??
                () {
                  final filterCubit = context.read<FilterCubit>();
                  unawaited(
                    HotelFilterBottomSheet.show(
                      context,
                      initialCriteria: filterCubit.state.criteria,
                      onApply: filterCubit.applyCriteria,
                    ),
                  );
                },
          ),
        ),
        const RecommendedHotelsSection(),
        const NearbyHotelsSection(),
      ],
    );
  }
}
