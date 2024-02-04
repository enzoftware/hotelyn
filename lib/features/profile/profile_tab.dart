import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotelyn/components/app_bar.dart';
import 'package:hotelyn/components/avatar/hotelyn_avatar.dart';
import 'package:hotelyn/components/text_style/hotelyn_text_style.dart';
import 'package:hotelyn/features/profile/profile_cubit.dart';
import 'package:hotelyn/features/profile/profile_state.dart';

import 'widgets/profile_options_section.dart';
import 'widgets/profile_stats_card.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  // TODO: When authentication is ready add a validation to redirect to login page to unauthenticated users.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HotelynHomeAppBar(
        title: 'Profile',
        iconData: Icons.settings,
        onIconPressed: () {},
      ),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          return switch (state) {
            ProfileLoading() => const ProfileLoadingScreen(),
            ProfileLoadSuccess() => const ProfileDataScreen(),
            // TODO: Create a custom error screen with a custom message per screen
            ProfileFailure() => const Placeholder(),
          };
        },
      ),
    );
  }
}

class ProfileLoadingScreen extends StatelessWidget {
  const ProfileLoadingScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class ProfileDataScreen extends StatelessWidget {
  const ProfileDataScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            ProfileUserInformationSection(),
            SizedBox(height: 24),
            ProfileStatsCard(),
            SizedBox(height: 24),
            ProfileOptionsSection(),
          ],
        ),
      ),
    );
  }
}

class ProfileUserInformationSection extends StatelessWidget {
  const ProfileUserInformationSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        HotelynAvatar(path: 'assets/images/profile_1.png', size: 50),
        SizedBox(height: 16),
        Text('Enzo Lizama', style: HotelynTextStyle.h2),
        SizedBox(height: 8),
        Text('Lima, Peru', style: HotelynTextStyle.description),
      ],
    );
  }
}
