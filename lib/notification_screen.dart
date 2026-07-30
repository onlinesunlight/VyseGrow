import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'wp_service.dart';
import 'post_detail_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late Future<List<dynamic>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _notificationsFuture = WPService.fetchNotifications();
  }

  void _handleNotificationTap(Map<String, dynamic> item) async {
    final String url = item['url'] ?? '';
    final String title = item['title'] ?? 'Notification';
    final String message = item['message'] ?? '';

    if (url.isEmpty || url == '#') return;

    // External link logic (if outside vysegrow)
    if (!url.contains('vysegrow.com')) {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      return;
    }

    // Open inside Detail Screen Webview
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PostDetailScreen(
            post: {
              'title': {'rendered': title},
              'content': {'rendered': '<p>$message</p>'},
              'url': url,
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        title: const Text(
          'Notifications',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        elevation: 2,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _notificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF2196F3)),
            );
          } else if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'No notifications yet',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }

          final notifications = snapshot.data!;

          return RefreshIndicator(
            color: const Color(0xFF2196F3),
            onRefresh: () async {
              setState(() {
                _notificationsFuture = WPService.fetchNotifications();
              });
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final item = Map<String, dynamic>.from(notifications[index]);
                final String title = WPService.parseHtmlTitle(
                  item['title'] ?? 'Notification',
                );
                final String message = item['message'] ?? '';
                final String date = item['date'] ?? '';
                final String url = item['url'] ?? '';

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFECEFF1)),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _handleNotificationTap(item),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: const Color(
                              0xFF2196F3,
                            ).withValues(alpha: 0.1),
                            child: const Icon(
                              Icons.notifications_active_rounded,
                              color: Color(0xFF2196F3),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        title,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF102A43),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (url.isNotEmpty && url != '#')
                                      const Icon(
                                        Icons.chevron_right_rounded,
                                        size: 18,
                                        color: Colors.grey,
                                      ),
                                  ],
                                ),
                                if (message.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    message,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade700,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                                if (date.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    date,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
