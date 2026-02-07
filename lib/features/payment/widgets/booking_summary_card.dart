import 'package:flutter/material.dart';
import 'package:hotelyn/components/text_style/hotelyn_text_style.dart';
import 'package:hotelyn/components/theme/hotelyn_colors.dart';

class BookingSummaryCard extends StatelessWidget {
  const BookingSummaryCard({
    required this.hotelName,
    required this.checkIn,
    required this.checkOut,
    required this.totalPrice,
    super.key,
  });

  final String hotelName;
  final String checkIn;
  final String checkOut;
  final String totalPrice;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: LightGreyColors.lightGrey,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Booking Summary', style: HotelynTextStyle.h3),
            const SizedBox(height: 12),
            _SummaryRow(label: 'Hotel', value: hotelName),
            const SizedBox(height: 8),
            _SummaryRow(label: 'Check-in', value: checkIn),
            const SizedBox(height: 8),
            _SummaryRow(label: 'Check-out', value: checkOut),
            const Divider(height: 24),
            _SummaryRow(
              label: 'Total',
              value: totalPrice,
              isBold: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  final String label;
  final String value;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: HotelynTextStyle.description,
        ),
        Text(
          value,
          style: isBold ? HotelynTextStyle.h3 : HotelynTextStyle.description,
        ),
      ],
    );
  }
}
