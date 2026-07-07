import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:hotelyn/components/navigation_bar/navigation_bar_cubit.dart';

class HotelynNavigationBar extends StatelessWidget {
  const HotelynNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<NavigationBarCubit>();
    return BottomNavigationBar(
      onTap: cubit.updateSelectedIndex,
      currentIndex: cubit.state.selectedTabIndex,
      showSelectedLabels: true,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Search',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.message),
          label: 'Messages',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
    );
  }
}
