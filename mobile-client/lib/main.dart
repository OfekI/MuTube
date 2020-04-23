import 'package:flutter/material.dart';
import 'package:mutube/services/services.dart';
import 'package:mutube/widgets/widgets.dart';

void main({String env}) async {
  WidgetsFlutterBinding.ensureInitialized();
  // load our config
  final config = await ConfigUtils.forEnvironment(env);

  runApp(MuTube(config: config));
}
