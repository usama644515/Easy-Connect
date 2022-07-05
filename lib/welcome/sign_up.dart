// ignore_for_file: prefer_const_constructors, unnecessary_new

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easyconnect/app_color.dart';
import 'package:easyconnect/loading.dart';
import 'package:easyconnect/welcome/login_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool _isObscure = true;
  bool loading = false;
  late String email, password;
  final _auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  TextEditingController _nameController = TextEditingController();

  void saveData() async {
    Map<String, dynamic> data = {
      'Name': _nameController.text,
      'Email': email,
      'Password': password,
      'uid': FirebaseAuth.instance.currentUser!.uid,
      // 'Home_Address': "chungi No 14 Multan",
      'Photourl':
          "https://www.shareicon.net/data/512x512/2016/05/24/770137_man_512x512.png",
    };
    await firestore
        .collection("Users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set(data)
        .whenComplete(() {
      FirebaseAuth.instance.currentUser!
          .updateDisplayName(_nameController.text);
      FirebaseAuth.instance.currentUser!.updatePhotoURL(
          "https://www.shareicon.net/data/512x512/2016/05/24/770137_man_512x512.png");

      setState(() {
        loading = false;
      });

      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return LoginScreen();
      }));

      //-----show the message------
      Fluttertoast.showToast(
          msg: 'Sucessfully Register.You Can Login Now',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.blue,
          textColor: Colors.white,
          fontSize: 16.0);
    });
  }

  void signup(email, password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      saveData();

      // .then((value) =>);
    } on FirebaseAuthException catch (e) {
      setState(() {
        loading = false;
      });
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
        Fluttertoast.showToast(
            msg: 'The account already exist',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.blue,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    } catch (e) {
      print(e);
    }
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
              // ignore: sized_box_for_whitespace
              Container(
                width: MediaQuery.of(context).size.width,
                child: Image.asset(
                  'assets/images/loginball.png',
                  fit: BoxFit.contain,
                ),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                          fontSize: 32.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                    child: Text(
                      'Full name',
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
                            return "Enter Name";
                          }
                        },
                        controller: _nameController,
                        autofocus: false,
                        style: const TextStyle(
                            fontSize: 15.0, color: Colors.black),
                        decoration: new InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Your Full Name',
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
                  SizedBox(height: 10.0),
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
                  SizedBox(height: 10.0),
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
              SizedBox(height: 20.0),
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
                          signup(email, password);
                          loading = true;
                        });
                      }
                    },
                    child: loading == true
                        ? Loading()
                        : Text(
                            'SIGN UP',
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
                // ignore: prefer_const_literals_to_create_immutables
                children: [
                  Text('Already have an account? ',
                      style: TextStyle(
                        fontSize: 15.0,
                        color: Colors.black,
                      )),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) {
                        return LoginScreen();
                      }));
                    },
                    child: Text(
                      'Login',
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
                        height: 15,
                      )),
                ),
                Text('Sign up with',
                    style: TextStyle(fontSize: 15.0, color: Colors.black)),
                Expanded(
                  child: new Container(
                      margin: const EdgeInsets.only(left: 20.0, right: 20.0),
                      child: Divider(
                        color: Colors.grey,
                        height: 15,
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
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: const Text(
                          'Facebook',
                          style: TextStyle(
                              fontSize: 15.0, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ]),
                  ),
                ),
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
                    child: Row(
                      children: [
                        Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.all(7.0),
                              child: Image.asset('assets/images/google.png'),
                            )),
                        Expanded(
                          flex: 2,
                          child: const Text(
                            'Google',
                            style: TextStyle(
                                fontSize: 15.0, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ]),
            ],
          ),
        ));
  }
}
