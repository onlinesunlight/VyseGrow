import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'wp_service.dart';

class PostDetailScreen extends StatefulWidget {
  final Map<String, dynamic> post;

  const PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  WebViewController? _controller;
  late String _currentTitle;
  late String _finalUrl;
  bool _isLoading = true;
  int _loadingProgress = 0;

  @override
  void initState() {
    super.initState();

    // 1. Initial Title Extraction
    String rawTitle = '';
    if (widget.post['title'] is Map) {
      rawTitle = widget.post['title']['rendered'] ?? '';
    } else if (widget.post['title'] is String) {
      rawTitle = widget.post['title'] ?? '';
    }
    _currentTitle = WPService.parseHtmlTitle(rawTitle);
    if (_currentTitle.isEmpty) {
      _currentTitle = 'VyseGrow Capitals';
    }

    // 2. Page URL Setup with app_view=true
    String pageUrl = widget.post['url'] ?? 'https://vysegrow.com';
    if (pageUrl == '#' || pageUrl.isEmpty) {
      pageUrl = 'https://vysegrow.com';
    }
    if (pageUrl.contains('?')) {
      _finalUrl = '$pageUrl&app_view=true';
    } else {
      _finalUrl = '$pageUrl?app_view=true';
    }

    // 3. Platform Specific Handling
    if (!kIsWeb) {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.white)
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (int progress) {
              if (mounted) {
                setState(() {
                  _loadingProgress = progress;
                });
              }
            },
            onPageStarted: (String url) {
              if (mounted) {
                setState(() {
                  _isLoading = true;
                });
              }
            },
            onPageFinished: (String url) async {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                });

                try {
                  final rawJsTitle = await _controller
                      ?.runJavaScriptReturningResult('document.title');
                  if (rawJsTitle != null && mounted) {
                    String cleanTitle = rawJsTitle
                        .toString()
                        .replaceAll('"', '')
                        .trim();
                    if (cleanTitle.isNotEmpty) {
                      setState(() {
                        _currentTitle = WPService.parseHtmlTitle(cleanTitle);
                      });
                    }
                  }
                } catch (e) {
                  debugPrint('Error reading document.title via JS: $e');
                }
              }
            },
            onWebResourceError: (WebResourceError error) {
              debugPrint('WebView Error: ${error.description}');
            },
          ),
        )
        ..addJavaScriptChannel(
          'FlutterChannel',
          onMessageReceived: (JavaScriptMessage message) {
            if (mounted && message.message.isNotEmpty) {
              setState(() {
                _currentTitle = WPService.parseHtmlTitle(message.message);
              });
            }
          },
        );

      _controller!.loadRequest(Uri.parse(_finalUrl));
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (!kIsWeb && _controller != null && await _controller!.canGoBack()) {
          await _controller!.goBack();
        } else {
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color(0xFF2196F3),
          foregroundColor: Colors.white,
          title: Text(
            _currentTitle,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          elevation: 2,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () {
                if (!kIsWeb) {
                  _controller?.reload();
                }
              },
              tooltip: 'Reload Page',
            ),
          ],
        ),
        body: Column(
          children: [
            if (_isLoading && !kIsWeb)
              LinearProgressIndicator(
                value: _loadingProgress / 100.0,
                backgroundColor: Colors.blue.shade50,
                color: const Color(0xFF2196F3),
                minHeight: 3,
              ),
            Expanded(
              child: kIsWeb
                  ? const Center(
                      child: Text(
                        'Web Preview Not Supported directly in Mobile Mode',
                      ),
                    )
                  : WebViewWidget(controller: _controller!),
            ),
          ],
        ),
      ),
    );
  }
}
