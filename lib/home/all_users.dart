import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easyconnect/home/chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AllUsers extends StatefulWidget {
  const AllUsers({Key? key}) : super(key: key);

  @override
  State<AllUsers> createState() => _AllUsersState();
}

class _AllUsersState extends State<AllUsers> {
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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        iconTheme: const IconThemeData(),
        title: Text("Start Chat",
            style: TextStyle(
              color: Theme.of(context).hintColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            )),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Users')
              .where('uid', isNotEqualTo: _auth.currentUser?.uid)
              // .where("chatId", arrayContains: "${_auth.currentUser!.uid}")
              // .orderBy('time', descending: true)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            return snapshot.connectionState == ConnectionState.waiting
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      DocumentSnapshot data = snapshot.data!.docs[index];

                      return ListTile(
                        dense: true,
                        onTap: () {
                          String chatRoomId = getChatRoomId(
                              _auth.currentUser!.uid, data.get('uid'));
                          Navigator.pop(context);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ChatScreen(
                                        username: data.get('Name'),
                                        userimage: data.get('Photourl'),
                                        docId: chatRoomId,
                                        idTo: data.get("uid"),
                                      )));
                        },
                        leading: CachedNetworkImage(
                          imageUrl: data.get('Photourl'),
                          imageBuilder: (context, imageProvider) => Container(
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
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                        title: Row(
                          children: [
                            Text(
                              data.get('Name'),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 17),
                            ),
                          ],
                        ),
                        subtitle: Text(data.get('Email')),
                        // trailing: const Icon(
                        //     Icons.arrow_forward_ios_sharp),
                      );
                    });
          },
        ),
      ),
    );
  }
}
