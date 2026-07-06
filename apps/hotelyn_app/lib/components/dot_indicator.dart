import 'package:flutter/material.dart';
import 'package:hotelyn/components/theme/hotelyn_colors.dart';

class GroupDotIndicator extends StatelessWidget {
  const GroupDotIndicator({
    required this.length,
    required this.selectedIndex,
    super.key,
  });

  final int length;
  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        length,
        (index) => DotIndicator(isActive: selectedIndex == index),
      ),
    );
  }
}

class DotIndicator extends StatelessWidget {
  const DotIndicator({
    required this.isActive,
    super.key,
    this.activeColor,
    this.inactiveColor,
  });

  final bool isActive;
  final Color? activeColor;
  final Color? inactiveColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = activeColor ?? theme.primaryColor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      height: 5,
      width: isActive ? 20 : 6,
      decoration: BoxDecoration(
        color: isActive ? color : GreyColors.grey.withValues(alpha: 0.25),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
    );
  }
}
