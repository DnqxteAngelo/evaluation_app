import 'package:evaluation_app/models/models.dart';

int calculateSumInRange(
    List<MapEntry<Activity, int>> activities, String start, String end) {
  bool inRange = false;
  int sum = 0;

  for (var entry in activities) {
    if (entry.key.activityName == start) {
      inRange = true; // Start summing from this point
    }
    if (inRange) {
      sum += entry.value;
    }
    if (entry.key.activityName == end) {
      break; // Stop summing after reaching the end
    }
  }
  return sum;
}

double calculatePercentage(
    List<MapEntry<Activity, int>> activities, String start, String end) {
  int rangeSum = calculateSumInRange(activities, start, end);
  int totalSum = activities.fold(0, (sum, entry) => sum + entry.value);

  // Avoid division by zero
  return totalSum == 0 ? 0 : (rangeSum / totalSum) * 100;
}
