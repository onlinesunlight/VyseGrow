import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class WPService {
  static const String baseUrl = "https://vysegrow.com/wp-json";
  static const String _menuCacheKey = "cached_primary_menu";
  static const String _marketCacheKey = "cached_market_data";

  static String parseHtmlTitle(String text) {
    return text
        .replaceAll('&amp;', '&')
        .replaceAll('&#038;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'");
  }

  // 1. Dynamic Welcome Banner Fetcher
  static Future<Map<String, String>?> fetchWelcomeBanner() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/vysegrow/v1/welcome-banner'))
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'title': data['title'] ?? 'Hello Investor 👋',
          'subtitle': data['subtitle'] ?? 'Smart Growth. Strong Wealth.',
          'badge': data['badge'] ?? '2026 Edition',
        };
      }
    } catch (e) {
      debugPrint("Error fetching welcome banner: $e");
    }
    return null;
  }

  // 2. Primary Menu Fetcher
  static Future<List<dynamic>> fetchPrimaryMenu() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/vysegrow/v1/primary-menu'))
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        await prefs.setString(_menuCacheKey, response.body);
        return data;
      }
    } catch (e) {}

    final String? cachedData = prefs.getString(_menuCacheKey);
    if (cachedData != null && cachedData.isNotEmpty) {
      try {
        return json.decode(cachedData);
      } catch (e) {}
    }
    return [];
  }

  // 3. Notifications
  static Future<List<dynamic>> fetchNotifications() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/app/v1/notifications'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) return data;
      }
    } catch (e) {
      debugPrint("Error fetching notifications: $e");
    }
    return [];
  }

  // 4. Bulletproof Live Market Engine with Local Storage Backup
  static Future<Map<String, dynamic>?> fetchMarketData() async {
    final prefs = await SharedPreferences.getInstance();

    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      Future<Map<String, dynamic>?> getIndexData(String symbol) async {
        final rawUrl =
            'https://query1.finance.yahoo.com/v8/finance/chart/$symbol?range=1d&interval=5m';

        final List<String> proxyUrls = kIsWeb
            ? [
                'https://api.allorigins.win/raw?url=${Uri.encodeComponent(rawUrl)}',
                'https://corsproxy.io/?${Uri.encodeComponent(rawUrl)}&_t=$timestamp',
              ]
            : [rawUrl];

        for (String url in proxyUrls) {
          try {
            final res = await http
                .get(Uri.parse(url))
                .timeout(const Duration(seconds: 3));
            if (res.statusCode == 200) {
              final result = json.decode(res.body)['chart']['result'][0];
              final List ts = result['timestamp'] ?? [];
              final List cl = result['indicators']['quote'][0]['close'] ?? [];
              List<Map<String, dynamic>> pts = [];

              for (int i = 0; i < ts.length && i < cl.length; i++) {
                if (ts[i] != null && cl[i] != null) {
                  pts.add({
                    't': (ts[i] as num).toInt(),
                    'p': (cl[i] as num).toDouble(),
                  });
                }
              }

              final double prevClose =
                  ((result['meta']['chartPreviousClose'] ??
                              result['meta']['previousClose'] ??
                              0.0)
                          as num)
                      .toDouble();
              final double price =
                  ((result['meta']['regularMarketPrice'] ?? 0.0) as num)
                      .toDouble();

              if (price > 0) {
                return {'pts': pts, 'prevClose': prevClose, 'price': price};
              }
            }
          } catch (e) {}
        }
        return null;
      }

      final niftyRes = await getIndexData('%5ENSEI');
      final sensexRes = await getIndexData('%5EBSESN');

      if (niftyRes != null && sensexRes != null) {
        final now = DateTime.now();
        final months = [
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
        final formattedDate =
            "${now.day} ${months[now.month - 1]}, ${now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour)}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'pm' : 'am'} IST";

        Map<String, dynamic> makeTab(Map<String, dynamic> d) => {
          '1D': d,
          '5D': d,
          '1M': d,
          '6M': d,
          '1Y': d,
          '5Y': d,
          'Max': d,
        };

        final resultMap = {
          'time': formattedDate,
          'nifty': {
            'price': (niftyRes['price'] as double).toStringAsFixed(2),
            'tabs': makeTab(niftyRes),
          },
          'sensex': {
            'price': (sensexRes['price'] as double).toStringAsFixed(2),
            'tabs': makeTab(sensexRes),
          },
        };

        // Cache last successful data
        await prefs.setString(_marketCacheKey, json.encode(resultMap));
        return resultMap;
      }
    } catch (e) {
      debugPrint("Live Market Error: $e");
    }

    // Fallback 1: Return Cached Data if available
    final String? cached = prefs.getString(_marketCacheKey);
    if (cached != null && cached.isNotEmpty) {
      try {
        return json.decode(cached);
      } catch (e) {}
    }

    // Fallback 2: Instant Default Values (Prevents Infinite Loading Spinner)
    final now = DateTime.now();
    return {
      'time': "${now.day} Jul, 03:30 pm IST",
      'nifty': {
        'price': "24834.85",
        'tabs': {
          '1D': {
            'pts': [
              {'t': 1722300000, 'p': 24780.0},
              {'t': 1722320000, 'p': 24834.85},
            ],
            'prevClose': 24780.0,
            'price': 24834.85,
          },
        },
      },
      'sensex': {
        'price': "81332.72",
        'tabs': {
          '1D': {
            'pts': [
              {'t': 1722300000, 'p': 81100.0},
              {'t': 1722320000, 'p': 81332.72},
            ],
            'prevClose': 81100.0,
            'price': 81332.72,
          },
        },
      },
    };
  }
}
