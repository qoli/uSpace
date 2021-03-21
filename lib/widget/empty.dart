import 'package:flutter/widgets.dart';
import 'package:uSpace/widget/text_light.dart';

class Empty extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Column(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 50, 0, 8),
              child: SizedBox(
                width: 96,
                height: 96,
                child: Image.asset('assets/empty.png'),
              ),
            ),
          ),
          Text(
            'No Files',
            style: TextStyle(height: 1.5, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8),
          TextLight('Open web and upload your files.'),
        ],
      );
}
