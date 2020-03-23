import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

import 'src/app.dart';
import 'src/secured_hydrated_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  BlocSupervisor.delegate = await SecuredHydratedBlocDelegate.build();
  runApp(Phoenix(
    child: App(),
  ));
}
