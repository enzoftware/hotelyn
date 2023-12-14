import 'package:equatable/equatable.dart';
import 'package:hotelyn/features/onboarding/data/on_boarding_data.dart';

class OnBoardingState extends Equatable {
  final int currentPosition;
  final String primaryButtonMessage;
  final List<OnBoardingItemData> data;

  const OnBoardingState({
    required this.currentPosition,
    required this.primaryButtonMessage,
    required this.data,
  });

  OnBoardingState copyWith({
    String? primaryButtonMessage,
    int? currentPosition,
    List<OnBoardingItemData>? data,
  }) {
    return OnBoardingState(
      currentPosition: currentPosition ?? this.currentPosition,
      primaryButtonMessage: primaryButtonMessage ?? this.primaryButtonMessage,
      data: data ?? this.data,
    );
  }

  @override
  List<Object?> get props => [
        currentPosition,
        primaryButtonMessage,
        data,
      ];
}
