import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PortalPage extends StatefulWidget {
  final String sessionURL;

  const PortalPage({Key? key, required this.sessionURL}) : super(key: key);

  @override
  _PortalPageState createState() => _PortalPageState();
}

class _PortalPageState extends State<PortalPage> {
  late WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    // Enable hybrid composition.
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: WebView(
        initialUrl: initialUrl,
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (webViewController) =>
            _webViewController = webViewController,
        onPageFinished: (String url) {
          if (url == initialUrl) {
            _redirectToStripe(widget.sessionURL);
          }
        },
        navigationDelegate: (NavigationRequest request) {
          if (request.url.startsWith('https://m-allahham.github.io/')) {
            Navigator.of(context).pushReplacementNamed('/success');
          } else {
            Navigator.of(context).pushReplacementNamed('/cancel');
          }

          return NavigationDecision.navigate;
        },
      ),
    );
  }

  String get initialUrl => 'https://m-allahham.github.io/manage.html';

  Future<void> _redirectToStripe(String sessionURL) async {
    try {
      await _webViewController
          .loadUrl(sessionURL.substring(1, sessionURL.length - 1));
      //await _webViewController.evaluateJavascript(redirectToCheckoutJs);
    } on PlatformException catch (e) {
      if (!e.details
          .contains('execution returned a result of an unsupported type')) {
        rethrow;
      }
    }
  }
}
