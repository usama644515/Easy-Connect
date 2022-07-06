import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easyconnect/home/PdfViewer.dart';
import 'package:easyconnect/home/image_view.dart';
import 'package:file_picker/file_picker.dart';
// import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'PdfViewer.dart';

class ChatScreen extends StatefulWidget {
  final docId, username, idTo, userimage;
  const ChatScreen(
      {Key? key, this.docId, this.username, this.idTo, this.userimage})
      : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  bool _validate = false;
  final TextEditingController _msgTextController = new TextEditingController();

  String returnTimeStamp(int messageTimeStamp) {
    String resultString = '';
    var format = DateFormat('dd-MM/hh:mm');
    var date = DateTime.fromMillisecondsSinceEpoch(messageTimeStamp);
    resultString = format.format(date);
    return resultString;
  }

  void open(BuildContext context, final int index, galleryItems) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GalleryPhotoViewWrapper(
          galleryItems: galleryItems,
          backgroundDecoration: const BoxDecoration(
            color: Colors.black,
          ),
          initialIndex: index,
          scrollDirection: Axis.horizontal,
        ),
      ),
    );
  }

  Future<void> _handleSubmitted() async {
    firestore
        .collection('chatRoom')
        .doc(widget.docId)
        .collection('chat')
        .doc()
        .set({
      'details': _msgTextController.text,
      'time': DateTime.now().millisecondsSinceEpoch,
      'attachment': '',
      'uid': _auth.currentUser?.uid,
      'idTo': widget.idTo,
      'type': 'text',
      'view': [(_auth.currentUser!.uid), '${widget.idTo}'],
      'msgRead': false,
    });

    FirebaseFirestore.instance.collection("chatRoom").doc(widget.docId).set({
      'time': DateTime.now(),
      '${widget.idTo}_unreadMsg': FieldValue.increment(1),
      "${_auth.currentUser?.uid}": widget.idTo,
      widget.idTo: "${_auth.currentUser?.uid}",
      'chatId': [(_auth.currentUser!.uid), '${widget.idTo}']
    }, SetOptions(merge: true));

    _msgTextController.clear();
  }

  showLoaderDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: Row(
        children: [
          const CircularProgressIndicator(),
          Container(
              margin: const EdgeInsets.only(left: 15),
              child: const Text("Uploading...")),
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

  late String Attachment, AttachmentUrl;

  Future getFile() async {
    var rng = new Random();
    String randomName = "";
    for (var i = 0; i < 5; i++) {
      // print(rng.nextInt(100));
      randomName += rng.nextInt(100).toString();
    }
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null) {
      PlatformFile fille = result.files.first;
      File file = File(result.files.single.path.toString());
      print(file);
      String fileName = '${randomName}Ticket.pdf';
      Attachment = fille.name; // for document name
      print(Attachment);
      // print(fileName + Attachment);
      // print('${file.readAsBytesSync()}');
      saveAttachment(file.readAsBytesSync(), fileName, Attachment);
    }
  }

  Future saveAttachment(var asset, String name, var fileName) async {
    showLoaderDialog(context);

    Reference reference = FirebaseStorage.instance.ref().child(name);
    UploadTask uploadTask = reference.putData(asset);
    AttachmentUrl =
        await (await uploadTask.whenComplete(() {})).ref.getDownloadURL();
    print("Certificate Url: " + AttachmentUrl);
    print(name);
    firestore
        .collection('chatRoom')
        .doc(widget.docId)
        .collection('chat')
        .doc()
        .set({
      'fileName': fileName, // for document name
      'details': 'Attachment',
      'type': 'file',
      'attachment': AttachmentUrl,
      'time': DateTime.now().millisecondsSinceEpoch,
      'uid': _auth.currentUser?.uid,
      'idTo': widget.idTo,
      'view': [(_auth.currentUser!.uid), '${widget.idTo}'],
      'msgRead': false,
    }).then((value) {
      FirebaseFirestore.instance.collection("chatRoom").doc(widget.docId).set({
        'time': DateTime.now(),
        '${widget.idTo}_unreadMsg': FieldValue.increment(1),
        "${_auth.currentUser?.uid}": widget.idTo,
        widget.idTo: "${_auth.currentUser?.uid}",
        'chatId': [(_auth.currentUser!.uid), '${widget.idTo}']
      }, SetOptions(merge: true));
      Navigator.pop(context);
    });
    Navigator.pop(context);
  }

  ImagePicker imagePicker = ImagePicker();

  Future _openGallery() async {
    File? file;
    var image = await imagePicker.getImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        file = File(image.path);
      });
      uploadImage(file);
    }
  }

  List<String> imageListUrl = <String>[];
  uploadImage(var file) async {
    String imageUrl;
    showLoaderDialog(context);
    Reference reference = FirebaseStorage.instance.ref().child(file.path);
    UploadTask uploadTask = reference.putFile(file);
    TaskSnapshot snapshot = await uploadTask;
    imageUrl = await snapshot.ref.getDownloadURL().then((value) async {
      imageListUrl.add(value);
      firestore
          .collection('chatRoom')
          .doc(widget.docId)
          .collection('chat')
          .doc()
          .set({
        'attachment': imageListUrl,
        'details': 'Image',
        'time': DateTime.now().millisecondsSinceEpoch,
        'uid': '${_auth.currentUser?.uid}',
        'idTo': widget.idTo,
        'type': 'image',
        'userView': true,
        'adminView': true,
      });
    }).then((value) {
      FirebaseFirestore.instance.collection("chatRoom").doc(widget.docId).set({
        'time': DateTime.now(),
        'adminunreadMsg': FieldValue.increment(1),
        "${_auth.currentUser?.uid}": widget.idTo,
        widget.idTo: "${_auth.currentUser?.uid}"
      }, SetOptions(merge: true));
      Navigator.pop(context);
    }).then((value) {
      Navigator.pop(context);
      return "";
    });
  }

  Future<void> _showChoiceDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              "Choose Option",
              style: TextStyle(
                color: Colors.blue[200],
              ),
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  Divider(
                    height: 0,
                    color: Colors.blue[50],
                  ),
                  ListTile(
                    onTap: () {
                      _openGallery();
                    },
                    title: const Text("Image"),
                    leading: const Icon(
                      Icons.image,
                      color: Color(0xFF394d7f),
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: Colors.blue[50],
                  ),
                  ListTile(
                    onTap: () {
                      getFile();
                    },
                    title: const Text("PDF File"),
                    leading: const Icon(
                      Icons.file_copy,
                      color: Color(0xFF394d7f),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

//----for online----
  // Future<bool> onBackPress() async {
  //   await firestore
  //       .collection("chatRoom")
  //       .doc(widget.docId)
  //       .set({'${_auth.currentUser?.displayName}Online': false},
  //           SetOptions(merge: true))
  //       .then((_) => print('offline'))
  //       .catchError((error) => print('Failed: $error'));
  //   Navigator.pop(context);
  //   return Future.value(false);
  // }

  var username;

  @override
  void initState() {
    // TODO: implement initState
    username = widget.username;
    getUserData();
    super.initState();
  }

  String _datetimeFormatter(String _timestamp) {
    String formattedDate =
        DateFormat('dd/MM/yyyy').format(DateTime.parse(_timestamp));
    return formattedDate;
  }

  var lastname;
  var email;
  Future getUserData() async {
    await firestore.collection("Users").doc(widget.idTo).get().then((value) {
      setState(() {
        lastname = value.get('Name');
        email = value.get('Email');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).splashColor,
          flexibleSpace: SafeArea(
            child: Container(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                children: <Widget>[
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // onBackPress();
                    },
                    icon: Icon(
                      Icons.arrow_back,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                  const SizedBox(
                    width: 2,
                  ),
                  CachedNetworkImage(
                    imageUrl: widget.userimage,
                    imageBuilder: (context, imageProvider) => Container(
                      width: 40,
                      height: 40,
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
                  const SizedBox(
                    width: 12,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "${widget.username}",
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(
                          height: 0,
                        ),
                        StreamBuilder<DocumentSnapshot>(
                            stream: firestore
                                .collection('Users')
                                .doc(widget.idTo)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return Container();
                              } else {
                                // print(snapshot.data!.data());
                                Map<String, dynamic> data = snapshot.data!
                                    .data() as Map<String, dynamic>;

                                return data['Online'] == true
                                    ? const Text(
                                        "Online",
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500),
                                      )
                                    : Container();
                              }
                            }),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // userprofile(context, widget.userimage, widget.username,
                      //     joinedDate, lastname, email, "");
                    },
                    child: Icon(
                      Icons.settings,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: WillPopScope(
          onWillPop: null,
          child: Container(
              child: StreamBuilder(
            stream: firestore
                .collection('chatRoom')
                .doc(widget.docId)
                .collection('chat')
                .where('view', arrayContains: _auth.currentUser?.uid)
                .orderBy('time', descending: true)
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              return snapshot.data?.size == 0
                  ? Column(
                      children: [
                        const Expanded(
                          child: Center(
                            child: Text(
                              "Send Message to Start Chat",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 10, right: 5, top: 10, bottom: 2),
                          child: Row(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.84,
                                decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .buttonColor
                                        .withOpacity(0.4),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                        color: Theme.of(context).cardColor,
                                        width: 1)),
                                child: Row(
                                  children: [
                                    IconButton(
                                        icon: Icon(
                                          Icons.attachment,
                                          color: Theme.of(context).hintColor,
                                        ),
                                        onPressed: () {
                                          _showChoiceDialog(context);
                                        }),
                                    Flexible(
                                      child: TextField(
                                        controller: _msgTextController,
                                        // onSubmitted: _handleSubmitted,
                                        decoration: InputDecoration(
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 0, vertical: 0),
                                          border: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                          errorBorder: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          disabledBorder: InputBorder.none,
                                          focusedErrorBorder: InputBorder.none,
                                          hintText: "Send a Message",
                                          errorText: _validate
                                              ? null
                                              : _msgTextController.text.isEmpty
                                                  ? null
                                                  : null,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 2.0),
                                      child: IconButton(
                                          icon: Icon(
                                            Icons.send,
                                            color: Theme.of(context).hintColor,
                                          ),
                                          onPressed: () {
                                            _msgTextController.text.isEmpty
                                                ? _validate = true
                                                : _handleSubmitted();
                                          }),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  // Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //     builder: (context) => ChatBotCollection(
                                  //         insertChatBot: true,
                                  //         docId: widget.docId),
                                  //   ),
                                  // );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10.0, right: 0.0),
                                  child: SvgPicture.asset(
                                      'assets/icons/chatbot.svg',
                                      color: Theme.of(context).hintColor,
                                      height: 35.0),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                              reverse: true,
                              scrollDirection: Axis.vertical,
                              physics: const ClampingScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: snapshot.data?.size,
                              itemBuilder: (context, index) {
                                DocumentSnapshot document = snapshot.data
                                    ?.docs[index] as DocumentSnapshot<Object?>;
                                final Uri? uri =
                                    Uri.tryParse(document['details']);
                                // print(uri);
                                if (document['uid'] != _auth.currentUser?.uid) {
                                  FirebaseFirestore.instance
                                      .collection("chatRoom")
                                      .doc(widget.docId)
                                      .collection('chat')
                                      .doc(document.id)
                                      .set({
                                    'msgRead': true,
                                  }, SetOptions(merge: true));
                                }
                                //--- for unread messages----
                                if (document['uid'] != _auth.currentUser?.uid) {
                                  FirebaseFirestore.instance
                                      .collection("chatRoom")
                                      .doc(widget.docId)
                                      .set({
                                    '${_auth.currentUser?.uid}_unreadMsg': 0,
                                  }, SetOptions(merge: true));
                                }
                                String _msg = document['details'];
                                if (_msg.contains('_username')) {
                                  _msg = _msg.replaceAll('_username', username);
                                  firestore
                                      .collection("chatRoom")
                                      .doc(widget.docId)
                                      .collection('chat')
                                      .doc(document.id)
                                      .set({
                                    'details': _msg
                                  }, SetOptions(merge: true)).then(
                                          (_) => print('online'));
                                }
                                return document['uid'] == _auth.currentUser?.uid
                                    ? Padding(
                                        padding: const EdgeInsets.only(
                                            top: 10, right: 10),
                                        child: document['attachment'] == ""
                                            ? GestureDetector(
                                                onLongPress: () {
                                                  _showDeleteDialoge(
                                                      context, document.id);
                                                },
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 5),
                                                      child: Text(
                                                        returnTimeStamp(
                                                            document['time']),
                                                        style: const TextStyle(
                                                            fontSize: 12),
                                                      ),
                                                    ),
                                                    Container(
                                                      constraints:
                                                          BoxConstraints(
                                                              maxWidth: size
                                                                      .width -
                                                                  size.width *
                                                                      0.30),
                                                      decoration:
                                                          const BoxDecoration(
                                                              gradient:
                                                                  LinearGradient(
                                                                begin: Alignment
                                                                    .topLeft,
                                                                end: Alignment
                                                                    .bottomRight,
                                                                colors: [
                                                                  ui.Color
                                                                      .fromARGB(
                                                                          255,
                                                                          217,
                                                                          115,
                                                                          243),
                                                                  Color(
                                                                      0xff0086f5),
                                                                ],
                                                              ),
                                                              borderRadius: BorderRadius.only(
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          15),
                                                                  bottomLeft: Radius
                                                                      .circular(
                                                                          15),
                                                                  bottomRight: Radius
                                                                      .circular(
                                                                          15))),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(10),
                                                        child: RichText(
                                                          text: TextSpan(
                                                              children: [
                                                                !uri!
                                                                        .hasAbsolutePath
                                                                    ? TextSpan(
                                                                        text:
                                                                            _msg,
                                                                        style: const TextStyle(
                                                                            color: Colors
                                                                                .white,
                                                                            fontSize:
                                                                                18,
                                                                            fontWeight:
                                                                                FontWeight.w400),
                                                                      )
                                                                    : TextSpan(
                                                                        text:
                                                                            _msg,
                                                                        style: const TextStyle(
                                                                            decoration: TextDecoration
                                                                                .underline,
                                                                            color: Colors
                                                                                .white,
                                                                            fontSize:
                                                                                18,
                                                                            fontWeight:
                                                                                FontWeight.w400),
                                                                        recognizer: TapGestureRecognizer()
                                                                          ..onTap = () async {
                                                                            var url =
                                                                                uri;
                                                                            if (await canLaunchUrl(url)) {
                                                                              await launchUrl(url);
                                                                            } else {
                                                                              throw "Cannot load url";
                                                                            }
                                                                          }),
                                                              ]),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 1),
                                                    SvgPicture.asset(
                                                        'assets/images/read.svg',
                                                        color: document[
                                                                    'msgRead'] ==
                                                                true
                                                            ? Colors.blue
                                                            : Colors.grey,
                                                        width: 17.0),
                                                  ],
                                                ),
                                              )
                                            : GestureDetector(
                                                onLongPress: () {
                                                  _showDeleteDialoge(
                                                      context, document.id);
                                                },
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 5),
                                                      child: Text(
                                                        returnTimeStamp(
                                                            document['time']),
                                                        style: const TextStyle(
                                                            fontSize: 12),
                                                      ),
                                                    ),
                                                    Container(
                                                      constraints:
                                                          BoxConstraints(
                                                              maxWidth: size
                                                                      .width -
                                                                  size.width *
                                                                      0.30),
                                                      decoration:
                                                          const BoxDecoration(
                                                        color: Colors
                                                            .white, // admin side
                                                        borderRadius:
                                                            BorderRadius.only(
                                                                topLeft:
                                                                    Radius
                                                                        .circular(
                                                                            15),
                                                                bottomLeft:
                                                                    Radius
                                                                        .circular(
                                                                            15),
                                                                bottomRight: Radius
                                                                    .circular(
                                                                        15)),
                                                      ),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          document['type'] ==
                                                                  'file'
                                                              ? Padding(
                                                                  padding: const EdgeInsets
                                                                          .only(
                                                                      bottom:
                                                                          2),
                                                                  child:
                                                                      GestureDetector(
                                                                    onTap: () {
                                                                      Navigator.push(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                              builder: (context) => PdfViewer(
                                                                                    url: document['attachment'],
                                                                                  )));
                                                                    },
                                                                    child:
                                                                        // admin side
                                                                        Container(
                                                                      height:
                                                                          60.0,
                                                                      constraints:
                                                                          BoxConstraints(
                                                                              maxWidth: size.width - size.width * 0.30),
                                                                      decoration:
                                                                          const BoxDecoration(
                                                                        gradient:
                                                                            LinearGradient(
                                                                          begin:
                                                                              Alignment.topLeft,
                                                                          end: Alignment
                                                                              .bottomRight,
                                                                          colors: [
                                                                            ui.Color.fromARGB(
                                                                                255,
                                                                                217,
                                                                                115,
                                                                                243),
                                                                            Color(0xff0086f5),
                                                                          ],
                                                                        ),
                                                                        borderRadius: BorderRadius.only(
                                                                            topLeft:
                                                                                Radius.circular(15),
                                                                            bottomLeft: Radius.circular(15),
                                                                            bottomRight: Radius.circular(15)),
                                                                      ),
                                                                      child:
                                                                          Padding(
                                                                        padding:
                                                                            const EdgeInsets.all(10),
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            Row(
                                                                              children: [
                                                                                Image.asset('assets/images/pdf.png', width: 30.0),
                                                                                const SizedBox(width: 5.0),
                                                                                SizedBox(
                                                                                  width: MediaQuery.of(context).size.width * 0.4,
                                                                                  child: Text(
                                                                                    document.get('fileName'),
                                                                                    style: const TextStyle(color: Colors.white, fontSize: 16),
                                                                                    overflow: TextOverflow.ellipsis,
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                            const Text(
                                                                              "View",
                                                                              style: TextStyle(color: Colors.white, fontSize: 18),
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                )
                                                              : Padding(
                                                                  padding: const EdgeInsets
                                                                          .only(
                                                                      bottom:
                                                                          0),
                                                                  child:
                                                                      GestureDetector(
                                                                    onTap: () {
                                                                      open(
                                                                          context,
                                                                          0,
                                                                          document[
                                                                              'attachment']);
                                                                    },
                                                                    child:
                                                                        CachedNetworkImage(
                                                                      imageUrl:
                                                                          "${document['attachment'][0]}",
                                                                      imageBuilder:
                                                                          (context, imageProvider) =>
                                                                              Container(
                                                                        height: size.height *
                                                                            0.30,
                                                                        width: size.width -
                                                                            size.width *
                                                                                0.30,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          borderRadius: const BorderRadius.only(
                                                                              topLeft: Radius.circular(15),
                                                                              bottomLeft: Radius.circular(15),
                                                                              bottomRight: Radius.circular(15)),
                                                                          image:
                                                                              DecorationImage(
                                                                            image:
                                                                                imageProvider,
                                                                            fit:
                                                                                BoxFit.cover,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      placeholder:
                                                                          (context, url) =>
                                                                              const CircularProgressIndicator(),
                                                                      errorWidget: (context,
                                                                              url,
                                                                              error) =>
                                                                          const Icon(
                                                                              Icons.error),
                                                                    ),
                                                                  ),
                                                                ),
                                                          // Padding(
                                                          //   padding:
                                                          //       const EdgeInsets
                                                          //           .all(10),
                                                          //   child: Text(
                                                          //     document['details'],
                                                          //     style: const TextStyle(
                                                          //         color: Colors
                                                          //             .white,
                                                          //         fontSize: 16,
                                                          //         fontWeight:
                                                          //             FontWeight
                                                          //                 .w400),
                                                          //   ),
                                                          // )
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(width: 1),
                                                    SvgPicture.asset(
                                                        'assets/images/read.svg',
                                                        color: document[
                                                                    'msgRead'] ==
                                                                true
                                                            ? Colors.blue
                                                            : Colors.grey,
                                                        width: 17.0),
                                                  ],
                                                ),
                                              ),
                                      )
                                    : Padding(
                                        padding: const EdgeInsets.only(
                                            top: 10, left: 10),
                                        child: document['attachment'] == ""
                                            ? GestureDetector(
                                                onLongPress: () {
                                                  _showDeleteDialoge(
                                                      context, document.id);
                                                },
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    Container(
                                                      constraints:
                                                          BoxConstraints(
                                                              maxWidth: size
                                                                      .width -
                                                                  size.width *
                                                                      0.30),
                                                      decoration:
                                                          const BoxDecoration(
                                                        color: Colors.grey,
                                                        borderRadius:
                                                            BorderRadius.only(
                                                                topRight:
                                                                    Radius
                                                                        .circular(
                                                                            15),
                                                                bottomLeft:
                                                                    Radius
                                                                        .circular(
                                                                            15),
                                                                bottomRight: Radius
                                                                    .circular(
                                                                        15)),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(10),
                                                        child: RichText(
                                                          text: TextSpan(
                                                              children: [
                                                                !uri!
                                                                        .hasAbsolutePath
                                                                    ? TextSpan(
                                                                        text:
                                                                            _msg,
                                                                        style: const TextStyle(
                                                                            color: Colors
                                                                                .white,
                                                                            fontSize:
                                                                                18,
                                                                            fontWeight:
                                                                                FontWeight.w400),
                                                                      )
                                                                    : TextSpan(
                                                                        text:
                                                                            _msg,
                                                                        style: const TextStyle(
                                                                            decoration: TextDecoration
                                                                                .underline,
                                                                            color: Colors
                                                                                .white,
                                                                            fontSize:
                                                                                18,
                                                                            fontWeight:
                                                                                FontWeight.w400),
                                                                        recognizer: TapGestureRecognizer()
                                                                          ..onTap = () async {
                                                                            var url =
                                                                                uri;
                                                                            if (await canLaunchUrl(url)) {
                                                                              await launchUrl(url);
                                                                            } else {
                                                                              throw "Cannot load url";
                                                                            }
                                                                          }),
                                                              ]),
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 5),
                                                      child: Text(
                                                        returnTimeStamp(
                                                            document['time']),
                                                        style: const TextStyle(
                                                            fontSize: 12),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            : GestureDetector(
                                                onLongPress: () {
                                                  _showDeleteDialoge(
                                                      context, document.id);
                                                },
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    Container(
                                                      constraints:
                                                          BoxConstraints(
                                                              maxWidth: size
                                                                      .width -
                                                                  size.width *
                                                                      0.30),
                                                      decoration:
                                                          const BoxDecoration(
                                                        color: Colors.grey,
                                                        borderRadius:
                                                            BorderRadius.only(
                                                                topRight:
                                                                    Radius
                                                                        .circular(
                                                                            15),
                                                                bottomLeft:
                                                                    Radius
                                                                        .circular(
                                                                            15),
                                                                bottomRight: Radius
                                                                    .circular(
                                                                        15)),
                                                      ),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          document['type'] ==
                                                                  'file'
                                                              ? Padding(
                                                                  padding: const EdgeInsets
                                                                          .only(
                                                                      bottom:
                                                                          2),
                                                                  child:
                                                                      GestureDetector(
                                                                    onTap: () {
                                                                      Navigator.push(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                              builder: (context) => PdfViewer(
                                                                                    url: document['attachment'],
                                                                                  )));
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      height:
                                                                          60,
                                                                      constraints:
                                                                          BoxConstraints(
                                                                              maxWidth: size.width - size.width * 0.30),
                                                                      decoration:
                                                                          const BoxDecoration(
                                                                        color: Colors
                                                                            .grey,
                                                                        borderRadius: BorderRadius.only(
                                                                            topRight:
                                                                                Radius.circular(15),
                                                                            bottomLeft: Radius.circular(15),
                                                                            bottomRight: Radius.circular(15)),
                                                                      ),
                                                                      child:
                                                                          Padding(
                                                                        padding:
                                                                            const EdgeInsets.all(10),
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            Row(
                                                                              children: [
                                                                                Image.asset('assets/images/pdf.png', width: 30.0),
                                                                                const SizedBox(width: 5.0),
                                                                                SizedBox(
                                                                                  width: MediaQuery.of(context).size.width * 0.4,
                                                                                  child: Text(
                                                                                    document.get('fileName'),
                                                                                    style: const TextStyle(color: Colors.white, fontSize: 16),
                                                                                    overflow: TextOverflow.ellipsis,
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                            const Text(
                                                                              "View",
                                                                              style: TextStyle(color: Colors.white, fontSize: 18),
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                )
                                                              : Padding(
                                                                  padding: const EdgeInsets
                                                                          .only(
                                                                      bottom:
                                                                          0),
                                                                  child:
                                                                      GestureDetector(
                                                                    onTap: () {
                                                                      open(
                                                                          context,
                                                                          0,
                                                                          document[
                                                                              'attachment']);
                                                                    },
                                                                    child:
                                                                        CachedNetworkImage(
                                                                      imageUrl:
                                                                          "${document['attachment'][0]}",
                                                                      imageBuilder:
                                                                          (context, imageProvider) =>
                                                                              Container(
                                                                        height: size.height *
                                                                            0.30,
                                                                        width: size.width -
                                                                            size.width *
                                                                                0.30,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          borderRadius: const BorderRadius.only(
                                                                              topRight: Radius.circular(15),
                                                                              bottomLeft: Radius.circular(15),
                                                                              bottomRight: Radius.circular(15)),
                                                                          image:
                                                                              DecorationImage(
                                                                            image:
                                                                                imageProvider,
                                                                            fit:
                                                                                BoxFit.cover,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      placeholder: (context,
                                                                              url) =>
                                                                          const Center(
                                                                              child: CircularProgressIndicator()),
                                                                      errorWidget: (context,
                                                                              url,
                                                                              error) =>
                                                                          const Icon(
                                                                              Icons.error),
                                                                    ),
                                                                  ),
                                                                ),
                                                          // Row(
                                                          //   mainAxisAlignment:
                                                          //       MainAxisAlignment
                                                          //           .start,
                                                          //   crossAxisAlignment:
                                                          //       CrossAxisAlignment
                                                          //           .end,
                                                          //   children: [
                                                          //     Container(
                                                          //       constraints: BoxConstraints(
                                                          //           maxWidth: size
                                                          //                   .width -
                                                          //               size.width *
                                                          //                   0.30),
                                                          //       decoration:
                                                          //           BoxDecoration(
                                                          //         color: Colors.grey,
                                                          //         borderRadius:
                                                          //             BorderRadius
                                                          //                 .circular(
                                                          //                     10.0),
                                                          //       ),
                                                          //       child: Padding(
                                                          //         padding:
                                                          //             const EdgeInsets
                                                          //                 .all(10),
                                                          //         child: Text(
                                                          //           document[
                                                          //               'details'],
                                                          //           style: const TextStyle(
                                                          //               color: Colors
                                                          //                   .white,
                                                          //               fontSize:
                                                          //                   16,
                                                          //               fontWeight:
                                                          //                   FontWeight
                                                          //                       .w400),
                                                          //         ),
                                                          //       ),
                                                          //     ),
                                                          //   ],
                                                          // )
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 5),
                                                      child: Text(
                                                        returnTimeStamp(
                                                            document['time']),
                                                        style: const TextStyle(
                                                            fontSize: 12),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                      );
                              }),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 10, right: 5, top: 10, bottom: 2),
                          child: Row(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.84,
                                decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .buttonColor
                                        .withOpacity(0.4),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                        color: Theme.of(context).cardColor,
                                        width: 1)),
                                child: Row(
                                  children: [
                                    IconButton(
                                        icon: Icon(
                                          Icons.attachment,
                                          color: Theme.of(context).hintColor,
                                        ),
                                        onPressed: () {
                                          _showChoiceDialog(context);
                                        }),
                                    Flexible(
                                      child: TextField(
                                        controller: _msgTextController,
                                        // onSubmitted: _handleSubmitted,
                                        decoration: InputDecoration(
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 0, vertical: 0),
                                          border: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                          errorBorder: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          disabledBorder: InputBorder.none,
                                          focusedErrorBorder: InputBorder.none,
                                          hintText: "Send a Message",
                                          errorText: _validate
                                              ? null
                                              : _msgTextController.text.isEmpty
                                                  ? null
                                                  : null,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 2.0),
                                      child: IconButton(
                                          icon: Icon(
                                            Icons.send,
                                            color: Theme.of(context).hintColor,
                                          ),
                                          onPressed: () {
                                            _msgTextController.text.isEmpty
                                                ? _validate = true
                                                : _handleSubmitted();
                                          }),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  // Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //     builder: (context) => ChatBotCollection(
                                  //         insertChatBot: true,
                                  //         docId: widget.docId),
                                  //   ),
                                  // );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10.0, right: 0.0),
                                  child: SvgPicture.asset(
                                      'assets/icons/chatbot.svg',
                                      color: Theme.of(context).hintColor,
                                      height: 35.0),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
            },
          )),
        ),
      ),
    );
  }

  _showDeleteDialoge(context, String id) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return CupertinoAlertDialog(
            title: const Text('Message Delete'),
            content: const Text('Are you sure to Delete Message?'),
            actions: [
              CupertinoDialogAction(
                child: const Text('Yes'),
                onPressed: () {
                  setState(() {
                    FirebaseFirestore.instance
                        .collection('chatRoom')
                        .doc(widget.docId)
                        .collection('chat')
                        .doc(id)
                        .set({
                      'view':
                          FieldValue.arrayRemove(['${_auth.currentUser?.uid}'])
                    }, SetOptions(merge: true)).then((_) {
                      print("Message Deleted");
                      Fluttertoast.showToast(
                          msg: "Message Deleted",
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
}
