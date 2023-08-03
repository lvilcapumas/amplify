import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/diagnostics.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void _signOut() async {
    if (Amplify.isConfigured) {
      final result = await Amplify.Auth.signOut(
        options: const SignOutOptions(globalSignOut: true),
      );

      safePrint(result);
    }
  }

  void _incrementCounter() async {
    try {
      if (Amplify.isConfigured) {
        final res = await Amplify.Auth.signInWithWebUI(
            options: const SignInWithWebUIOptions(
                pluginOptions: CognitoSignInWithWebUIPluginOptions(
              isPreferPrivateSession: true,
            )),
            provider: AuthProvider.google);
        safePrint(res);

        final authSession = await Amplify.Auth.fetchAuthSession(
          options: const FetchAuthSessionOptions(forceRefresh: true),
        );
        safePrint('User is signed in: ${authSession.isSignedIn}');

        var accessToken = (authSession as CognitoAuthSession)
            .userPoolTokensResult
            .value
            .accessToken
            .toJson();

        safePrint(accessToken);
      }
    } catch (e) {
      safePrint(e);
    }
  }

  initialize() async {
    await Amplify.addPlugins([AmplifyAuthCognito()]);

    final config =
        await rootBundle.loadString('assets/amplifyconfiguration_dev.json');
    await Amplify.configure(config);
  }

  @override
  void initState() {
    super.initState();
    initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '2',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            OutlinedButton(onPressed: _signOut, child: const Text("click"))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) async {
    super.debugFillProperties(properties);
    final config =
        await rootBundle.loadString('assets/amplifyconfiguration_dev.json');
    properties.add(StringProperty('amplifyConfig', config));
  }
}
