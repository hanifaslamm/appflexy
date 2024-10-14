// MODULE GA KEPAKE (SAMA KYK KASIR)


import 'package:apptiket/app/modules/checkout/controllers/checkout_controller.dart';
import 'package:apptiket/app/widgets/ticket_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../widgets/summary_card.dart';

class CheckoutScreen extends StatelessWidget {
  CheckoutScreen({super.key});

  final CheckoutController _controller =
      Get.put(CheckoutController()); // Initialize controller

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kasir'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Get.back(); // Use GetX back navigation
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  const Text(
                    'Tiket',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TicketCard(
                    ticketName: 'Tiket Dewasa',
                    price: _controller.adultTicketPrice,
                    onIncrease: _controller.increaseAdultTicket,
                    onDecrease: _controller.decreaseAdultTicket,
                    quantity: _controller.adultTicketQuantity,
                  ),
                  const SizedBox(height: 8),
                  TicketCard(
                    ticketName: 'Tiket Anak',
                    price: _controller.childTicketPrice,
                    onIncrease: _controller.increaseChildTicket,
                    onDecrease: _controller.decreaseChildTicket,
                    quantity: _controller.childTicketQuantity,
                  ),
                  const SizedBox(height: 16),
                  const SummaryCard(),
                  const SizedBox(height: 16),
                  /* masih missing payment method
                  const PaymentMethod(),
                  */
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Aksi ketika tombol pemesanan ditekan
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.blue,
              ),
              child: const Text(
                'Lakukan Pemesanan',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
