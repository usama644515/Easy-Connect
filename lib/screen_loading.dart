import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ScreenLoading extends StatefulWidget {
  const ScreenLoading({Key? key}) : super(key: key);

  @override
  _ScreenLoadingState createState() => _ScreenLoadingState();
  Future ScreenLoad(BuildContext context){
    return   showDialog(
      // barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return const CupertinoAlertDialog(
          content: SizedBox(
            height: 65,
            width: 65,
            child: Center(
              child: CircularProgressIndicator(
                color:Colors.amber,
              ),
            ),
          ),
        );
      },
    );
  }
}



class _ScreenLoadingState extends State<ScreenLoading> {





  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) =>showLoaderDialog(context));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(),
    );
  }
  showLoaderDialog(BuildContext context) {
    showDialog(
      // barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return const CupertinoAlertDialog(
          content: SizedBox(
            height: 65,
            width: 65,
            child: Center(
              child: CircularProgressIndicator(
                color:Colors.amber,
              ),
            ),
          ),
        );
      },
    );
  }
}
