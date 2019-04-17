import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:url_launcher/url_launcher.dart';

class WebViewPage extends StatefulWidget {
  final String url;
  final String title;

  WebViewPage({@required this.url, this.title});

  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool hasLoaded = false;
  final flutterWebViewPlugin = new FlutterWebviewPlugin();

  Future<Null> _onRefresh() async {
    Scaffold.of(context).showSnackBar(new SnackBar(
        content: Text("刷新中"),
        duration: new Duration(seconds: 1),
        backgroundColor: Color.fromARGB(0, 0, 0, 0)));
    await flutterWebViewPlugin.reload();
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void initState() {
    super.initState();
    flutterWebViewPlugin.onStateChanged.listen((state) {
      print(state);
    });
  }

  @override
  void dispose() {
    flutterWebViewPlugin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(widget.title),
          actions: <Widget>[
            IconButton(
              icon: Icon(CupertinoIcons.share_up),
              onPressed: () => _launchURL(widget.url),
            )
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _onRefresh,
          child: WebviewScaffold(
            url: widget.url,
            withZoom: false,
            withLocalStorage: true,
            withJavascript: true,
            supportMultipleWindows: true,
            allowFileURLs: true,
            geolocationEnabled: true,
          ),
        ),
      ),
    );
  }
}

class WebViewExample extends StatefulWidget {
  @override
  _WebViewExampleState createState() => _WebViewExampleState();
}

class _WebViewExampleState extends State<WebViewExample> {
  TextEditingController controller = TextEditingController();
  FlutterWebviewPlugin flutterWebviewPlugin = FlutterWebviewPlugin();
  var urlString = "https://liuvigongzuoshi.github.io/cesium-react/index.html";

  launchUrl() {
    setState(() {
      urlString = controller.text;
      flutterWebviewPlugin.reloadUrl(urlString);
    });
  }

  @override
  void initState() {
    super.initState();

    flutterWebviewPlugin.onStateChanged.listen((WebViewStateChanged wvs) {
      print(wvs.type);
    });
  }

  @override
  Widget build(BuildContext context) {
    return WebviewScaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: false,
          controller: controller,
          textInputAction: TextInputAction.go,
          onSubmitted: (url) => launchUrl(),
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: "Enter Url Here",
            hintStyle: TextStyle(color: Colors.white),
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.navigate_next),
            onPressed: launchUrl,
          )
        ],
      ),
      url: urlString,
      withZoom: false,
    );
  }
}
