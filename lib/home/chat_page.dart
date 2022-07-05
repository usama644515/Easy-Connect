import 'package:easyconnect/home/all_users.dart';
import 'package:easyconnect/home/chat_screen.dart';
import 'package:easyconnect/welcome/login_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with WidgetsBindingObserver {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final groupchat = TextEditingController();
  final formkey = GlobalKey<FormState>();
  getChatRoomId(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  String _datetimeFormatter(String _timestamp) {
    String formattedDate =
        DateFormat('hh:mm/dd-MM').format(DateTime.parse(_timestamp));
    return formattedDate;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    if (_auth.currentUser?.uid != null) {
      setStatus(true);
    }
  }

  void setStatus(bool status) async {
    await firestore.collection('Users').doc(_auth.currentUser?.uid).set({
      "Online": status,
    }, SetOptions(merge: true));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_auth.currentUser?.uid != null) {
      if (state == AppLifecycleState.resumed) {
        print('online');
        // online
        setStatus(true);
      } else {
        print('offline');
        // offline
        setStatus(false);
      }
    }
  }

  var myMenuItems = <String>[
    'Home',
    'Profile',
    'Setting',
  ];

  void SelectedItem(BuildContext context, item) {
    switch (item) {
      case 0:
        // Navigator.of(context)
        //     .push(MaterialPageRoute(builder: (context) => SettingPage()));
        break;
      case 1:
        print("Privacy Clicked");
        break;
      case 2:
        print("User Logged out");
        _logoutDialoge(context);

        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        iconTheme: const IconThemeData(),
        title: Text("Message Box",
            style: TextStyle(
              color: Theme.of(context).hintColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            )),
        actions: [
          Theme(
            data: Theme.of(context).copyWith(
                textTheme: const TextTheme()
                    .apply(bodyColor: Theme.of(context).hintColor),
                dividerColor: Theme.of(context).hintColor,
                iconTheme: IconThemeData(color: Theme.of(context).hintColor)),
            child: PopupMenuButton<int>(
              color: Theme.of(context).backgroundColor,
              itemBuilder: (context) => [
                PopupMenuItem<int>(
                    value: 0,
                    child: Text("Setting",
                        style: TextStyle(color: Theme.of(context).hintColor))),
                PopupMenuItem<int>(
                    value: 1,
                    child: Text("Privacy Policy page",
                        style: TextStyle(color: Theme.of(context).hintColor))),
                const PopupMenuDivider(),
                PopupMenuItem<int>(
                    value: 2,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.logout,
                          color: Colors.red,
                        ),
                        const SizedBox(
                          width: 7,
                        ),
                        Text("Logout",
                            style:
                                TextStyle(color: Theme.of(context).hintColor))
                      ],
                    )),
              ],
              onSelected: (item) => SelectedItem(context, item),
            ),
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          ListView(
            physics: const NeverScrollableScrollPhysics(),
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('chatRoom')
                      // .where("chatId", arrayContains: "${_auth.currentUser!.uid}")
                      .orderBy('time', descending: true)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    return snapshot.data?.size == 0
                        ? const Center(
                            child: Text(
                              "Create ChatRoom to Start Chat",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 18,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: snapshot.data!.docs.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              DocumentSnapshot data =
                                  snapshot.data!.docs[index];

                              return FutureBuilder(
                                builder: (_, AsyncSnapshot snapshot) {
                                  var msgCount;
                                  bool msgCheck;
                                  try {
                                    msgCount = data.get('${_auth.currentUser?.uid}_unreadMsg');
                                    msgCheck = true;
                                  } on StateError catch (e) {
                                    msgCheck = false;
                                    // print('1');
                                  }
                                  return snapshot.data == null
                                      ? const SizedBox(
                                          width: 45,
                                          height: 45,
                                          child: Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        )
                                      : ListTile(
                                          dense: true,
                                          onLongPress: () {
                                            _showDeleteDialoge(
                                                context, data.id);
                                          },
                                          onTap: () {
                                            String chatRoomId = getChatRoomId(
                                                _auth.currentUser!.uid,
                                                data.get(
                                                    "${_auth.currentUser?.uid}"));
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        ChatScreen(
                                                          username: snapshot
                                                              .data
                                                              .get('Name'),
                                                          userimage: snapshot
                                                              .data
                                                              .get('Photourl'),
                                                          docId: chatRoomId,
                                                          idTo: snapshot.data
                                                              .get("uid"),
                                                        )));
                                          },
                                          leading: CachedNetworkImage(
                                            imageUrl:
                                                snapshot.data.get('Photourl'),
                                            imageBuilder:
                                                (context, imageProvider) =>
                                                    Container(
                                              width: 50,
                                              height: 50,
                                              decoration: BoxDecoration(
                                                // borderRadius: BorderRadius.circular(50),
                                                shape: BoxShape.circle,
                                                image: DecorationImage(
                                                  image: imageProvider,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            placeholder: (context, url) =>
                                                const CircularProgressIndicator(),
                                            errorWidget:
                                                (context, url, error) =>
                                                    const Icon(Icons.error),
                                          ),
                                          title: Row(
                                            children: [
                                              Text(
                                                snapshot.data.get('Name'),
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 17),
                                              ),
                                            ],
                                          ),
                                          subtitle: StreamBuilder(
                                              stream: firestore
                                                  .collection("chatRoom")
                                                  .doc(data.id)
                                                  .collection("chat")
                                                  .orderBy('time',
                                                      descending: true)
                                                  .limit(1)
                                                  .snapshots(),
                                              builder: (BuildContext context,
                                                  AsyncSnapshot<QuerySnapshot>
                                                      snapshot) {
                                                if (!snapshot.hasData) {
                                                  return Container();
                                                }
                                                DocumentSnapshot document =
                                                    snapshot.data?.docs[0]
                                                        as DocumentSnapshot<
                                                            Object?>;
                                                return SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.6,
                                                  child: Text(
                                                    document['details'],
                                                    style: const TextStyle(
                                                        fontSize: 15.0,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                );
                                              }),
                                          trailing: msgCheck == true
                                              ? msgCount > 0
                                                  ? Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      children: [
                                                        Container(
                                                          decoration:
                                                              const BoxDecoration(
                                                            color: Colors.blue,
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Text(
                                                              msgCount
                                                                  .toString(),
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontSize: 14),
                                                            ),
                                                          ),
                                                        ),
                                                        Text(_datetimeFormatter(
                                                            data
                                                                .get('time')
                                                                .toDate()
                                                                .toString())),
                                                      ],
                                                    )
                                                  : Text(_datetimeFormatter(data
                                                      .get('time')
                                                      .toDate()
                                                      .toString()))
                                              : Text(_datetimeFormatter(data
                                                  .get('time')
                                                  .toDate()
                                                  .toString())),
                                        );
                                },
                                future: getuserdata(
                                    data.get("${_auth.currentUser?.uid}")),
                              );
                            });
                  },
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 15,
            right: 15,
            child: GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AllUsers()));
              },
              child: PhysicalModel(
                shape: BoxShape.circle,
                color: Colors.blue,
                elevation: 6,
                shadowColor: Theme.of(context).backgroundColor,
                child: Container(
                  height: 60,
                  width: 60,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue,
                  ),
                  child: const Icon(Icons.message, color: Colors.white),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Future getuserdata(String id) async {
    var article = await firestore.collection("Users").doc(id).get();
    return article;
  }

  var lastmsg = [];
  Future getlastMsg(var id) async {
    Map<String, dynamic> collection;
    QuerySnapshot<Map<String, dynamic>> data = await firestore
        .collection("chatRoom")
        .doc(id)
        .collection("chat")
        .orderBy('time', descending: true)
        .limit(1)
        .get();

    collection = data.docs.first.data();
    lastmsg.add(collection['details']);
    print(lastmsg);
    // var msg;
  }

  _showDeleteDialoge(context, String id) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return CupertinoAlertDialog(
            title: const Text('ChatRoom Delete'),
            content: const Text('Are you sure to Delete ChatRoom?'),
            actions: [
              CupertinoDialogAction(
                child: const Text('Yes'),
                onPressed: () {
                  setState(() {
                    FirebaseFirestore.instance
                        .collection('chatRoom')
                        .doc(id)
                        .delete()
                        .then((_) {
                      print("Message Deleted");
                      Fluttertoast.showToast(
                          msg: "ChatRoom Deleted",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.white,
                          textColor: Colors.black,
                          fontSize: 16.0);
                    });
                  });

                  // Close the dialog
                  Navigator.of(context).pop();
                },
              ),
              CupertinoDialogAction(
                child: const Text('No'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  _logoutDialoge(context) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return CupertinoAlertDialog(
            title: const Text('Are you sure you want to Logout?'),
            // content: const Text('Are you sure to Delete Message?'),
            actions: [
              CupertinoDialogAction(
                child: const Text('Log Out'),
                onPressed: () {
                  setStatus(false);
                  FirebaseAuth.instance.signOut();
                  GoogleSignIn().signOut();
                  Get.offAll(() => const LoginScreen());
                },
              ),
              CupertinoDialogAction(
                child: const Text('No'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }
}
