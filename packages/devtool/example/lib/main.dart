// ignore_for_file: public_member_api_docs
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:devtool/devtool.dart';
import 'package:state_notifier/state_notifier.dart';

part 'main.freezed.dart';

@freezed
abstract class Company with _$Company {
  factory Company({String name, Director director}) = _Company;
}

@freezed
abstract class Director with _$Director {
  factory Director({
    String name,
    @Default(true) bool awesome,
    Assistant assistant,
  }) = _Director;
}

@freezed
abstract class Assistant with _$Assistant {
  factory Assistant({String name}) = _Assistant;
}

final devtoolController = DevtoolController();

void main() {
  runApp(
    ProviderScope(
      observers: [devtoolController],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Home(),
    );
  }
}

final greetingProvider = Provider(
  (_) => 'Hello world',
  name: 'greetingProvider',
);
final counterProvider = StateNotifierProvider(
  (_) => Counter(),
  name: 'counterProvider',
);
final companyProvider = StateNotifierProvider((_) {
  return CompanyController(
    Company(
      name: 'Google',
      director: Director(
        name: 'Lisa',
        assistant: Assistant(name: 'Anna'),
      ),
    ),
  );
}, name: 'companyProvider');

class CompanyController extends StateNotifier<Company> {
  CompanyController(Company company) : super(company);
}

class Counter extends StateNotifier<int> {
  Counter() : super(0);

  void increment() => state++;
}

class Home extends HookWidget {
  const Home({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final greeting = useProvider(greetingProvider);
    final company = useProvider(companyProvider.state);
    final count = useProvider(counterProvider.state);

    return Row(
      children: [
        Expanded(
          child: Scaffold(
            appBar: AppBar(title: const Text('Example')),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(greeting),
                  Text(count.toString()),
                  Text(
                      '${company.name} (${company.director.name} & ${company.director.assistant.name})'),
                ],
              ),
            ),
            floatingActionButton: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  heroTag: null,
                  onPressed: () => context.read(counterProvider).increment(),
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(
          width: 500,
          child: DevtoolView(),
        )
      ],
    );
  }
}

class DevtoolView extends StatelessWidget {
  const DevtoolView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Devtool')),
      body: Devtool(controller: devtoolController),
    );
  }
}
