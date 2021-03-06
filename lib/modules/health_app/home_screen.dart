import 'package:conditional_builder/conditional_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fristapp/layout/cubit/cubit.dart';
import 'package:fristapp/layout/cubit/states.dart';
import 'package:fristapp/shared/component/component.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GPCubit, GPStates>(
      listener: (context, state) {},
      builder: (context, state) {
        var cubit = GPCubit.get(context);
        // FlutterBlue flutterBlue = FlutterBlue.instance;
        return Scaffold(
          body: Center(child: Text('Hoom Screen')),
        );
      },
    );
  }
}
