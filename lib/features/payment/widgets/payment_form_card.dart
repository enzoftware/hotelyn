import 'package:clarity_flutter/clarity_flutter.dart';
import 'package:flutter/material.dart';
import 'package:hotelyn/components/text_input/hotelyn_text_input.dart';
import 'package:hotelyn/components/text_style/hotelyn_text_style.dart';
import 'package:hotelyn/components/theme/hotelyn_colors.dart';

class PaymentFormCard extends StatelessWidget {
  const PaymentFormCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ClarityMask(
      child: Card(
        elevation: 0,
        color: LightGreyColors.lightGrey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Payment Details', style: HotelynTextStyle.h3),
              SizedBox(height: 16),
              HotelynTextInput(
                hintText: 'Card Number',
                prefixIcon: Icons.credit_card,
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 12),
              _ExpiryAndCvvRow(),
              SizedBox(height: 12),
              HotelynTextInput(
                hintText: 'Cardholder Name',
                prefixIcon: Icons.person_outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExpiryAndCvvRow extends StatelessWidget {
  const _ExpiryAndCvvRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: HotelynTextInput(
            hintText: 'MM/YY',
            prefixIcon: Icons.calendar_today,
            keyboardType: TextInputType.datetime,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: HotelynTextInput(
            hintText: 'CVV',
            prefixIcon: Icons.lock_outline,
            obscureText: true,
            keyboardType: TextInputType.number,
          ),
        ),
      ],
    );
  }
}
