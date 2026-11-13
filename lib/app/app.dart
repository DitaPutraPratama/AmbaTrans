import 'package:material_ui/material_ui.dart';

import 'theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      // ponytail: empty placeholder; routes and screens arrive in T-011.
      home: const Scaffold(),
    );
  }
}
