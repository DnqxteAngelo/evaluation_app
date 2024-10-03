import 'package:shadcn_flutter/shadcn_flutter.dart';

class SummaryField extends StatelessWidget {
  final bool isMobile;
  final String label;
  final String value;

  const SummaryField({
    Key? key,
    required this.isMobile,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return isMobile
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label).semiBold().small(),
              const SizedBox(height: 8),
              TextField(
                readOnly: true,
                controller: TextEditingController(text: value),
              ),
            ],
          )
        : Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(label).semiBold().small(),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 3,
                child: TextField(
                  readOnly: true,
                  controller: TextEditingController(text: value),
                ),
              ),
            ],
          );
  }
}
