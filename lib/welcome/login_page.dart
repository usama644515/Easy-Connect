// ignore_for_file: prefer_const_constructors, unnecessary_new

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easyconnect/app_color.dart';
import 'package:easyconnect/home/chat_page.dart';
import 'package:easyconnect/home_screen.dart';
import 'package:easyconnect/loading.dart';
import 'package:easyconnect/welcome/sign_up.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import 'dart:async';

import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  //-----check internet connection----

  late StreamSubscription internetconnection;
  bool isoffline = false;
  bool loading = false;

  @override
  void initState() {
    // internetconnection = Connectivity()
    //     .onConnectivityChanged
    //     .listen((ConnectivityResult result) {
    //   // whenevery connection status is changed.
    //   if (result == ConnectivityResult.none) {
    //     //there is no any connection
    //     setState(() {
    //       isoffline = true;
    //     });
    //   } else if (result == ConnectivityResult.mobile) {
    //     //connection is mobile data network
    //     setState(() {
    //       isoffline = false;
    //     });
    //   } else if (result == ConnectivityResult.wifi) {
    //     //connection is from wifi
    //     setState(() {
    //       isoffline = false;
    //     });
    //   }
    // }); // using this listiner, you can get the medium of connection as well.

    super.initState();
  }

  @override
  dispose() {
    super.dispose();
    internetconnection.cancel();
    //cancel internent connection subscription after you are done
  }

  //-----check internet connection----

  bool _isObscure = true;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  late String email, password;
  void saveData() async {
    Map<String, dynamic> data = {
      'Name': auth.currentUser?.displayName ?? "Guest",
      'Email': auth.currentUser?.email ?? "Email",
      'Phone No': null,
      'uid': FirebaseAuth.instance.currentUser!.uid,
      'Photourl': auth.currentUser?.photoURL,
      'date': DateTime.now(),
    };
    await firestore
        .collection("Users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set(data, SetOptions(merge: true))
        .whenComplete(() {});
  }

  showLoaderDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: new Row(
        children: [
          CircularProgressIndicator(),
          Container(
              margin: EdgeInsets.only(left: 15), child: Text("Loading...")),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  // function to implement the google signin

// creating firebase instance
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<void> signInGoogle(BuildContext context) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();
    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;
      final AuthCredential authCredential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken);

      // Getting users credential
      UserCredential result = await auth.signInWithCredential(authCredential);
      User? user = result.user;

      if (result != null) {
        saveData();
        await Get.offAll(() => const ChatPage());
        Fluttertoast.showToast(
            msg: "Successfully Login",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.blue,
            textColor: Colors.white,
            fontSize: 16.0);
      } // if result not null we simply call the MaterialpageRoute,
      // for go to the HomePage screen
      else {
        Fluttertoast.showToast(
            msg: "Error Occured",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.blue,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    }
  }

  void login(email, password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      //---show message----
      Fluttertoast.showToast(
          msg: 'Successfully Login',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.blue,
          textColor: Colors.white,
          fontSize: 16.0);

      setState(() {
        loading = false;
      });
      //-----go to next screen-----
      await Get.offAll(() => const ChatPage());
    } on FirebaseAuthException catch (e) {
      setState(() {
        loading = false;
      });
      if (e.code == 'user-not-found') {
        Fluttertoast.showToast(
            msg: "No User Found",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.blue,
            textColor: Colors.white,
            fontSize: 16.0);
        print(e.code);
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        Fluttertoast.showToast(
            msg: "Wrong Password",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.blue,
            textColor: Colors.white,
            fontSize: 16.0);
        print('Wrong password provided for that user.');
      } else {
        Fluttertoast.showToast(
            msg: "Error occurred while logging in",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.blue,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    }
  }

  final formGlobalKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[200],
        resizeToAvoidBottomInset: false,
        body: Form(
          key: formGlobalKey,
          child: ListView(
            children: [
              Stack(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: Image.asset(
                      'assets/images/loginball.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  // Container(
                  //   child:
                  //       errmsg("No Internet Connection Available", isoffline),
                  //   //to show internet connection message on isoffline = true.
                  // ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      'Login',
                      style: TextStyle(
                          fontSize: 32.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 15.0),
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                    child: Text(
                      'E-mail',
                      style: TextStyle(
                        fontSize: 15.0,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    // ignore: avoid_unnecessary_containers
                    child: Container(
                      child: TextFormField(
                        validator: (value) {
                          if (value == "") {
                            return "Enter Email";
                          }
                        },
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (value) {
                          email = value; //get the value entered by user.
                        },
                        controller: null,
                        autofocus: false,
                        style: const TextStyle(
                            fontSize: 15.0, color: Colors.black),
                        decoration: new InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Your email or phone',
                          contentPadding: const EdgeInsets.only(
                              left: 14.0, bottom: 15.0, top: 15.0),
                          focusedBorder: OutlineInputBorder(
                            borderSide: new BorderSide(color: Colors.white),
                            borderRadius: new BorderRadius.circular(10.7),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: new BorderSide(color: Colors.white),
                            borderRadius: new BorderRadius.circular(10.7),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 15.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 5.0),
                    child: Text(
                      'Password',
                      style: TextStyle(fontSize: 15.0, color: Colors.black),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: TextFormField(
                      onChanged: (value) {
                        password = value; //get the value entered by user.
                      },
                      validator: (value) {
                        if (value == "") {
                          return "Enter Password";
                        }
                        if (value!.length < 7) {
                          return 'Password must be more than 6 character';
                        }
                      },
                      obscureText: _isObscure,
                      controller: null,
                      autofocus: false,
                      style: new TextStyle(fontSize: 15.0, color: Colors.black),
                      decoration: new InputDecoration(
                        //-----hide or show text icon------
                        suffixIcon: IconButton(
                            color: Colors.grey[400],
                            icon: Icon(_isObscure
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () {
                              setState(() {
                                _isObscure = !_isObscure;
                              });
                            }),
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Password',
                        contentPadding: const EdgeInsets.only(
                            left: 14.0, bottom: 15.0, top: 15.0),
                        focusedBorder: OutlineInputBorder(
                          borderSide: new BorderSide(color: Colors.white),
                          borderRadius: new BorderRadius.circular(10.7),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: new BorderSide(color: Colors.white),
                          borderRadius: new BorderRadius.circular(10.7),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10.0,
              ),
              Center(
                child: Text(
                  'Forget Password',
                  style: TextStyle(fontSize: 15.0, color: AppColor.primary),
                ),
              ),
              SizedBox(height: 15.0),
              Padding(
                padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width / 5,
                  right: MediaQuery.of(context).size.width / 5,
                  bottom: 5.0,
                  top: 5.0,
                ),
                child: Container(
                  height: 55.0,
                  width: MediaQuery.of(context).size.width,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(AppColor.primary),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                      ),
                    ),
                    onPressed: () {
                      if (formGlobalKey.currentState!.validate()) {
                        // use the information provided

                        setState(() {
                          loading = true;
                          login(email, password);
                        });
                      }
                    },
                    child: loading == true
                        ? Loading()
                        : Text(
                            'LOGIN',
                            style: TextStyle(
                              fontSize: 15.0,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Dont have an account? ',
                      style: TextStyle(
                        fontSize: 15.0,
                        color: Colors.black,
                      )),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return const SignupScreen();
                          },
                        ),
                      );
                    },
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 15.0,
                        color: AppColor.primary,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20.0,
              ),
              Row(children: <Widget>[
                Expanded(
                  child: new Container(
                      margin: const EdgeInsets.only(left: 20.0, right: 20.0),
                      child: Divider(
                        color: Colors.grey,
                        height: 30,
                      )),
                ),
                Text('Sign in with',
                    style: TextStyle(fontSize: 15.0, color: Colors.black)),
                Expanded(
                  child: new Container(
                      margin: const EdgeInsets.only(left: 20.0, right: 20.0),
                      child: Divider(
                        color: Colors.grey,
                        height: 30,
                      )),
                ),
              ]),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                      width: 130.0,
                      height: 50.0,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25.0),
                        border: Border.all(
                          color: Colors.white,
                          width: 2.0,
                        ),
                      ),
                      child: Row(children: [
                        Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.all(7.0),
                              child: Image.asset('assets/images/facebook.png'),
                            )),
                        Expanded(
                          flex: 2,
                          child: const Text(
                            'Facebook',
                            style: TextStyle(
                                fontSize: 15.0, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ])),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: GestureDetector(
                    onTap: () {
                      signInGoogle(context);
                    },
                    child: Container(
                        width: 130.0,
                        height: 50.0,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25.0),
                          border: Border.all(
                            color: Colors.white,
                            width: 2.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                                flex: 1,
                                child: Padding(
                                  padding: const EdgeInsets.all(7.0),
                                  child:
                                      Image.asset('assets/images/google.png'),
                                )),
                            Expanded(
                              flex: 2,
                              child: const Text(
                                'Google',
                                style: TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        )),
                  ),
                ),
              ]),
            ],
          ),
        ));
  }
}

//----create error message----

Widget errmsg(String text, bool show) {
  //error message widget.
  if (show == true) {
    //if error is true then show error message box
    return Container(
      padding: EdgeInsets.all(10.00),
      margin: EdgeInsets.only(bottom: 10.00),
      color: Colors.red,
      child: Row(children: [
        Container(
          margin: EdgeInsets.only(right: 6.00),
          child: Icon(Icons.info, color: Colors.white),
        ), // icon for error message

        Text(text, style: TextStyle(color: Colors.white)),
        //show error message text
      ]),
    );
  } else {
    return Container();
    //if error is false, return empty container.
  }
}
