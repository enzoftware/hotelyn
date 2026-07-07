import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotelyn/components/app_bar.dart';
import 'package:hotelyn/components/text_style/hotelyn_text_style.dart';
import 'package:hotelyn/features/messages/messages_cubit.dart';
import 'package:hotelyn/features/messages/messages_state.dart';

class MessagesTab extends StatelessWidget {
  const MessagesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MessagesCubit, MessagesState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(
          appBar: HotelynHomeAppBar(
            title: 'Messages',
            iconData: Icons.notifications,
            onIconPressed: () {},
          ),
          body: Builder(
            builder: (context) {
              return switch (state) {
                MessagesLoading() => const MessagesLoadingScreen(),
                MessagesEmpty() => const MessagesEmptyScreen(),
                MessagesError() => const MessagesErrorScreen(),
                MessagesLoadSuccess() => const MessagesLoadSuccessScreen(),
              };
            },
          ),
          floatingActionButton: state is MessagesEmpty
              ? FloatingActionButton(
                  onPressed: () {},
                  child: const Icon(Icons.message_rounded),
                )
              : null,
        );
      },
    );
  }
}

class MessagesLoadSuccessScreen extends StatelessWidget {
  const MessagesLoadSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class MessagesErrorScreen extends StatelessWidget {
  const MessagesErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class MessagesLoadingScreen extends StatelessWidget {
  const MessagesLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

class MessagesEmptyScreen extends StatelessWidget {
  const MessagesEmptyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/messages/empty.png',
            width: 200,
            height: 200,
          ),
          const SizedBox(height: 30),
          const Text(
            'No Messages Here',
            style: HotelynTextStyle.h1,
          ),
          const SizedBox(height: 12),
          const Text(
            'Lets start messaging with others or with seller',
            style: HotelynTextStyle.description,
          ),
        ],
      ),
    );
  }
}
