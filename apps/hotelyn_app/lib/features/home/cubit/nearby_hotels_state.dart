import 'package:equatable/equatable.dart';
import 'package:hotelyn_domain/hotelyn_domain.dart' as domain;

/// States for the nearby-hotels cubit.
sealed class NearbyHotelsState extends Equatable {
  const NearbyHotelsState();

  @override
  List<Object?> get props => [];
}

/// Initial state before hotels have been requested.
final class NearbyHotelsInitial extends NearbyHotelsState {
  const NearbyHotelsInitial();
}

/// Hotels are being fetched from the repository.
final class NearbyHotelsLoading extends NearbyHotelsState {
  const NearbyHotelsLoading();
}

/// Hotels loaded successfully.
final class NearbyHotelsLoaded extends NearbyHotelsState {
  const NearbyHotelsLoaded({
    required this.hotels,
    this.isFallback = false,
  });

  /// The list of nearby hotels.
  final List<domain.Hotel> hotels;

  /// Whether the data came from the local fallback catalogue rather than
  /// the live API.
  final bool isFallback;

  @override
  List<Object?> get props => [hotels, isFallback];
}

/// An error occurred during fetching.
final class NearbyHotelsFailure extends NearbyHotelsState {
  const NearbyHotelsFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
