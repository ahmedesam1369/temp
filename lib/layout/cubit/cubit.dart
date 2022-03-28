import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fristapp/layout/cubit/states.dart';
import 'package:fristapp/model/user_model.dart';
import 'package:fristapp/modules/health_app/home_screen.dart';
import 'package:fristapp/modules/health_app/info_screen.dart';
import 'package:fristapp/modules/health_app/settings_screen.dart';
import 'package:fristapp/shared/component/component.dart';
import 'package:fristapp/shared/component/constants.dart';
import 'package:fristapp/shared/network/local/cache_helper.dart';
import 'package:fristapp/shared/network/remote/dio_helper.dart';
import 'package:fristapp/shared/styles/icon_broken.dart';
import 'package:image_picker/image_picker.dart';
import 'package:health/health.dart';

class GPCubit extends Cubit<GPStates> {
  GPCubit() : super(InitialState());
  static GPCubit get(context) => BlocProvider.of(context);
  int currentIndex = 0;

  List<BottomNavigationBarItem> bottomItems = [
    BottomNavigationBarItem(
        icon: Icon(
          Icons.health_and_safety_outlined,
        ),
        label: 'Home'),
    BottomNavigationBarItem(
      icon: Icon(
        IconBroken.Info_Square,
      ),
      label: 'Info',
    ),
    BottomNavigationBarItem(
      icon: Icon(IconBroken.Setting),
      label: 'Settings',
    ),
  ];

  void changeBottomNavBar(int index) {
    currentIndex = index;
    emit(BottomNavState());
  }

  List<Widget> screens = [
    HomeScreen(),
    Infoscreen(),
    Settingsscreen(),
  ];

  bool IsDark = false;
  void ChangeAppMode({bool? fromShared}) {
    if (fromShared != null) {
      IsDark = fromShared;
    } else
      IsDark = !IsDark;
    CachHelper.saveData(key: 'isDark', value: IsDark).then((value) {
      emit(AppChangeModeState());
    });
  }

  UserModel? usermodel;
  void getUserData() {
    emit(GetUserLoadingState());
    FirebaseFirestore.instance.collection('Users').doc(uId).get().then((value) {
      usermodel = UserModel.fromJson(value.data());
      emit(GetUserSuccessState());
    }).catchError((error) {
      print(error.toString());
      emit(GetUserErrorState(error.toString()));
    });
  }

  void UserDeleteAccount() {
    emit(UserDeleteAccountLoadingState());
    FirebaseAuth.instance.currentUser!.delete().then((value) {
      print('Deleted Successfully');
      emit(UserDeleteAccountSuccessState());
    }).catchError((error) {
      UserDeleteAccountErrorState(error.toString());
      print(error.toString());
    });
  }

// *****************************
// create a HealthFactory for use in the app
  HealthFactory health = HealthFactory();

  List<HealthDataPoint> healthDataList = [];
// AppState _state = AppState.DATA_NOT_FETCHED;
  int? nofsteps;

  HealthDataPoint? lastDateSteps;
  HealthDataPoint? lastDateWeight;
  HealthDataPoint? lastDateHeight;
  HealthDataPoint? lastDateBloodGlucose;
  HealthDataPoint? lastDateHeartRate;
  HealthDataPoint? lastDateEnergyBurned;
  HealthDataPoint? lastDateBloodOxygen;
  HealthDataPoint? lastDateBodyTemperatur;
  HealthDataPoint? lastDateBloodPressureSystolic;
  HealthDataPoint? lastDateBloodPressureDiastolic;

  double _mgdl = 10.0;

  /// Add some random health data.
  Future addData() async {
    final now = DateTime.now();
    final earlier = now.subtract(Duration(minutes: 5));

    nofsteps = Random().nextInt(10);
    final types = [HealthDataType.STEPS, HealthDataType.BLOOD_GLUCOSE];
    final rights = [HealthDataAccess.WRITE, HealthDataAccess.WRITE];
    final permissions = [
      HealthDataAccess.READ_WRITE,
      HealthDataAccess.READ_WRITE
    ];
    bool? hasPermissions =
        await HealthFactory.hasPermissions(types, permissions: rights);
    if (hasPermissions == false) {
      await health.requestAuthorization(types, permissions: permissions);
    }

    _mgdl = Random().nextInt(10) * 1.0;
    bool success = await health.writeHealthData(
        nofsteps!.toDouble(), HealthDataType.STEPS, earlier, now);

    if (success) {
      success = await health.writeHealthData(
          _mgdl, HealthDataType.BLOOD_GLUCOSE, now, now);
    }
    if (success) {
      emit(DataAddedToGoogleFitSuccessState());
    } else {
      emit(DataAddedToGoogleFitErrorState());
    }
  }

