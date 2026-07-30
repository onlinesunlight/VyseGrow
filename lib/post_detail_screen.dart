import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'wp_service.dart';

// Web Compatibility Imports
import 'dart:ui_web' as ui;
import 'package:web/web.dart' as web;

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
  late String _iframeViewType;
  bool _isLoading = true;
  int _loadingProgress = 0;
  StreamSubscription? _webMessageSubscription;

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
    if (kIsWeb) {
      _iframeViewType = 'iframe-view-${DateTime.now().millisecondsSinceEpoch}';

      // Register HTML IFrame Element for Web Platform
      ui.platformViewRegistry.registerViewFactory(_iframeViewType, (
        int viewId,
      ) {
        final iframe = web.HTMLIFrameElement();
        iframe.src = _finalUrl;
        iframe.style.border = 'none';
        iframe.style.width = '100%';
        iframe.style.height = '100%';

        return iframe;
      });

      // Listen to postMessage from Website JS (Web / Iframe)
      _webMessageSubscription = web.window.onMessage.listen((
        web.MessageEvent event,
      ) {
        if (event.data != null && mounted) {
          final String message = event.data.toString();
          // Filter out JSON strings or empty messages
          if (message.isNotEmpty && !message.contains('{')) {
            setState(() {
              _currentTitle = WPService.parseHtmlTitle(message);
            });
          }
        }
      });

      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      });
    } else {
      // Native WebViewController for Android & iOS Mobile Devices
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

                // Fetch page title automatically via document.title evaluation
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
  void dispose() {
    _webMessageSubscription?.cancel();
    super.dispose();
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
                if (kIsWeb) {
                  setState(() {});
                } else {
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
                  ? HtmlElementView(viewType: _iframeViewType)
                  : WebViewWidget(controller: _controller!),
            ),
          ],
        ),
      ),
    );
  }
}
