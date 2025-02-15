import 'dart:convert';

import 'package:apptiket/app/routes/app_pages.dart';
import 'package:apptiket/app/widgets/navbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:apptiket/app/modules/home/controllers/home_controller.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _pageIndex = 0;
  final List<Widget> _pages = [
    const Center(child: Text('Beranda', style: TextStyle(fontSize: 24))),
    const Center(child: Text('Penjualan', style: TextStyle(fontSize: 24))),
    const Center(child: Text('Settings', style: TextStyle(fontSize: 24))),
  ];

  final HomeController homeController = Get.put(HomeController());

  @override
  void initState() {
    super.initState();
    homeController.fetchPieChartData(homeController
        .selectedFilter.value); // Fetch pie chart data when initializing
    homeController.fetchCompanyDetails(); // Fetch store data when initializing
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff181681),
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          _buildBackground(),
          _buildContent(),
        ],
      ),
      bottomNavigationBar: CustomNavigationBar(
        currentIndex: _pageIndex,
        onTap: (index) {
          setState(() {
            _pageIndex = index;
            if (index == 0) {
              Get.offAllNamed(Routes.HOME);
            } else if (index == 1) {
              Get.offAllNamed(Routes.DAFTAR_KASIR);
            } else if (index == 2) {
              Get.offAllNamed(Routes.PROFILEUSER2);
            }
          });
        },
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      toolbarHeight: 150,
      backgroundColor: const Color(0xff181681),
      elevation: 0,
      title: Container(
        padding: const EdgeInsets.only(top: 5.0),
        child: const Text(
          "Flexy",
          style: TextStyle(
            fontFamily: 'Pacifico',
            fontSize: 50,
            fontWeight: FontWeight.normal,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      height: Get.height,
      width: Get.width,
      color: const Color(0xff181681),
    );
  }

  Widget _buildContent() {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 10),
          child: Column(
            children: [
              _buildUserInfoSection(),
              const SizedBox(height: 20),
            ],
          ),
        ),
        _buildPieChartSection(),
      ],
    );
  }

  Widget _buildUserInfoSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25),
      decoration: BoxDecoration(
        color: const Color(0xff365194).withOpacity(1),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 4),
            blurRadius: 20,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                Obx(() {
                  if (homeController.isLoading.value) {
                    return const CircularProgressIndicator();
                  }

                  final storeData = homeController.storeData.value;
                  final imageUrl = storeData?['gambar'];

                  return _buildProductImage(imageUrl ?? '');
                }),
                const SizedBox(width: 10),
                Expanded(
                  child: Obx(() {
                    if (homeController.isLoading.value) {
                      return const CircularProgressIndicator();
                    }

                    final storeData = homeController.storeData.value;
                    print('Store data: $storeData'); // Debug print
                    return Text.rich(
                      TextSpan(
                        text: 'Selamat Datang, ',
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Inter',
                          fontSize: 18,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: storeData?['nama_usaha'] ??
                                'Nama tidak ditemukan',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Inter',
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    );
                  }),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              margin: const EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(0, 4),
                    blurRadius: 20,
                    spreadRadius: 3,
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildCircularIconButton(
                    Icons.confirmation_num_outlined,
                    'Data',
                    'Tiket',
                    const Color(0xffFFAF00),
                    Colors.white,
                    onTap: () {
                      Get.offAllNamed(Routes.MANAJEMEN_TIKET);
                    },
                  ),
                  _buildCircularIconButton(
                    Icons.bar_chart,
                    'Riwayat',
                    'Penjualan',
                    const Color(0xff5475F9),
                    Colors.white,
                    onTap: () {
                      Get.offAllNamed(Routes.SALES_HISTORY);
                    },
                  ),
                  _buildCircularIconButton(
                    CupertinoIcons.cube_box,
                    'Data',
                    'Produk',
                    const Color(0xffF95454),
                    Colors.white,
                    onTap: () {
                      Get.offAllNamed(Routes.DAFTAR_PRODUK);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChartSection() {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.5,
      // Increase maxChildSize to allow more space when dragged up
      maxChildSize: 0.7,
      snap: true,
      builder: (BuildContext context, ScrollController scrollController) {
        return NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (OverscrollIndicatorNotification overscroll) {
            overscroll.disallowIndicator();
            return true;
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.98),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  spreadRadius: 1,
                  blurRadius: 12,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            // Wrap content in SingleChildScrollView to handle overflow
            child: SingleChildScrollView(
              controller: scrollController,
              child: Obx(() {
                if (homeController.isLoading.value) {
                  return SizedBox(
                    height: Get.height * 0.65,
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xff181681)),
                        strokeWidth: 3,
                      ),
                    ),
                  );
                } else if (homeController.pieChartData.isEmpty) {
                  return SizedBox(
                    height: Get.height * 0.65,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(25),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            CupertinoIcons.cube_box,
                            size: 80,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 40),
                          child: const Text(
                            'Tidak ada data pesanan yang dapat ditampilkan.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.5,
                              color: Color(0xFF757575),
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return Column(
                    mainAxisSize: MainAxisSize.min, // Add this to ensure column takes minimum required space
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(top: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Catatan Penjualan',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2D2D2D),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              child: DropdownButton<String>(
                                value: homeController.selectedFilter.value,
                                underline: SizedBox(),
                                icon: Icon(Icons.keyboard_arrow_down, size: 20),
                                items: <String>['Harian', 'Mingguan', 'Bulanan']
                                    .map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF2D2D2D),
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (newValue) {
                                  homeController.onFilterChanged(newValue!);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildPieChart(),
                      // Add bottom padding to ensure content isn't cut off when scrolled
                      SizedBox(height: 24),
                    ],
                  );
                }
              }),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPieChart() {
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: Column(
        children: [
          const SizedBox(height: 38),
          SizedBox(
            width: 200,
            height: 200,
            child: Stack(
              children: [
                PieChart(
                  PieChartData(
                    sections: homeController.pieChartData.map((data) {
                      return PieChartSectionData(
                        color: data.color,
                        value: data.value,
                        title: '${data.value.toStringAsFixed(1)}%',
                        radius: 50, // Reduced radius
                        titleStyle: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    }).toList(),
                    sectionsSpace: 2,
                    centerSpaceRadius: 75, // Increased center space radius
                  ),
                ),
                Center(
                  child: Text(
                    'Total\nPesanan:\nRp. ${NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(homeController.totalOrders.value)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularIconButton(
    IconData icon,
    String label1,
    String label2,
    Color circleColor,
    Color iconColor, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: circleColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 35,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label1,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontFamily: 'Inter',
            ),
          ),
          Text(
            label2,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage(String imageUrl) {
    if (imageUrl.isEmpty) {
      return _buildPlaceholderImage();
    }

    final token = homeController.getToken();

    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: CachedNetworkImage(
        imageUrl: imageUrl.startsWith('http')
            ? imageUrl
            : 'https://flexy.my.id/storage/$imageUrl',
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildLoadingPlaceholder(),
        errorWidget: (context, url, error) {
          print('Error loading image: $error');
          return _buildErrorImage();
        },
        cacheManager: CacheManager(
          Config(
            'customCacheKey',
            stalePeriod: const Duration(days: 7),
            maxNrOfCacheObjects: 100,
            repo: JsonCacheInfoRepository(databaseName: 'customCacheKey'),
            fileService: HttpFileService(httpClient: http.Client()),
          ),
        ) as BaseCacheManager?,
        fadeInDuration: const Duration(milliseconds: 500),
        fadeOutDuration: const Duration(milliseconds: 500),
        useOldImageOnUrlChange: true,
        cacheKey: imageUrl,
        httpHeaders: {
          'Authorization': 'Bearer $token',
          'Connection': 'keep-alive',
          'Keep-Alive': 'timeout=100, max=1000'
        },
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Icon(
        Icons.image,
        size: 30,
        color: Colors.grey[600],
      ),
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[600]!),
        ),
      ),
    );
  }

  Widget _buildErrorImage() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Icon(
        Icons.broken_image,
        size: 30,
        color: Colors.grey[600],
      ),
    );
  }
}
