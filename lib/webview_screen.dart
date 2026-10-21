import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';
import 'theme/app_theme.dart';
import 'login_screen.dart';class WebViewScreen extends StatefulWidget {
  final String title;
  final String url;
  final bool showAppBar;

  const WebViewScreen({
    super.key,
    required this.title,
    required this.url,
    this.showAppBar = true,
  });

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  InAppWebViewController? _controller;
  bool _isLoading = true;
  bool _hasError = false;
  int _loadingProgress = 0;
  WebUri? _failedUrl;

  bool _isInvoiceOrPrintPage(String url) {
    final lowerUrl = url.toLowerCase();
    return lowerUrl.contains('print') ||
        lowerUrl.contains('invoice') ||
        lowerUrl.contains('pdf') ||
        lowerUrl.contains('bill') ||
        lowerUrl.contains('receipt') ||
        lowerUrl.contains('download') ||
        lowerUrl.contains('jobcard/view') ||
        lowerUrl.contains('jobcard/pdf');
  }

  @override
  void initState() {
    super.initState();
  }

  Future<void> _reload() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    if (_failedUrl != null) {
      final urlToLoad = _failedUrl!;
      _failedUrl = null;
      await _controller?.loadUrl(urlRequest: URLRequest(url: urlToLoad));
    } else {
      await _controller?.reload();
    }
  }

  Future<void> _handleBack() async {
    if (_controller != null && await _controller!.canGoBack()) {
      await _controller!.goBack();
      return;
    }
    if (!mounted) return;
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _handleBack();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F4F8),
        appBar: widget.showAppBar
            ? AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                scrolledUnderElevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
                  onPressed: _handleBack,
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/images/MeriGarage.png',
                      height: 20, // Adjust height as needed for AppBar
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 2),
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
                      if (_controller != null) {
                        final currentUrl = await _controller!.getUrl();
                        if (currentUrl != null) {
                          if (await canLaunchUrl(currentUrl)) {
                            await launchUrl(currentUrl, mode: LaunchMode.externalApplication);
                          }
                        }
                      }
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
              )
            : null,
        body: SafeArea(
          top: !widget.showAppBar,
          bottom: true,
          child: _hasError ? _buildErrorView() : InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(widget.url)),
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              useOnDownloadStart: true,
              domStorageEnabled: true,
              databaseEnabled: true,
              thirdPartyCookiesEnabled: true,
              sharedCookiesEnabled: true,
              mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
              allowFileAccess: true,
              allowContentAccess: true,
              useShouldOverrideUrlLoading: true,
            ),
            onWebViewCreated: (controller) {
              _controller = controller;
            },
            onLoadStart: (controller, url) {
              if (mounted) {
                setState(() {
                  _isLoading = true;
                  _hasError = false;
                  _loadingProgress = 0;
                });
              }
            },
            onProgressChanged: (controller, progress) {
              if (mounted) {
                setState(() {
                  _loadingProgress = progress;
                });
              }
            },
            onLoadStop: (controller, url) async {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                });
              }

              final urlStr = url?.toString() ?? "";
              final lowerUrlStr = urlStr.toLowerCase();

              // Intercept login page here as well, just in case
              if (lowerUrlStr.contains('login.php')) {
                if (mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                }
                return;
              }

              final isInvoice = _isInvoiceOrPrintPage(urlStr);

              // Combine Custom CSS and Viewport injection to reduce bridge calls
              String jsInjection = """
                (function() {
                  // Fix tables by wrapping them in scrollable divs to prevent breaking the mobile viewport
                  var tables = document.querySelectorAll('table');
                  tables.forEach(function(t) {
                    if (t.parentElement && !t.parentElement.classList.contains('table-responsive')) {
                      var wrapper = document.createElement('div');
                      wrapper.style.overflowX = 'auto';
                      wrapper.style.width = '100%';
                      wrapper.style.display = 'block';
                      wrapper.style.webkitOverflowScrolling = 'touch';
                      t.parentNode.insertBefore(wrapper, t);
                      wrapper.appendChild(t);
                    }
                  });

                  var style = document.createElement('style');
                  style.type = 'text/css';
                  style.innerHTML = '.table-responsive { overflow-x: auto !important; -webkit-overflow-scrolling: touch !important; display: block !important; width: 100% !important; } table { width: 100% !important; min-width: max-content !important; } td, th { white-space: nowrap !important; }';
                  
                  var meta = document.querySelector('meta[name="viewport"]');
                  if (!meta) {
                    meta = document.createElement('meta');
                    meta.name = 'viewport';
                    document.getElementsByTagName('head')[0].appendChild(meta);
                  }
              """;

              if (isInvoice) {
                jsInjection += """
                  meta.content = 'width=device-width, initial-scale=1.0, minimum-scale=0.25, maximum-scale=5.0, user-scalable=yes';
                  style.innerHTML += ' body { overflow-x: auto !important; -webkit-overflow-scrolling: touch !important; width: 100% !important; min-width: 320px !important; }';
                """;
              } else {
                jsInjection += """
                  meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
                """;
              }
              
              jsInjection += """
                  document.head.appendChild(style);
                })();
              """;

              try {
                await controller.evaluateJavascript(source: jsInjection);
              } catch (e) {
                debugPrint("Error injecting custom scripts: $e");
              }
            },
            onReceivedError: (controller, request, error) {
              if (request.isForMainFrame ?? true) {
                if (mounted) {
                  setState(() {
                    _failedUrl = request.url;
                    _isLoading = false;
                    _hasError = true;
                  });
                }
              }
            },
            shouldOverrideUrlLoading: (controller, navigationAction) async {
              final uri = navigationAction.request.url;
              if (uri == null) return NavigationActionPolicy.ALLOW;

              final uriStr = uri.toString().toLowerCase();

              // If session expires or user logs out, go back to app login
              if (uriStr.contains('login.php')) {
                if (mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                }
                return NavigationActionPolicy.CANCEL;
              }

              // If it's a PDF, open externally to prevent back button loops.
              // Reports (print/download) are now allowed to load inside the app.
              if (uriStr.endsWith('.pdf')) {
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                  return NavigationActionPolicy.CANCEL;
                }
              }

              return NavigationActionPolicy.ALLOW;
            },
            onDownloadStartRequest: (controller, downloadStartRequest) async {
              final uri = downloadStartRequest.url;
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
              // Automatically go back if a download leaves us on a blank page
              if (await controller.canGoBack()) {
                await controller.goBack();
              }
            },
          ),
        ),
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
