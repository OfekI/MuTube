import 'package:flutter/widgets.dart';
import 'package:mutube/main.dart' as App;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // set config to prod
  App.main(env: 'prod');
}
