import 'package:shadcn_flutter/shadcn_flutter.dart';

Widget buildToast(
    BuildContext context, ToastOverlay overlay, String toastText) {
  return SurfaceCard(
    fillColor: Color(0xFF09090B),
    child: Basic(
      title: Text(toastText),
      trailing: IconButton.ghost(
        size: ButtonSize.small,
        onPressed: () {
          overlay.close();
        },
        icon: const Icon(
          RadixIcons.crossCircled,
        ),
      ),
      trailingAlignment: Alignment.center,
    ),
  );
}
