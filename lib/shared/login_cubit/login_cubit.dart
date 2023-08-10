import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/user_model.dart';
import '../../modules/newscreen2.dart';
import 'login_states.dart';

class LoginCubit extends Cubit<LoginStates> {
  LoginCubit(this.context) : super(LoginInitialState());

  final BuildContext context;

  static LoginCubit get(context) => BlocProvider.of(context);

  var FullNameController = TextEditingController();
  var PhoneController = TextEditingController();
  var gender = "Male";

  bool hidden = true;
  bool hidden2 = true;

  void changeGender(String g) {
    gender = g;
    emit(ChangeGenderState());
  }

  void changePassHidden() {
    hidden = !hidden;
    emit(ChangeButtonIconState());
  }

  void changePassHidden2() {
    hidden2 = !hidden2;
    emit(ChangeButtonIconState());
  }

  Future<void> registerAccount(
      TextEditingController nameController,
      TextEditingController emailController,
      TextEditingController passController,
      TextEditingController phoneController,
      String genderController) async {
    emit(SignUpLoadingState());
    await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
            email: emailController.text, password: passController.text)
        .then((value) {
      print(
          "User with email: ${value.user!.email} and id: ${value.user!.uid} Added Successfully");
      createAccount(
          uId: value.user!.uid,
          name: nameController.text,
          email: emailController.text,
          phone: phoneController.text,
          gender: genderController);
      emit(SignUpSuccessfullyState());
    }).catchError((error) {
      print(error);
    });
  }

  Future<void> createAccount(
      {required String uId,
      required String name,
      required String email,
      required String phone,
      required String gender}) async {
    UserModel userModel = UserModel(
        uId: uId, name: name, email: email, phone: phone, gender: gender);

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uId)
        .set(userModel.toMap())
        .then((value) {
      print("User Added");
      emit(SignUpDataSuccessfullyState());
    }).catchError((error) {
      print("error: $error");
    });
  }

  void loginAccount(TextEditingController emailController,
      TextEditingController passController) {
    emit(LoginLoadingState());
    FirebaseAuth.instance
        .signInWithEmailAndPassword(
            email: emailController.text, password: passController.text)
        .then((value) {
      print("user with ${value.user!.email} Signin Successfully Success");
      emit(LoginSuccessfullyState());
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => NewScreen()));
      emit(HomePageState());
    }).catchError((error) {
      print(error);
    });
  }
}
