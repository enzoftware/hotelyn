import 'package:flutter/material.dart';
import 'package:hotelyn/components/text_input/hotelyn_search_input.dart';
import 'package:hotelyn/features/search/recent_search/cubit/search_cubit.dart';

class SearchFormPage extends StatelessWidget {
  const SearchFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(
        children: [
          Hero(
            tag: SearchCubit.searchTag,
            child: HotelynSearchInput(hintText: 'Search hotel'),
          ),
        ],
      ),
    );
  }
}
