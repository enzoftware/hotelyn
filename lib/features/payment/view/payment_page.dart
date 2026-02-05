import 'package:clarity_flutter/clarity_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotelyn/components/hotelyn_button.dart';
import 'package:hotelyn/components/theme/hotelyn_colors.dart';
import 'package:hotelyn/core/services/clarity_service.dart';
import 'package:hotelyn/features/payment/payment.dart';

class PaymentPage extends StatelessWidget {
  const PaymentPage({super.key});

  static const route = '/payment';

  @override
  Widget build(BuildContext context) {
    Clarity.setCurrentScreenName('payment');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: BlocProvider(
          create: (context) => PaymentBloc(
            clarityService: context.read<ClarityService>(),
          ),
          child: const _PaymentBody(),
        ),
      ),
    );
  }
}

class _PaymentBody extends StatelessWidget {
  const _PaymentBody();

  @override
  Widget build(BuildContext context) {
    return ClarityMask(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 16),
            const BookingSummaryCard(
              hotelName: 'Grand Plaza Hotel',
              checkIn: 'Dec 15, 2024',
              checkOut: 'Dec 18, 2024',
              totalPrice: r'$690.30',
            ),
            const SizedBox(height: 16),
            const PaymentFormCard(),
            const SizedBox(height: 32),
            ClarityUnmask(
              child: HotelynButton(
                message: 'Pay Now',
                onPressed: () {
                  Clarity.setCustomTag(
                    'booking_completed',
                    'hotel_grand_plaza',
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Payment successful!'),
                      backgroundColor: GreenColors.green,
                    ),
                  );
                  Navigator.of(context).pop();
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
