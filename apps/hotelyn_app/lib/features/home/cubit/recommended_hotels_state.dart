import 'package:equatable/equatable.dart';
import 'package:hotelyn_domain/hotelyn_domain.dart' as domain;

/// States for the recommended-hotels cubit.
sealed class RecommendedHotelsState extends Equatable {
  const RecommendedHotelsState();

  @override
  List<Object?> get props => [];
}

/// Initial state before the cubit has been asked to load.
final class RecommendedHotelsInitial extends RecommendedHotelsState {
  const RecommendedHotelsInitial();
}

/// Hotels are being fetched from the repository.
final class RecommendedHotelsLoading extends RecommendedHotelsState {
  const RecommendedHotelsLoading();
}

/// Hotels loaded successfully.
final class RecommendedHotelsLoaded extends RecommendedHotelsState {
  const RecommendedHotelsLoaded({
    required this.hotels,
    this.isFallback = false,
  });

  /// The list of recommended hotels.
  final List<domain.Hotel> hotels;

  /// Whether the data came from the local fallback catalogue rather than
  /// the live API.
  final bool isFallback;

  @override
  List<Object?> get props => [hotels, isFallback];
}

/// An error occurred during fetching.
final class RecommendedHotelsFailure extends RecommendedHotelsState {
  const RecommendedHotelsFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