  /// Fetch data points from the health plugin and show them in the app.
  Future fetchData() async {
    emit(FetchingDataFromGoogleFitState());

    // setState(() => _state = AppState.FETCHING_DATA);
    // define the types to get
    final types = [
      HealthDataType.STEPS,
      HealthDataType.WEIGHT,
      HealthDataType.HEIGHT,
      HealthDataType.BLOOD_GLUCOSE,
      HealthDataType.HEART_RATE,
      HealthDataType.ACTIVE_ENERGY_BURNED,
      HealthDataType.BLOOD_OXYGEN,
      HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
      HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
      HealthDataType.BODY_TEMPERATURE,

      // HealthDataType.BASAL_ENERGY_BURNED,
      // HealthDataType.BODY_FAT_PERCENTAGE,
      // HealthDataType.BODY_MASS_INDEX,
      // HealthDataType.DIETARY_CARBS_CONSUMED,
      // HealthDataType.DIETARY_ENERGY_CONSUMED,
      // HealthDataType.DIETARY_FATS_CONSUMED,
      // HealthDataType.DIETARY_PROTEIN_CONSUMED,
      // HealthDataType.FORCED_EXPIRATORY_VOLUME,
      // HealthDataType.HEART_RATE_VARIABILITY_SDNN,
      // HealthDataType.RESTING_HEART_RATE,
      // HealthDataType.WAIST_CIRCUMFERENCE,
      // HealthDataType.WALKING_HEART_RATE,
      // HealthDataType.DISTANCE_WALKING_RUNNING,
      // HealthDataType.FLIGHTS_CLIMBED,
      // HealthDataType.MOVE_MINUTES,
      // HealthDataType.DISTANCE_DELTA,
      // HealthDataType.MINDFULNESS,
      // HealthDataType.WATER,
      // SLEEP_IN_BED,
      // HealthDataType.SLEEP_ASLEEP,
      // HealthDataType.SLEEP_AWAKE,
      // HealthDataType.EXERCISE_TIME,
      // HealthDataType.WORKOUT,
      // HealthDataType.HEADACHE_NOT_PRESENT,
      // HealthDataType.HEADACHE_MILD,
      // HealthDataType.HEADACHE_MODERATE,
      // HealthDataType.HEADACHE_SEVERE,
      // HealthDataType.HEADACHE_UNSPECIFIED,
    ];

    // with coresponsing permissions
    final permissions = [
      HealthDataAccess.READ,
      HealthDataAccess.READ,
      HealthDataAccess.READ,
      HealthDataAccess.READ,
      HealthDataAccess.READ,
      HealthDataAccess.READ,
      HealthDataAccess.READ,
      HealthDataAccess.READ,
      HealthDataAccess.READ,
      HealthDataAccess.READ,
    ];

    // get data within the last 24 hours
    final now = DateTime.now();
    final yesterday = now.subtract(Duration(days: 1));

    bool requested =
        await health.requestAuthorization(types, permissions: permissions);

    if (requested) {
      try {
        // fetch health data
        List<HealthDataPoint> healthData =
            // await health.getHealthDataFromTypes(yesterday, now, types);
            await health.getHealthDataFromTypes(yesterday, now, types);

        // save all the new data points (only the first 100)
        healthDataList.addAll((healthData.length < 100)
            ? healthData
            : healthData.sublist(0, 100));
      } catch (error) {
        print("Exception in getHealthDataFromTypes: $error");
      }

      // filter out duplicates
      healthDataList = HealthFactory.removeDuplicates(healthDataList);

      // print the results
      healthDataList.forEach((x) {
        print(x);
        if (x.typeString == 'ACTIVE_ENERGY_BURNED') {
          lastDateEnergyBurned = x;
        }
        if (x.typeString == 'BLOOD_PRESSURE_SYSTOLIC') {
          lastDateBloodPressureSystolic = x;
        }

        if (x.typeString == 'BLOOD_GLUCOSE') {
          lastDateBloodGlucose = x;
        }
        if (x.typeString == 'STEPS') {
          lastDateSteps = x;
        }

        if (x.typeString == 'BLOOD_PRESSURE_DIASTOLIC') {
          lastDateBloodPressureDiastolic = x;
        }
        if (x.typeString == 'BLOOD_OXYGEN') {
          lastDateBloodOxygen = x;
        }

        if (x.typeString == 'BODY_TEMPERATURE') {
          lastDateBodyTemperatur = x;
        }
        if (x.typeString == 'HEART_RATE') {
          lastDateHeartRate = x;
        }

        if (x.typeString == 'HEIGHT') {
          lastDateHeight = x;
        }
        if (x.typeString == 'WEIGHT') {
          lastDateWeight = x;
        }
        // if (x.typeString != 'ACTIVE_ENERGY_BURNED' ||
        //     x.typeString != 'BLOOD_PRESSURE_SYSTOLIC' ||
        //     x.typeString != 'BLOOD_GLUCOSE' ||
        //     x.typeString != 'STEPS' ||
        //     x.typeString != 'BLOOD_PRESSURE_DIASTOLIC' ||
        //     x.typeString != 'BLOOD_OXYGEN' ||
        //     x.typeString != 'BODY_TEMPERATURE' ||
        //     x.typeString != 'HEART_RATE') {
        //   print(x.typeString);
        // }
      });

      if (healthDataList.isEmpty) {
        emit(NoDataFromGoogleFitState());
      } else {
        emit(DataReadyFromGoogleFitState());
      }
    } else {
      print("Authorization not granted");
      emit(DataNotFetchedFromGoogleFitState());
      // setState(() => _state = AppState.DATA_NOT_FETCHED);
    }
  }

