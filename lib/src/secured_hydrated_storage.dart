import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

class SecuredHydratedBlocDelegate extends HydratedBlocDelegate {
  SecuredHydratedBlocDelegate._(SecuredHydratedBlocStorage storage)
      : super(storage);

  static Future<SecuredHydratedBlocDelegate> build() async {
    return SecuredHydratedBlocDelegate._(
        await SecuredHydratedBlocStorage.getInstance());
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    final state = transition.nextState;
    if (bloc is HydratedBloc) {
      final stateJson = bloc.toJson(state);
      if (stateJson != null) {
        storage.write(
          '${bloc.runtimeType.toString()}${bloc.id}',
          json.encode(stateJson),
        );
      }
    }
  }
}

class SecuredHydratedBlocStorage implements HydratedStorage {
  static SecuredHydratedBlocStorage _instance;
  final Map<String, dynamic> _storage;
  final File _file;

  /// Returns an instance of `HydratedBlocStorage`.
  /// `storageDirectory` can optionally be provided.
  /// By default, `getTemporaryDirectory` is used.
  static Future<SecuredHydratedBlocStorage> getInstance({
    Directory storageDirectory,
  }) async {
    print('GETTING INSTANCE');
    if (_instance != null) {
      return _instance;
    }

    final directory =
        storageDirectory ?? await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/.hydrated_bloc.json');
    var storage = <String, dynamic>{};

    if (await file.exists()) {
      try {
        storage =
            json.decode(await file.readAsString()) as Map<String, dynamic>;
      } on dynamic catch (_) {
        await file.delete();
      }
    }

    _instance = SecuredHydratedBlocStorage._(storage, file);
    return _instance;
  }

  SecuredHydratedBlocStorage._(this._storage, this._file);

  @override
  dynamic read(String key) {
    debugPrintStack(label: 'READING $key', maxFrames: 10);
    return _storage[key];
  }

  @override
  Future<void> write(String key, dynamic value) async {
    print('WRITING $key $value');
    _storage[key] = value;
    await _file.writeAsString(json.encode(_storage));
    return _storage[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    print('DELETING $key');
    _storage[key] = null;
    return await _file.writeAsString(json.encode(_storage));
  }

  @override
  Future<void> clear() async {
    print('CLEARING DB');
    _storage.clear();
    _instance = null;
    return await _file.exists() ? await _file.delete() : null;
  }
}
