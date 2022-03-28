import 'dart:io';
import 'package:conditional_builder/conditional_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fristapp/layout/cubit/cubit.dart';
import 'package:fristapp/layout/cubit/states.dart';
import 'package:fristapp/modules/vitals/energy_burned.dart';
import 'package:fristapp/modules/vitals/heart_rate.dart';
import 'package:fristapp/modules/vitals/spo2.dart';
import 'package:fristapp/modules/vitals/total_steps.dart';
import 'package:fristapp/shared/component/component.dart';
import 'package:fristapp/shared/styles/MyIcon.dart.dart';
import 'package:fristapp/shared/styles/icon_broken.dart';
import 'package:health/health.dart';

class Infoscreen extends StatelessWidget {
  bool showData = false;
  bool showSteps = false;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GPCubit, GPStates>(
      listener: (context, state) {
        var cubit = GPCubit.get(context);
        if (state is StepsReadyFromGoogleFitState) showSteps = true;
        if (state is DataReadyFromGoogleFitState) showData = true;
      },
      builder: (context, state) {
        var cubit = GPCubit.get(context);
        return Scaffold(
          // appBar: AppBar(
          //   actions: [
          //     IconButton(
          //         onPressed: () {
          //           print(cubit.nofsteps);

          //           print(cubit.lastDateWeight!.typeString);
          //           print(cubit.lastDateWeight!.value);
          //           print(cubit.lastDateWeight!.unitString);
          //           print(cubit.lastDateWeight!.dateFrom);
          //           print(cubit.lastDateWeight!.dateTo);
          //         },
          //         icon: Icon(IconBroken.Arrow___Down)),
          //   ],
          // ),
          body: Material(
            // color: Theme.of(context).backgroundColor,
            color: cubit.IsDark ? Colors.grey[800] : Colors.white,
            child: RefreshIndicator(
              onRefresh: cubit.refreshandfetch,
              child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    const SizedBox(height: 10),
                    GridView.count(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 4 / 5,
                      children: [
                        GestureDetector(
                          onTap: () {
                            NavigetTo(context, HeartRate());

                            print('${cubit.lastDateSteps!.value}');
                            print('${cubit.lastDateSteps!.dateFrom}');
                          },
                          child: InfoCard(
                            title: 'Heart Rate',
                            content: 'Beats per minute',
                            icon: IconBroken.Heart,
                            isPrimaryColor: false,
                            context: context,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            NavigetTo(context, EnergyBurned());
                          },
                          child: InfoCard(
                            title: 'Energy Burned',
                            content: 'Calories',
                            icon: IconBroken.Scan,
                            isPrimaryColor: false,
                            context: context,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            NavigetTo(context, TotalSteps());
                          },
                          child: InfoCard(
                            title: 'Steps',
                            content: 'Count',
                            icon: MyIcon.walking,
                            isPrimaryColor: false,
                            context: context,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            print('*************************');
                            print('Blood Pressure');
                            print(cubit.lastDateBloodPressureSystolic!.value);
                            print(cubit.lastDateBloodPressureDiastolic!.value);
                            print('*************************');
                            // NavigetTo(context, BloodOxygen());
                          },
                          child: InfoCard(
                            title: 'Blood Pressure',
                            content: 'mmHg',
                            icon: IconBroken.User,
                            isPrimaryColor: false,
                            context: context,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            print('*************************');
                            print('Body Temperatur');
                            print(cubit.lastDateBodyTemperatur!.value);
                            print('*************************');
                            // NavigetTo(context, BloodOxygen());

                            // NavigetTo(context, BloodOxygen());
                          },
                          child: InfoCard(
                            title: 'Body Temperature',
                            content: '°C',
                            icon: MyIcon.temperatire,
                            isPrimaryColor: false,
                            context: context,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // print('*************************');
                            // print('Height');
                            // print(cubit.lastDateHeight!.value);
                            // print('*************************');
                            // NavigetTo(context, BloodOxygen());
                          },
                          child: InfoCard(
                            title: 'Height',
                            content: 'Meters',
                            icon: IconBroken.Filter,
                            isPrimaryColor: false,
                            context: context,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // NavigetTo(context, BloodOxygen());
                          },
                          child: InfoCard(
                            title: 'Weight',
                            content: 'Kg',
                            icon: MyIcon.weight,
                            isPrimaryColor: false,
                            context: context,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // NavigetTo(context, BloodOxygen());
                          },
                          child: InfoCard(
                            title: 'SpO2',
                            content: 'Percentage',
                            icon: MyIcon.pan_tool,
                            isPrimaryColor: false,
                            context: context,
                          ),
                        ),
                      ],
                    ),
                  ]),
            ),
          ),
        );
      },
    );
  }
}