  /// Fetch steps from the health plugin and show them in the app.
  Future fetchStepData() async {
    int? steps;

    // get steps for today (i.e., since midnight)
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);

    bool requested = await health.requestAuthorization([HealthDataType.STEPS]);

    if (requested) {
      try {
        steps = await health.getTotalStepsInInterval(midnight, now);
      } catch (error) {
        print("Caught exception in getTotalStepsInInterval: $error");
      }

      print('Total number of steps: $steps');
      emit(FetchingStepsFromGoogleFitState());

      if (steps == null) {
        nofsteps = 0;
        emit(NoStepsFromGoogleFitState());
      } else {
        nofsteps = steps;
        emit(StepsReadyFromGoogleFitState());
      }

      // setState(() {
      //   nofsteps = (steps == null) ? 0 : steps;
      //   _state = (steps == null) ? AppState.NO_DATA : AppState.STEPS_READY;
      // });
    } else {
      print("Authorization not granted");
      emit(StepsNotFetchedFromGoogleFitState());
      // setState(() => _state = AppState.DATA_NOT_FETCHED);
    }
  }

  Widget _contentFetchingData() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(
              strokeWidth: 10,
            )),
        Text('Fetching data...')
      ],
    );
  }

  Widget _contentDataReady() {
    return ListView.builder(
        itemCount: healthDataList.length,
        itemBuilder: (_, index) {
          HealthDataPoint p = healthDataList[index];
          return ListTile(
            title: Text("${p.typeString}: ${p.value}"),
            trailing: Text('${p.unitString}'),
            subtitle: Text('${p.dateFrom} - ${p.dateTo}'),
          );
        });
  }

  Widget _contentNoData() {
    return Text('No Data to show');
  }

  Widget _contentNotFetched() {
    return Column(
      children: [
        Text('Press the download button to fetch data.'),
        Text('Press the plus button to insert some random data.'),
        Text('Press the walking button to get total step count.'),
      ],
      mainAxisAlignment: MainAxisAlignment.center,
    );
  }

  Widget _authorizationNotGranted() {
    return Text('Authorization not given. '
        'For Android please check your OAUTH2 client ID is correct in Google Developer Console. '
        'For iOS check your permissions in Apple Health.');
  }

  Widget _dataAdded() {
    return Text('$nofsteps steps and $_mgdl mgdl are inserted successfully!');
  }

  Widget _stepsFetched() {
    return Text('Total number of steps: $nofsteps');
  }

  Widget _dataNotAdded() {
    return Text('Failed to add data');
  }

  Future<void> refreshandfetch() => Future.delayed(Duration(seconds: 2), () {
        fetchData();
        fetchStepData();
        emit(RefreshAndFetchDataState());
      });
}
