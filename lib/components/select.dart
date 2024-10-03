import 'package:shadcn_flutter/shadcn_flutter.dart';

class LabeledSelect<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<T> items;
  final Function(T?) onChanged;
  final String Function(T item) itemDisplay;
  final bool isMobile;
  final BoxConstraints popupConstraints;

  const LabeledSelect({
    Key? key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.itemDisplay,
    required this.isMobile, // Pass in the isMobile boolean
    this.popupConstraints = const BoxConstraints(maxHeight: 300, maxWidth: 200),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return isMobile
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label).semiBold().small(), // Reusable label
              const SizedBox(height: 8),
              Select<T>(
                itemBuilder: (context, item) {
                  return Text(itemDisplay(item)); // Display the item name
                },
                searchFilter: (item, query) {
                  return itemDisplay(item)
                          .toLowerCase()
                          .contains(query.toLowerCase())
                      ? 1
                      : 0;
                },
                autoClosePopover: true,
                popupConstraints: popupConstraints,
                onChanged: onChanged,
                value: value,
                placeholder: Align(
                  alignment: Alignment.centerLeft, // Align to the start
                  child: Text('Select $label', selectionColor: Colors.gray),
                ),
                children: items
                    .map((item) => SelectItemButton(
                          value: item,
                          child: Text(itemDisplay(item)),
                        ))
                    .toList(),
              ),
            ],
          )
        : Row(
            children: [
              Expanded(
                flex: 2, // You can adjust the flex for better proportions
                child: Text(label).semiBold().small(),
              ),
              const SizedBox(width: 16), // Space between label and select
              Expanded(
                flex: 3, // Adjust flex for the select box
                child: Select<T>(
                  itemBuilder: (context, item) {
                    return Text(itemDisplay(item)); // Display the item name
                  },
                  searchFilter: (item, query) {
                    return itemDisplay(item)
                            .toLowerCase()
                            .contains(query.toLowerCase())
                        ? 1
                        : 0;
                  },
                  popupConstraints: popupConstraints,
                  onChanged: onChanged,
                  value: value,
                  placeholder: Text(
                    'Select $label',
                    selectionColor: Colors.gray,
                  ),
                  children: items
                      .map((item) => SelectItemButton(
                            value: item,
                            child: Text(itemDisplay(item)),
                          ))
                      .toList(),
                ),
              ),
            ],
          );
  }
}
