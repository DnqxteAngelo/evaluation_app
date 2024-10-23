import 'package:evaluation_app/models/models.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class ActivityTallyList extends StatelessWidget {
  final List<MapEntry<Activity, int>> activities;

  const ActivityTallyList({
    Key? key,
    required this.activities,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: activities.map((entry) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: Container(
            width: 250,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(entry.key.activityName).semiBold().xSmall(),
                Text(entry.value.toString()).xSmall(),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
