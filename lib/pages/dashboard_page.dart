import 'package:evaluation_app/models/models.dart';
import 'package:evaluation_app/pages/profile_page.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class DashboardPage extends StatefulWidget {
  final User user;

  DashboardPage({
    required this.user,
  });

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  void popover() {
    showPopover(
      context: context,
      alignment: Alignment.topRight,
      builder: (context) {
        return SurfaceCard(
          child: SizedBox(
            width: 120,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GhostButton(
                  onPressed: () {},
                  leading: const Icon(BootstrapIcons.personGear).small(),
                  child: const Text('Account Settings').small(),
                ).withPadding(vertical: 4),
                const Divider(),
                GhostButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Logout Account'),
                          content: const Text('Do you really want to logout?'),
                          actions: [
                            OutlineButton(
                              child: const Text('Cancel'),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            DestructiveButton(
                              child: const Text('Logout'),
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  leading:
                      const Icon(BootstrapIcons.arrowBarLeft, color: Colors.red)
                          .small(),
                  child: const Text('Logout',
                      style: TextStyle(
                        color: Colors.red,
                      )).small(),
                ).withPadding(vertical: 4),
              ],
            ),
          ),
        ).withPadding(vertical: 8);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 1000;
    return Scaffold(
      headers: [
        AppBar(
          title: const Text('Dashboard'),
          subtitle: Text(
              'Hello, Mr. ${widget.user.userFullName.split(',').first.trim()}!'),
          trailing: [
            OutlineButton(
              onPressed: () {
                popover();
              },
              density: ButtonDensity.icon,
              child: Avatar(
                initials: Avatar.getInitials(widget.user.userFullName),
                size: 36,
              ),
            ),
          ],
        ),
        const Divider(),
      ],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: 400,
              child: OutlineButton(
                alignment: Alignment.center,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfilePage(
                        user: widget.user,
                      ),
                    ),
                  );
                },
                size: isMobile ? ButtonSize.large : ButtonSize.xLarge,
                leading: const Icon(BootstrapIcons.fileEarmarkSpreadsheet),
                child: const Text('Evaluate'),
              ),
            ),
            Container(
              width: 400,
              child: PrimaryButton(
                alignment: Alignment.center,
                onPressed: () {},
                size: isMobile ? ButtonSize.large : ButtonSize.xLarge,
                leading: const Icon(BootstrapIcons.database),
                child: const Text('Master List'),
              ),
            ),
            Container(
              width: 400,
              child: OutlineButton(
                alignment: Alignment.center,
                onPressed: () {},
                size: isMobile ? ButtonSize.large : ButtonSize.xLarge,
                leading: const Icon(BootstrapIcons.barChartLine),
                child: const Text('Records'),
              ),
            ),
          ],
        ).gap(12),
      ),
    );
  }
}
