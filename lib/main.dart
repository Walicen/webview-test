import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'web_view_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WebView Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'WebView Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // ! PUT YOUR URL HERE
  final String url = '';

  final ChromeSafariBrowser browser = MyChromeSafariBrowser();

  @override
  void initState() {
    super.initState();
    browser.addMenuItem(ChromeSafariBrowserMenuItem(
      id: 1,
      label: 'Custom item menu 1',
      action: (url, title) {
        debugPrint('Custom item menu 1 clicked!');
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton.icon(
              onPressed: _onPressedWebView,
              icon: const Icon(Icons.web),
              label: const Text('Open WebView'),
            ),
            ElevatedButton.icon(
              onPressed: _onPressedUrlLauncher,
              icon: const Icon(Icons.public),
              label: const Text('Open Url Launcher'),
            ),
            ElevatedButton.icon(
              onPressed: () => _launchURL(context),
              icon: const Icon(Icons.public),
              label: const Text('Open Url Tabs'),
            ),
            ElevatedButton.icon(
              onPressed: () => _openInAppWebView(context),
              icon: const Icon(Icons.public),
              label: const Text('Open InAppWebView'),
            ),
          ],
        ),
      ),
    );
  }

  void _onPressedWebView() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MyWebViewPage(url: url),
      ),
    );
  }

  void _onPressedUrlLauncher() async {
    try {
      if (await canLaunchUrlString(url)) {
        final result = await launchUrlString(url, mode: LaunchMode.platformDefault);
        log("Result: $result");
      } else {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      log("Erro ao abrir URL $e");
    }
  }

  void _launchURL(BuildContext context) async {
    try {
      await launch(
        url,
        customTabsOption: CustomTabsOption(
          toolbarColor: Theme.of(context).primaryColor,
          enableDefaultShare: true,
          enableUrlBarHiding: true,
          showPageTitle: true,
        ),
        safariVCOption: SafariViewControllerOption(
          preferredBarTintColor: Theme.of(context).primaryColor,
          preferredControlTintColor: Colors.white,
          barCollapsingEnabled: true,
          entersReaderIfAvailable: false,
          dismissButtonStyle: SafariViewControllerDismissButtonStyle.close,
        ),
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  _openInAppWebView(BuildContext context) async {
    try {
      await browser.open(
        url: Uri.parse(url),
        options: ChromeSafariBrowserClassOptions(
            android:
                AndroidChromeCustomTabsOptions(shareState: CustomTabsShareState.SHARE_STATE_OFF),
            ios: IOSSafariOptions(
              barCollapsingEnabled: true,
              dismissButtonStyle: IOSSafariDismissButtonStyle.CLOSE,
              preferredBarTintColor: Theme.of(context).primaryColor,
            )),
      );
      Future.delayed(const Duration(seconds: 10), () {
        browser.close();
      });
    } catch (e) {
      log("Erro ao abrir URL $e");
    }
  }
}

class MyChromeSafariBrowser extends ChromeSafariBrowser {
  @override
  void onOpened() {
    debugPrint("ChromeSafari browser opened");
  }

  @override
  void onCompletedInitialLoad() {
    debugPrint("ChromeSafari browser initial load completed");
  }

  @override
  void onClosed() {
    debugPrint("ChromeSafari browser closed");
  }
}
