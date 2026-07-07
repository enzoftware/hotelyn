import 'package:hotelyn_dashboard/app/app.dart';
import 'package:hotelyn_dashboard/bootstrap.dart';

Future<void> main() async {
  await bootstrap(() => const App());
}
