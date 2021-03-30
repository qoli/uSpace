import 'package:flutter/material.dart';
import 'package:uSpace/class/files.dart';
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
              const Text(
                'About',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
              ),
              const Text(
                'uSpace App',
                style: TextStyle(
                  height: 1.5,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(64, 8, 64, 4),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ButtonTheme(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.black,
                        elevation: 0,
                      ),
                      onPressed: () async {
                        const url = 'http://github.com/qoli/uSpace';
                        if (await canLaunch(url)) await launch(url);
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Github Project',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(64, 4, 64, 8),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ButtonTheme(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.red,
                        elevation: 0,
                      ),
                      onPressed: () => _removeAllFiles(context),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Remove All Files',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const Text('❤️'),
            ],
          ),
        ),
      ),
    );
  }

  void _removeAllFiles(BuildContext context) async {
    await Files().removeAllFiles();
    Navigator.pop(context, 'refresh');
  }
}
