import 'package:equatable/equatable.dart';

sealed class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoadSuccess extends SearchState {}

class SearchError extends SearchState {}
