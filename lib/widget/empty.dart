import 'package:flutter/widgets.dart';
import 'package:uSpace/widget/text_light.dart';
import 'package:uSpace/generated/l10n.dart';

class Empty extends StatelessWidget {
  const Empty({Key? key}) : super(key: key);

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
            L10n.of(context).noFiles,
            style: const TextStyle(
              height: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextLight(L10n.of(context).uploadFileDes),
        ],
      );
}
