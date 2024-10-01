import 'package:shadcn_flutter/shadcn_flutter.dart';

void buildDialog(
    BuildContext context, String title, String content, List<Widget> buttons) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text(content)],
        ),
        actions: buttons,
      );
    },
  );
}
