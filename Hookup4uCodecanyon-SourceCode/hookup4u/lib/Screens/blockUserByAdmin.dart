import 'package:flutter/material.dart';
import 'package:hookup4u/util/color.dart';

class BlockUser extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondryColor.withOpacity(.5),
      body: AlertDialog(
        actionsPadding: EdgeInsets.only(right: 10),
        backgroundColor: Colors.white,
        actions: [
          Text("for more info visit: https://help.deligence.com"),
        ],
        title: Column(
          children: [
            Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Center(
                  child: Container(
                      height: 50,
                      width: 100,
                      child: Image.asset(
                        "asset/hookup4u-Logo-BP.png",
                        fit: BoxFit.contain,
                      )),
                )),
            Text(
              "sorry, you can't access the application!",
              style: TextStyle(color: primaryColor),
            ),
          ],
        ),
        content: Text(
            "you're blocked by the admin and your profile will also not appear for other users."),
      ),
    );
  }
}
