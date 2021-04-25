import 'package:flutter/material.dart';
import 'package:uSpace/class/files.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uSpace/generated/l10n.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

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
                L10n.of(context).about,
                style: const TextStyle(
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
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          L10n.of(context).githubProject,
                          style: const TextStyle(
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
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          L10n.of(context).removeAllFiles,
                          style: const TextStyle(
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
