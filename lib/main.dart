// ignore_for_file: library_private_types_in_public_api, prefer_const_constructors, use_super_parameters, use_build_context_synchronously, avoid_print

import 'package:evaluation_app/components/toast.dart';
import 'package:evaluation_app/models/models.dart';
import 'package:evaluation_app/pages/dashboard_page.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ShadcnApp(
      debugShowCheckedModeBanner: false,
      title: 'My App',
      home: MyHomePage(),
      theme: ThemeData(
        colorScheme: ColorSchemes.lightZinc(),
        radius: 0.5,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePagetate createState() => _MyHomePagetate();
}

class _MyHomePagetate extends State<MyHomePage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool obscureText = true;

  void loginUser() async {
    // Check if fields are empty
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      // Show toast if any field is empty
      showToast(
        context: context,
        builder: (context, overlay) => buildToast(
          context,
          overlay,
          "Username and password cannot be empty.",
        ),
        location: ToastLocation.bottomRight,
      );
      return; // Stop the login process if fields are empty
    }

    String url = "http://localhost/evaluation_app_api/auth.php";

    final Map<String, dynamic> jsonData = {
      "username": _usernameController.text,
      "password": _passwordController.text,
    };

    try {
      http.Response response = await http.post(
        Uri.parse(url),
        body: {
          "json": jsonEncode(jsonData),
          "operation": "login",
        },
      );

      if (response.statusCode == 200) {
        var userData = jsonDecode(response.body);
        if (userData.isNotEmpty) {
          User user = User.fromJson(userData[0]);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DashboardPage(
                user: user,
              ),
            ),
          );
          showToast(
            context: context,
            builder: (context, overlay) =>
                buildToast(context, overlay, "Successfully logged in."),
            location: ToastLocation.bottomRight,
          );

          _usernameController.clear();
          _passwordController.clear();
        } else {
          // Show toast when credentials are invalid
          showToast(
            context: context,
            builder: (context, overlay) => buildToast(context, overlay,
                "Incorrect username or password. Please try again."),
            location: ToastLocation.bottomRight,
          );
        }
      } else {
        // If response is not 200, show error toast
        showToast(
          context: context,
          builder: (context, overlay) => buildToast(
              context, overlay, "An error occurred. Please try again."),
          location: ToastLocation.bottomRight,
        );
      }
    } catch (error) {
      // Catch network or other errors and display an error toast
      showToast(
        context: context,
        builder: (context, overlay) =>
            buildToast(context, overlay, "Error: $error"),
        location: ToastLocation.bottomRight,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("EVALUATION APP").x3Large().bold(),
        SizedBox(
          height: 24,
        ),
        Container(
          padding: EdgeInsets.all(12),
          width:
              MediaQuery.of(context).size.width < 600 ? double.infinity : 500,
          child: Card(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1), // The shadow color
                spreadRadius: 1, // Spread of the shadow
                blurRadius: 10, // How blurred the shadow is
                offset: Offset(0, 4), // Offset for the shadow (x, y)
              ),
            ],
            padding: const EdgeInsets.all(24),
            child: MediaQuery.of(context).size.width < 600
                ? mobileScreen()
                : desktopScreen(),
          ).intrinsic(),
        ),
      ],
    ));
  }

  Widget mobileScreen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Login to your account').semiBold(),
        const SizedBox(height: 4),
        const Text('Enter your username and password').muted().xSmall(),
        const SizedBox(height: 24),
        buildFormFields(isMobile: true), // Reuse the buildFormFields function
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            PrimaryButton(
              onPressed: loginUser,
              child: const Text('Login'),
            ),
          ],
        )
      ],
    );
  }

  Widget desktopScreen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Login to your account').semiBold(),
        const SizedBox(height: 4),
        const Text('Enter your username and password').muted().xSmall(),
        const SizedBox(height: 24),
        buildFormFields(isMobile: false), // Reuse the buildFormFields function
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            PrimaryButton(
              onPressed: loginUser,
              child: const Text('Login'),
            ),
          ],
        )
      ],
    );
  }

// Build a common form field function
  Widget buildFormFields({required bool isMobile}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        isMobile
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Username').semiBold().small(),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _usernameController,
                    placeholder: 'Enter username...',
                  ),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 1,
                    child: const Text('Username').semiBold().small(),
                  ),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _usernameController,
                      placeholder: 'Enter username...',
                    ),
                  ),
                ],
              ),
        const SizedBox(height: 16),
        isMobile
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Password').semiBold().small(),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _passwordController,
                    placeholder: 'Enter password...',
                    obscureText: obscureText,
                    trailing: IconButton.ghost(
                      icon: Icon(obscureText
                          ? RadixIcons.eyeClosed
                          : RadixIcons.eyeOpen),
                      onPressed: () {
                        setState(() {
                          obscureText = !obscureText;
                        });
                      },
                    ),
                  ),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 1,
                    child: const Text('Password').semiBold().small(),
                  ),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _passwordController,
                      placeholder: 'Enter password...',
                      obscureText: obscureText,
                      trailing: IconButton.ghost(
                        icon: Icon(obscureText
                            ? RadixIcons.eyeClosed
                            : RadixIcons.eyeOpen),
                        onPressed: () {
                          setState(() {
                            obscureText = !obscureText;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
      ],
    );
  }
}
