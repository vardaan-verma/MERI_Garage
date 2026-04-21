import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'theme/app_theme.dart';

class WebViewScreen extends StatefulWidget {
  final String title;
  final String url;

  const WebViewScreen({super.key, required this.title, required this.url});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;
  int _loadingProgress = 0;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFF0F4F8))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() {
              _isLoading = true;
              _hasError = false;
              _loadingProgress = 0;
            });
          },
          onProgress: (progress) {
            setState(() {
              _loadingProgress = progress;
            });
          },
          onPageFinished: (url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (error) {
            setState(() {
              _isLoading = false;
              _hasError = true;
            });
          },
          onNavigationRequest: (request) {
            // Allow all navigation within merigarage.com/software
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  Future<void> _reload() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    await _controller.reload();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final canGoBack = await _controller.canGoBack();
        if (canGoBack) {
          await _controller.goBack();
        } else {
          if (context.mounted) Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F4F8),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
            onPressed: () async {
              if (await _controller.canGoBack()) {
                await _controller.goBack();
              } else {
                if (context.mounted) Navigator.of(context).pop();
              }
            },
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: GoogleFonts.inter(
                  color: Colors.black87,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'merigarage.com',
                style: GoogleFonts.inter(
                  color: Colors.black38,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: [
            // Reload button
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Colors.black54),
              onPressed: _reload,
              tooltip: 'Reload',
            ),
            // Open externally / share
            IconButton(
              icon: const Icon(Icons.open_in_browser_rounded, color: Colors.black54),
              tooltip: 'Open in browser',
              onPressed: () async {
                await _controller.loadRequest(Uri.parse(widget.url));
              },
            ),
            const SizedBox(width: 4),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(3),
            child: AnimatedOpacity(
              opacity: _isLoading ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: LinearProgressIndicator(
                value: _loadingProgress < 100 ? _loadingProgress / 100.0 : null,
                backgroundColor: Colors.transparent,
                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryRed),
                minHeight: 3,
              ),
            ),
          ),
        ),
        body: _hasError ? _buildErrorView() : WebViewWidget(controller: _controller),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryRed.withAlpha(15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                size: 56,
                color: AppTheme.primaryRed,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Unable to Connect',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Check your internet connection and try again.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.black45,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _reload,
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: Text(
                'Retry',
                style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.secondaryBlue,
                foregroundColor: Colors.white,
                minimumSize: const Size(160, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
