import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

class ActivityTable extends StatelessWidget {
  final List<List<int?>> data;
  final List<String> headers;
  final String title;
  final List<String> timeRanges; // New parameter to accept time ranges

  const ActivityTable({
    Key? key,
    required this.data,
    required this.headers,
    required this.title,
    required this.timeRanges,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        shadcn.Text(
          title,
        ).bold().center(),
        const SizedBox(height: 8),
        Table(
          border: TableBorder.all(),
          columnWidths: const {
            0: FixedColumnWidth(50)
          }, // Set fixed width for time column
          children: [
            // Header Row
            TableRow(
              children: [
                const TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("min", textAlign: TextAlign.center),
                  ),
                ),
                ...headers.map((header) => TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(header, textAlign: TextAlign.center),
                      ),
                    )),
              ],
            ),
            // Data Rows
            for (int i = 0; i < data.length; i++)
              TableRow(
                children: [
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: shadcn.Text(
                        timeRanges[i], // Use timeRanges for the min column
                        textAlign: TextAlign.center,
                      ).xSmall(),
                    ),
                  ),
                  ...data[i].map((cell) => TableCell(
                        child: Container(
                          color: cell != null
                              ? Colors.redAccent
                              : Colors.transparent,
                          alignment: Alignment.center,
                          child: Text(cell?.toString() ?? ""),
                        ),
                      )),
                ],
              ),
          ],
        ),
      ],
    );
  }
}
