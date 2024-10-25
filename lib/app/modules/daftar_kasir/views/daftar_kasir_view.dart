import 'dart:io';
import 'package:apptiket/app/modules/kasir/views/kasir_view.dart';
import 'package:apptiket/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';

class DaftarKasirView extends StatefulWidget {
  @override
  _DaftarKasirViewState createState() => _DaftarKasirViewState();
}

class _DaftarKasirViewState extends State<DaftarKasirView>
    with SingleTickerProviderStateMixin {
  final NumberFormat currencyFormat =
      NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 2);
  final box = GetStorage();
  List<Map<String, dynamic>> produkList = [];
  List<Map<String, dynamic>> filteredProdukList = [];
  List<Map<String, dynamic>> tiketList = [];
  List<Map<String, dynamic>> filteredTiketList = [];
  List<Map<String, dynamic>> pesananList = [];
  String searchQuery = '';
  int pesananCount = 0;
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: 2, vsync: this); // 2 tab: produk & tiket
    _loadProdukList();
    _loadTiketList();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _loadProdukList() {
    List<dynamic>? storedProdukList = box.read<List<dynamic>>('produkList');
    if (storedProdukList != null) {
      produkList = List<Map<String, dynamic>>.from(storedProdukList);
    } else {
      produkList = []; // Provide default empty list
    }
    filteredProdukList = produkList; // Avoid null references
  }

  void _loadTiketList() {
    List<dynamic>? storedTiketList = box.read<List<dynamic>>('tiketList');
    if (storedTiketList != null) {
      tiketList = List<Map<String, dynamic>>.from(storedTiketList);
    } else {
      tiketList = []; // Provide default empty list
    }
    filteredTiketList = tiketList; // Avoid null references
  }

  void updateSearchQuery(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredProdukList = produkList; // No need to filter if query is empty
        filteredTiketList = tiketList;
      } else {
        filteredProdukList = produkList
            .where((produk) => produk['namaProduk']
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
        filteredTiketList = tiketList
            .where((tiket) =>
                tiket['namaTiket'].toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void addToPesanan(Map<String, dynamic> item) {
    setState(() {
      pesananList.add({
        'nama': item['namaProduk'] ?? item['namaTiket'],
        'harga': item['hargaJual'] ?? item['hargaTiket'],
        'image': item['image'],
      });
      pesananCount++;
    });
  }

  Widget _buildList(List<Map<String, dynamic>> list, String type) {
    return list.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox, size: 100, color: Colors.grey),
                SizedBox(height: 16),
                Text('Tidak ada daftar $type yang dapat ditampilkan.',
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
          )
        : ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              final item = list[index];
              String title =
                  type == 'produk' ? item['namaProduk'] : item['namaTiket'];
              double price = type == 'produk'
                  ? double.tryParse(item['hargaJual']?.toString() ?? '0') ?? 0.0
                  : double.tryParse(item['hargaTiket']?.toString() ?? '0') ??
                      0.0;

              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading:
                      item['image'] != null && File(item['image']).existsSync()
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.file(
                                File(item['image']),
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Icon(Icons.image, size: 50),
                  title: Text(title,
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(currencyFormat.format(price)),
                  onTap: () {
                    addToPesanan(item);
                    Get.snackbar('Pesanan', '$title ditambahkan ke pesanan.');
                  },
                ),
              );
            },
          );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Jumlah tab
      child: Scaffold(
        appBar: AppBar(
          title: Text('Daftar Produk dan Tiket'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Produk'),
              Tab(text: 'Tiket'),
            ],
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Get.offAllNamed(Routes.HOME),
          ),
        ),
        body: TabBarView(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: _buildList(filteredProdukList, 'produk'),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: _buildList(filteredTiketList, 'tiket'),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Get.to(() => KasirView(pesananList: pesananList));
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(Icons.shopping_cart),
              if (pesananCount > 0)
                Positioned(
                  right: 0,
                  child: CircleAvatar(
                    radius: 8.0,
                    backgroundColor: Colors.red,
                    child: Text(
                      pesananCount.toString(),
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
