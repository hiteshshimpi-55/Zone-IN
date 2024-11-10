import 'dart:developer';
import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/material.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Instagram Reel Receiver',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ReelReceiverPage(),
    );
  }
}

class ReelReceiverPage extends StatefulWidget {
  @override
  _ReelReceiverPageState createState() => _ReelReceiverPageState();
}

class _ReelReceiverPageState extends State<ReelReceiverPage> {
  String? _sharedReelLink;

  @override
  void initState() {
    super.initState();

    // Listen for incoming shared media (URLs in this case)
    ReceiveSharingIntent.instance.getMediaStream().listen(
        (List<SharedMediaFile> media) {
      for (var item in media) {
        log("Map: ${item.toMap()}");
        log("Path:${item.path}");
        log("Thumbnail : ${item.thumbnail}"); // Thumbnail is usually empty
        log("Platform:${item.type}");
      }
      if (media.isNotEmpty && media[0].path.isNotEmpty) {
        setState(() {
          _sharedReelLink = media[0].path;
        });
      }
    }, onError: (err) {
      print("Error in receiving share intent: $err");
    });

    // For initial shared media (for when the app is opened via a shared intent)
    ReceiveSharingIntent.instance
        .getInitialMedia()
        .then((List<SharedMediaFile> media) {
      for (var item in media) {
        log("Map: ${item.toMap()}");
        log("Path:${item.path}");
        log("Thumbnail : ${item.thumbnail}");
        log("Platform:${item.type}");
      }
      if (media.isNotEmpty && media[0].path.isNotEmpty) {
        setState(() {
          _sharedReelLink = media[0].path;
        });
      }
    });
  }

  Future<void> _launchInBrowser(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Instagram Reel Receiver"),
      ),
      body: Center(
        child: _sharedReelLink == null
            ? Text("No reel link shared yet!")
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Shared Reel Link Preview:",
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 10),
                  // Link Preview Widget - Fetches thumbnail, title, description
                  AnyLinkPreview(
                    link:
                        "https://youtube.com/watch?v=Z17KJNPmSRk&si=_5_D2Npd8Zxw1QI3",
                    displayDirection: UIDirection.uiDirectionHorizontal,
                    cache: Duration(hours: 1),
                    backgroundColor: Colors.grey[300],
                    errorWidget: Container(
                      color: Colors.grey[300],
                      child: Text('Oops!'),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      _launchInBrowser(_sharedReelLink ?? "");
                    },
                    child: Text("Open Reel"),
                  ),
                ],
              ),
      ),
    );
  }
}
