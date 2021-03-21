import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'About',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
              ),
              Text(
                'uSpace App',
                style: TextStyle(
                  height: 1.5,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(64, 32, 64, 32),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ButtonTheme(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    child: RaisedButton(
                      color: Colors.black,
                      elevation: 0,
                      onPressed: () async {
                        const url = 'http://github.com/qoli/uSpace';
                        if (await canLaunch(url)) {
                          await launch(url);
                        } else {
                          throw 'Could not launch $url';
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Github Project",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Text('❤️')
            ],
          ),
        ),
      ),
    );
  }
}
