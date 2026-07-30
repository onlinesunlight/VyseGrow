import 'dart:async';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fl_chart/fl_chart.dart';
import 'wp_service.dart';
import 'post_detail_screen.dart';
import 'notification_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<Map<String, dynamic>?> _marketDataFuture;
  late Future<Map<String, String>?> _welcomeBannerFuture;
  Timer? _marketTimer;
  bool _isRefreshingMarket = false;

  final String phoneNumber = "+919451663807";
  final String emailAddress = "info@vysegrow.com";

  @override
  void initState() {
    super.initState();
    _fetchMarketData();
    _welcomeBannerFuture = WPService.fetchWelcomeBanner();

    _marketTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (mounted) {
        _fetchMarketDataSilently();
      }
    });
  }

  void _fetchMarketData() {
    setState(() {
      _marketDataFuture = WPService.fetchMarketData();
    });
  }

  void _fetchMarketDataSilently() async {
    final newData = await WPService.fetchMarketData();
    if (newData != null && mounted) {
      setState(() {
        _marketDataFuture = Future.value(newData);
      });
    }
  }

  Future<void> _manualRefreshMarket() async {
    if (_isRefreshingMarket) return;
    setState(() {
      _isRefreshingMarket = true;
    });
    final newData = await WPService.fetchMarketData();
    if (newData != null && mounted) {
      setState(() {
        _marketDataFuture = Future.value(newData);
      });
    }
    if (mounted) {
      setState(() {
        _isRefreshingMarket = false;
      });
    }
  }

  @override
  void dispose() {
    _marketTimer?.cancel();
    super.dispose();
  }

  Future<void> _makePhoneCall(String phone) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phone.replaceAll(' ', ''));
    if (await canLaunchUrl(launchUri)) await launchUrl(launchUri);
  }

  Future<void> _sendEmail(String email) async {
    final Uri launchUri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(launchUri)) await launchUrl(launchUri);
  }

  Future<void> _openOFAApp() async {
    const String packageName = 'com.ofaclientapp';
    final Uri appUri = Uri.parse('ofaclientapp://');
    final Uri playStoreUri = Uri.parse(
      'https://play.google.com/store/apps/details?id=$packageName',
    );

    try {
      if (await canLaunchUrl(appUri)) {
        await launchUrl(appUri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(playStoreUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      await launchUrl(playStoreUri, mode: LaunchMode.externalApplication);
    }
  }

  int _parseId(dynamic val) {
    if (val == null) return 0;
    if (val is int) return val;
    return int.tryParse(val.toString()) ?? 0;
  }

  int _getParentId(Map item) {
    return _parseId(
      item['parent_id'] ??
          item['menu_item_parent'] ??
          item['parent'] ??
          item['post_parent'],
    );
  }

  int _getItemId(Map item) {
    return _parseId(item['id'] ?? item['ID']);
  }

  final List<Map<String, dynamic>> manualSliderData = [
    {
      'tag': 'WEALTH CREATION',
      'title': '₹5,000/Mo SIP Can Build ₹1 Crore+',
      'desc': 'Leverage compounding growth with top equity mutual funds.',
      'btnText': 'Calculate Growth ➔',
      'badgeText': 'Up to 15% CAGR',
      'url': 'https://vysegrow.com/wealth-creation',
      'gradient': [const Color(0xFF0F172A), const Color(0xFF1E293B)],
      'accentColor': const Color(0xFF22C55E),
      'icon': Icons.trending_up_rounded,
      'content':
          '<h2>Power of SIP & Compounding</h2><p>Start early to maximize your returns through systematic monthly investments.</p>',
    },
    {
      'tag': 'FREE PORTFOLIO CHECK',
      'title': 'Is Your Investment Underperforming?',
      'desc': 'Get a 100% Free expert review & optimize your fund allocation.',
      'btnText': 'Get Free Review ➔',
      'badgeText': '100% FREE',
      'url': 'https://vysegrow.com/portfolio-review',
      'gradient': [const Color(0xFF1E1B4B), const Color(0xFF312E81)],
      'accentColor': const Color(0xFF38BDF8),
      'icon': Icons.pie_chart_outline_rounded,
      'content':
          '<h2>Portfolio Review Service</h2><p>Our SEBI registered partners review your portfolio for risk and return balancing.</p>',
    },
    {
      'tag': 'TAX SAVING UNDER 80C',
      'title': 'Save up to ₹46,800 Tax Every Year',
      'desc':
          'Invest in ELSS funds with lowest lock-in (3 Yrs) & higher returns.',
      'btnText': 'Save Tax Now ➔',
      'badgeText': 'Lowest Lock-in',
      'url': 'https://vysegrow.com/save-tax-under-80c',
      'gradient': [const Color(0xFF2E1065), const Color(0xFF4C1D95)],
      'accentColor': const Color(0xFFF43F5E),
      'icon': Icons.verified_user_rounded,
      'content':
          '<h2>ELSS Tax Saving Mutual Funds</h2><p>Save tax under Section 80C while earning wealth with market-linked equity returns.</p>',
    },
  ];

  final List<Map<String, dynamic>> quickButtons = [
    {
      'title': 'Mutual Fund Smart Trick',
      'icon': Icons.trending_up_rounded,
      'color': const Color(0xFF2196F3),
      'url': 'https://vysegrow.com/mutual-fund',
    },
    {
      'title': 'Portfolio Review',
      'icon': Icons.pie_chart_outline_rounded,
      'color': Colors.teal,
      'url': 'https://vysegrow.com/portfolio-review',
    },
    {
      'title': 'Calculator',
      'icon': Icons.calculate_rounded,
      'color': Colors.deepOrange,
      'url': 'https://vysegrow.com/calculator',
    },
    {
      'title': 'Events',
      'icon': Icons.event_available_rounded,
      'color': Colors.purple,
      'url': 'https://vysegrow.com/events',
    },
    {
      'title': 'Financial Planning',
      'icon': Icons.assignment_turned_in_rounded,
      'color': Colors.blue,
      'url': 'https://vysegrow.com/financial-planning',
    },
    {
      'title': 'Invest Now',
      'icon': Icons.rocket_launch_rounded,
      'color': Colors.green,
      'url': 'https://vysegrow.com/invest-now',
    },
  ];

  final List<Map<String, String>> footerLinks = [
    {'title': 'About Us', 'url': 'https://vysegrow.com/about-us'},
    {'title': 'Privacy Policy', 'url': 'https://vysegrow.com/privacy-policy'},
    {
      'title': 'Terms & Conditions',
      'url': 'https://vysegrow.com/terms-conditions',
    },
    {'title': 'Contact Support', 'url': 'https://vysegrow.com/contact-us'},
  ];

  void _openDetailScreenWithData(
    String title,
    String htmlContent,
    String url,
  ) async {
    final String cleanTitle = WPService.parseHtmlTitle(title);

    if (url.isNotEmpty && url != '#' && !url.contains('vysegrow.com')) {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostDetailScreen(
          post: {
            'title': {'rendered': cleanTitle},
            'content': {'rendered': htmlContent},
            'url': url,
          },
        ),
      ),
    );
  }

  Widget _buildWelcomeBanner() {
    return FutureBuilder<Map<String, String>?>(
      future: _welcomeBannerFuture,
      builder: (context, snapshot) {
        String title = "Hello Investor 👋";
        String subtitle =
            "Smart Growth. Strong Wealth. Build your financial future with VyseGrow.";
        String badge = "2026 Edition";

        if (snapshot.hasData && snapshot.data != null) {
          title = snapshot.data!['title'] ?? title;
          subtitle = snapshot.data!['subtitle'] ?? subtitle;
          badge = snapshot.data!['badge'] ?? badge;
        }

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1565C0).withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 12,
                  height: 1.3,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(105),
        child: Container(
          color: Colors.white,
          child: SafeArea(
            top: true,
            bottom: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  color: const Color(0xFF2196F3),
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () => _makePhoneCall(phoneNumber),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.phone_in_talk_rounded,
                              size: 12,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              phoneNumber,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      InkWell(
                        onTap: () => _sendEmail(emailAddress),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.email_rounded,
                              size: 12,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              emailAddress,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x0D000000),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Builder(
                        builder: (context) => InkWell(
                          onTap: () => Scaffold.of(context).openDrawer(),
                          child: const Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Icon(
                              Icons.menu_rounded,
                              color: Color(0xFF2196F3),
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                      Image.asset(
                        'assets/applogo.png',
                        height: 38,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const Text(
                              'VYSEGROW CAPITALS',
                              style: TextStyle(
                                color: Color(0xFF1565C0),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.notifications_none_rounded,
                              color: Color(0xFF2196F3),
                              size: 26,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const NotificationScreen(),
                                ),
                              );
                            },
                            tooltip: 'Notifications',
                          ),
                          const SizedBox(width: 4),
                          Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF4CAF50,
                                  ).withValues(alpha: 0.35),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(25),
                                onTap: _openOFAApp,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 7,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(
                                        Icons.login_rounded,
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Login',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2196F3), Color(0xFF1565C0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                      onPressed: () => Navigator.pop(context),
                      tooltip: 'Close Menu',
                    ),
                  ),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.show_chart_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'VyseGrow Capitals',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Smart Growth. Strong Wealth.',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.grid_view_rounded,
                color: Color(0xFF2196F3),
              ),
              title: const Text(
                'Dashboard',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () => Navigator.pop(context),
            ),
            const Divider(height: 1),
            const Padding(
              padding: EdgeInsets.only(left: 16, top: 16, bottom: 8),
              child: Text(
                'EXPLORE CATEGORIES',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            FutureBuilder<List<dynamic>>(
              future: WPService.fetchPrimaryMenu(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(
                        color: Color(0xFF2196F3),
                      ),
                    ),
                  );
                } else if (snapshot.hasError ||
                    !snapshot.hasData ||
                    snapshot.data!.isEmpty) {
                  return const ListTile(title: Text('No Menu Items Found'));
                }

                final List<dynamic> rawList = snapshot.data!;
                final List<Map<String, dynamic>> allItems = rawList
                    .map((e) => Map<String, dynamic>.from(e))
                    .toList();

                final rootItems = allItems
                    .where((item) => _getParentId(item) == 0)
                    .toList();

                return Column(
                  children: rootItems.map((parent) {
                    final int parentId = _getItemId(parent);
                    String parentTitle = WPService.parseHtmlTitle(
                      parent['title'] ?? 'Menu',
                    );

                    final children = allItems
                        .where(
                          (item) =>
                              _getParentId(item) == parentId && parentId != 0,
                        )
                        .toList();

                    void handleMenuTap(
                      Map<String, dynamic> menuItem,
                      String displayTitle,
                    ) {
                      Navigator.pop(context);
                      final String content = menuItem['content'] ?? '';
                      final String url = menuItem['url'] ?? '';
                      _openDetailScreenWithData(displayTitle, content, url);
                    }

                    if (children.isNotEmpty) {
                      return ExpansionTile(
                        leading: const Icon(
                          Icons.folder_outlined,
                          color: Color(0xFF2196F3),
                          size: 20,
                        ),
                        title: Text(
                          parentTitle,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF102A43),
                          ),
                        ),
                        children: children.map((child) {
                          String childTitle = WPService.parseHtmlTitle(
                            child['title'] ?? 'Submenu',
                          );
                          return ListTile(
                            contentPadding: const EdgeInsets.only(
                              left: 32,
                              right: 16,
                            ),
                            leading: const Icon(
                              Icons.arrow_right_rounded,
                              color: Color(0xFF2196F3),
                              size: 20,
                            ),
                            title: Text(
                              childTitle,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            onTap: () => handleMenuTap(child, childTitle),
                          );
                        }).toList(),
                      );
                    }

                    return ListTile(
                      leading: const Icon(
                        Icons.insert_drive_file_outlined,
                        color: Color(0xFF2196F3),
                        size: 20,
                      ),
                      title: Text(
                        parentTitle,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF102A43),
                        ),
                      ),
                      onTap: () => handleMenuTap(parent, parentTitle),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            _buildWelcomeBanner(),

            CustomBlockCard(
              child: CarouselSlider(
                options: CarouselOptions(
                  height: 185.0,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 4),
                  enlargeCenterPage: true,
                  viewportFraction: 0.98,
                ),
                items: manualSliderData.map((item) {
                  final Color accentColor = item['accentColor'];
                  final List<Color> gradientColors = item['gradient'];

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: gradientColors.last.withValues(alpha: 0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: accentColor.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: accentColor.withValues(alpha: 0.5),
                                ),
                              ),
                              child: Text(
                                item['tag']!,
                                style: TextStyle(
                                  color: accentColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white10,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    item['icon'],
                                    size: 12,
                                    color: accentColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    item['badgeText']!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['title']!,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['desc']!,
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: Colors.white70,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: InkWell(
                            onTap: () => _openDetailScreenWithData(
                              item['title']!,
                              item['content']!,
                              item['url']!,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: accentColor,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: accentColor.withValues(alpha: 0.4),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                item['btnText']!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 16, top: 10, bottom: 2),
              child: Text(
                'QUICK SERVICES & GUIDES',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1565C0),
                ),
              ),
            ),
            CustomBlockCard(
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.05,
                ),
                itemCount: quickButtons.length,
                itemBuilder: (context, index) {
                  final btn = quickButtons[index];
                  return InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _openDetailScreenWithData(
                      btn['title'],
                      '<p>Details for ${btn['title']}</p>',
                      btn['url'],
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: btn['color'].withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: btn['color'].withValues(
                              alpha: 0.12,
                            ),
                            child: Icon(
                              btn['icon'],
                              size: 20,
                              color: btn['color'],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            btn['title'],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 10,
                bottom: 2,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'LIVE MARKET INDICATORS & CHARTS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1565C0),
                    ),
                  ),
                  InkWell(
                    onTap: _manualRefreshMarket,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A73E8).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _isRefreshingMarket
                              ? const SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFF1A73E8),
                                  ),
                                )
                              : const Icon(
                                  Icons.refresh_rounded,
                                  size: 14,
                                  color: Color(0xFF1A73E8),
                                ),
                          const SizedBox(width: 4),
                          Text(
                            _isRefreshingMarket ? "Updating..." : "Refresh",
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A73E8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            FutureBuilder<Map<String, dynamic>?>(
              future: _marketDataFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CustomBlockCard(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  );
                }
                final market = snapshot.data!;
                final nifty = market['nifty'];
                final sensex = market['sensex'];
                return Column(
                  children: [
                    GoogleStyleMarketCard(
                      title: "NIFTY 50",
                      exchange: "NSE LIVE",
                      price: nifty['price'],
                      tabData: (nifty['tabs'] as Map<String, dynamic>).map(
                        (k, v) => MapEntry(k, v as Map<String, dynamic>),
                      ),
                      marketTime: market['time'],
                    ),
                    GoogleStyleMarketCard(
                      title: "SENSEX",
                      exchange: "BSE LIVE",
                      price: sensex['price'],
                      tabData: (sensex['tabs'] as Map<String, dynamic>).map(
                        (k, v) => MapEntry(k, v as Map<String, dynamic>),
                      ),
                      marketTime: market['time'],
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              color: const Color(0xFF102A43),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'VYSEGROW CAPITALS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'VyseGrow Capitals is an AMFI-registered Mutual Fund Distribution platform owned by Ravindra Kumar Dubrey (ARN: 103077, EUIN: E130662). Empowering your financial journey through strategic investments, smart portfolio management, and long-term wealth creation.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Colors.white24, height: 1),
                  const SizedBox(height: 16),
                  const Text(
                    'QUICK LINKS',
                    style: TextStyle(
                      color: Color(0xFF64B5F6),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: footerLinks.map((link) {
                      return InkWell(
                        onTap: () => _openDetailScreenWithData(
                          link['title']!,
                          '<p>Loading ${link['title']}...</p>',
                          link['url']!,
                        ),
                        child: Text(
                          link['title']!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              size: 14,
                              color: Color(0xFF64B5F6),
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Legal Disclaimer',
                              style: TextStyle(
                                color: Color(0xFF64B5F6),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Market data, charts, and indices displayed are sourced from public aggregators for informational and tracking purposes only. Mutual Fund investments are subject to market risks, read all scheme related documents carefully before investing.',
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 10.5,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Align(
                    alignment: Alignment.center,
                    child: Text(
                      '© 2026 VyseGrow Capitals. All Rights Reserved.',
                      style: TextStyle(color: Colors.white54, fontSize: 11),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.center,
                    child: InkWell(
                      onTap: () => _openDetailScreenWithData(
                        'SUNLIGHT DIGITAL SOLUTIONS',
                        '<h2>SUNLIGHT DIGITAL SOLUTIONS</h2><p>Proudly developed by Sunlight Digital Solutions.</p>',
                        '#',
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Developed by ',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 11,
                            ),
                          ),
                          Text(
                            'SUNLIGHT DIGITAL SOLUTIONS',
                            style: TextStyle(
                              color: Color(0xFF64B5F6),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GoogleStyleMarketCard extends StatefulWidget {
  final String title;
  final String exchange;
  final String price;
  final Map<String, Map<String, dynamic>> tabData;
  final String marketTime;

  const GoogleStyleMarketCard({
    super.key,
    required this.title,
    required this.exchange,
    required this.price,
    required this.tabData,
    required this.marketTime,
  });

  @override
  State<GoogleStyleMarketCard> createState() => _GoogleStyleMarketCardState();
}

class _GoogleStyleMarketCardState extends State<GoogleStyleMarketCard> {
  String _selectedTimeframe = '1D';

  DateTime _getISTDate(int timestampSeconds) {
    return DateTime.fromMillisecondsSinceEpoch(
      timestampSeconds * 1000,
      isUtc: true,
    ).add(const Duration(hours: 5, minutes: 30));
  }

  @override
  Widget build(BuildContext context) {
    final currentTab =
        widget.tabData[_selectedTimeframe] ?? widget.tabData['1D'] ?? {};
    List<Map<String, dynamic>> activePoints =
        (currentTab['pts'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    double currentVal = double.tryParse(widget.price) ?? 0.0;

    double startVal = (currentTab['prevClose'] as num?)?.toDouble() ?? 0.0;
    if (startVal == 0.0 && activePoints.isNotEmpty) {
      startVal = (activePoints.first['p'] as num).toDouble();
    }

    double changeVal = currentVal - startVal;
    double percentVal = startVal != 0 ? (changeVal / startVal) * 100 : 0.0;
    bool isPositive = changeVal >= 0;

    final Color lineColor = isPositive
        ? const Color(0xFF00C853)
        : const Color(0xFFD50000);

    List<FlSpot> spots = [];
    for (int i = 0; i < activePoints.length; i++) {
      spots.add(FlSpot(i.toDouble(), (activePoints[i]['p'] as num).toDouble()));
    }

    double minY = 0, maxY = 100;
    if (spots.isNotEmpty) {
      double minVal = spots.map((e) => e.y).reduce((a, b) => a < b ? a : b);
      double maxVal = spots.map((e) => e.y).reduce((a, b) => a > b ? a : b);
      double padding = (maxVal - minVal) * 0.1;
      minY = minVal - (padding == 0 ? 10 : padding);
      maxY = maxVal + (padding == 0 ? 10 : padding);
    }

    double labelInterval = 1.0;
    if (spots.length > 1) {
      if (_selectedTimeframe == '6M' || _selectedTimeframe == '1Y') {
        labelInterval = (spots.length - 1) / 5.0;
      } else {
        labelInterval = (spots.length - 1) / 4.0;
      }
      if (labelInterval < 0.1) labelInterval = 1.0;
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDEFEF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F3F4),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  widget.exchange,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF5F6368),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                "₹${widget.price}",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isPositive
                      ? const Color(0xFFE6F4EA)
                      : const Color(0xFFFCE8E6),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(
                      isPositive
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                      size: 14,
                      color: lineColor,
                    ),
                    Text(
                      "${isPositive ? '+' : ''}${changeVal.toStringAsFixed(2)} (${percentVal.toStringAsFixed(2)}%)",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: lineColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Text(
                widget.marketTime,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF70757A),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Text(" • ", style: TextStyle(color: Colors.grey)),
              const Text(
                "Live Data",
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF1A73E8),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['1D', '5D', '1M', '6M', '1Y', '5Y', 'Max'].map((tf) {
                final bool isSelected = _selectedTimeframe == tf;
                return InkWell(
                  onTap: () => setState(() => _selectedTimeframe = tf),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF1A73E8)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      tf,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.grey.shade700,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          if (spots.isNotEmpty)
            SizedBox(
              height: 180,
              width: double.infinity,
              child: LineChart(
                LineChartData(
                  minY: minY,
                  maxY: maxY,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: (maxY - minY) / 3,
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: widget.title == "SENSEX" ? 52 : 45,
                        getTitlesWidget: (value, meta) => Text(
                          value.toStringAsFixed(0),
                          style: const TextStyle(
                            color: Color(0xFF70757A),
                            fontSize: 9.5,
                          ),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 22,
                        interval: labelInterval,
                        getTitlesWidget: (value, meta) {
                          String label = "";
                          int spotCount = activePoints.length;
                          if (spotCount > 0) {
                            int labelIndex = (value / labelInterval)
                                .round()
                                .clamp(0, 5);
                            int ptIdx = (labelIndex * labelInterval)
                                .round()
                                .clamp(0, spotCount - 1);
                            int timestamp = activePoints[ptIdx]['t'];
                            DateTime date = _getISTDate(timestamp);

                            if (_selectedTimeframe == '1D') {
                              const times = [
                                '9:30 am',
                                '11:00 am',
                                '12:30 pm',
                                '2:00 pm',
                                '3:30 pm',
                              ];
                              label = times[labelIndex.clamp(0, 4)];
                            } else if (_selectedTimeframe == '5D' ||
                                _selectedTimeframe == '1M') {
                              label =
                                  "${date.day} ${_getMonthName(date.month)}";
                            } else if (_selectedTimeframe == '6M' ||
                                _selectedTimeframe == '1Y') {
                              label = _getMonthName(date.month);
                            } else {
                              label = "${date.year}";
                            }
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              label,
                              style: const TextStyle(
                                color: Color(0xFF70757A),
                                fontSize: 9,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: const Border(
                      bottom: BorderSide(color: Color(0xFFDADCE0)),
                      left: BorderSide(color: Color(0xFFDADCE0)),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: lineColor,
                      barWidth: 2.2,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            lineColor.withValues(alpha: 0.35),
                            lineColor.withValues(alpha: 0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}

class CustomBlockCard extends StatelessWidget {
  final Widget child;
  const CustomBlockCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFECEFF1)),
      ),
      child: child,
    );
  }
}
