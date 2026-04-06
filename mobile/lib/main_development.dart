import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:shop/config/dependencies.dart';

import 'main.dart';

void main() {
  Logger.root.level = Level.ALL;

  runApp(MultiProvider(providers: providersRemote, child: const MainApp()));
}