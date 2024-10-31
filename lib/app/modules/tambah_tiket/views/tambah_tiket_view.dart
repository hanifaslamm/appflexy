import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gap/gap.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';

class TambahTiketView extends StatefulWidget {
  final Map<String, dynamic>? tiket; // Data tiket yang akan diedit
  final int? index; // Index tiket untuk di-update

  TambahTiketView({this.tiket, this.index});

  @override
  _TambahTiketViewState createState() => _TambahTiketViewState();
}

class _TambahTiketViewState extends State<TambahTiketView> {
  final TextEditingController namaTiketController = TextEditingController();
  final TextEditingController stokController = TextEditingController();
  final TextEditingController hargaJualController = TextEditingController();
  final TextEditingController keteranganController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.tiket != null) {
      namaTiketController.text = widget.tiket!['namaTiket'];
      stokController.text = widget.tiket!['stok'];
      hargaJualController.text = widget.tiket!['hargaTiket'];
      keteranganController.text = widget.tiket!['keterangan'];
    }
  }

  final NumberFormat currencyFormat =
      NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

  void _onCashInputChanged(String value) {
    String formattedValue;

    // Remove any non-numeric characters
    value = value.replaceAll(RegExp(r'[^0-9]'), '');

    // Format the numeric value
    if (value.isNotEmpty) {
      double parsedValue = double.parse(value);
      formattedValue = currencyFormat.format(parsedValue);
    } else {
      formattedValue = currencyFormat.format(0);
    }

    // Update the controller text with formatted value
    hargaJualController.value = TextEditingValue(
      text: formattedValue,
      selection: TextSelection.collapsed(offset: formattedValue.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          widget.tiket == null ? 'Tambah Tiket' : 'Edit Tiket',
          style: const TextStyle(
              color: Color(0xff181681), fontWeight: FontWeight.bold),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          // Menutup keyboard saat mengetuk area kosong
          FocusScope.of(context).unfocus();
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: namaTiketController,
                    decoration: InputDecoration(
                      hintText: 'Nama Tiket',
                      prefixIcon: Icon(
                        Bootstrap.ticket_detailed,
                        color: Color(0xff181681),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            13), // Set border radius to 25
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(11),
                          borderSide:
                              BorderSide(color: Color(0xff181681), width: 2.0)),
                    ),
                  ),
                  const Gap(30),
                  TextField(
                    controller: stokController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Bootstrap.box,
                        color: Color(0xff181681),
                      ),
                      hintText: 'Stok',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            13), // Set border radius to 25
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(11),
                          borderSide:
                              BorderSide(color: Color(0xff181681), width: 2.0)),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const Gap(30),
                  TextField(
                    controller: hargaJualController,
                    decoration: InputDecoration(
                      hintText: 'Harga Tiket',
                      prefixIcon: Icon(
                        IonIcons.cash,
                        color: Color(0xff181681),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            13), // Set border radius to 25
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(11),
                          borderSide:
                              BorderSide(color: Color(0xff181681), width: 2.0)),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: _onCashInputChanged,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: keteranganController,
                    decoration: InputDecoration(
                      hintText: 'Keterangan Tiket',
                      hintStyle: TextStyle(color: Color(0xff181681)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            13), // Set border radius to 25
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(11),
                          borderSide:
                              BorderSide(color: Color(0xff181681), width: 2.0)),
                    ),
                    maxLines: 4,
                  ),
                  const Gap(70),
                  ElevatedButton(
                    onPressed: () {
                      // Parse the unformatted numeric value for hargaTiket
                      final jumlahUang = double.tryParse(hargaJualController
                              .text
                              .replaceAll(RegExp(r'[^0-9]'), '')) ??
                          0;

                      // Kembali ke halaman sebelumnya dengan data tiket
                      Map<String, dynamic> newTiket = {
                        'namaTiket': namaTiketController.text,
                        'stok': int.tryParse(stokController.text) ??
                            0, // Convert stok to int
                        'hargaTiket':
                            jumlahUang, // Use the parsed numeric value
                        'keterangan': keteranganController.text,
                      };
                      Get.back(result: newTiket); // Kirim data tiket
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xff181681), // Gunakan warna yang sesuai
                      minimumSize: const Size(
                          double.infinity, 50), // Sesuaikan lebar dan tinggi
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(20), // Bentuk tombol rounded
                      ),
                    ),
                    child: const Text(
                      'Tambahkan tiket',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white, // Warna teks tombol putih
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
