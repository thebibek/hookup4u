import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hookup4u/models/user_model.dart';
import 'package:hookup4u/util/color.dart';

import 'call.dart';

class DialCall extends StatefulWidget {
  final String channelName;
  final User receiver;
  final String callType;
  const DialCall({@required this.channelName, this.receiver, this.callType});

  @override
  _DialCallState createState() => _DialCallState();
}

class _DialCallState extends State<DialCall> {
  bool ispickup = false;
  //final db = Firestore.instance;
  CollectionReference callRef = Firestore.instance.collection("calls");
  @override
  void initState() {
    _addCallingData();
    super.initState();
  }

  _addCallingData() async {
    await callRef.document(widget.channelName).delete();
    await callRef.document(widget.channelName).setData({
      'callType': widget.callType,
      'calling': true,
      'response': "Awaiting",
      'channel_id': widget.channelName,
      'last_call': FieldValue.serverTimestamp()
    });
  }

  @override
  void dispose() async {
    super.dispose();
    ispickup = true;
    await callRef
        .document(widget.channelName)
        .setData({'calling': false}, merge: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
          child: StreamBuilder<QuerySnapshot>(
              stream: callRef
                  .where("channel_id", isEqualTo: "${widget.channelName}")
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                Future.delayed(Duration(seconds: 30), () async {
                  if (!ispickup) {
                    await callRef
                        .document(widget.channelName)
                        .updateData({'response': 'Not-answer'});
                  }
                });
                if (!snapshot.hasData) {
                  return Container();
                } else
                  try {
                    switch (snapshot.data.documents[0]['response']) {
                      case "Awaiting":
                        {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              CircleAvatar(
                                backgroundColor: Colors.grey,
                                radius: 60,
                                child: Center(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                      60,
                                    ),
                                    child: CachedNetworkImage(
                                      imageUrl:
                                          widget.receiver.imageUrl[0] ?? '',
                                      useOldImageOnUrlChange: true,
                                      placeholder: (context, url) =>
                                          CupertinoActivityIndicator(
                                        radius: 15,
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Icon(
                                            Icons.error,
                                            color: Colors.black,
                                            size: 30,
                                          ),
                                          Text(
                                            "Enable to load",
                                            style: TextStyle(
                                              color: Colors.black,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Text("Calling to ${widget.receiver.name}...",
                                  style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold)),
                              RaisedButton.icon(
                                  color: primaryColor,
                                  icon: Icon(
                                    Icons.call_end,
                                    color: Colors.white,
                                  ),
                                  label: Text(
                                    "END",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  onPressed: () async {
                                    await callRef
                                        .document(widget.channelName)
                                        .setData({'response': "Call_Cancelled"},
                                            merge: true);
                                    // Navigator.pop(context);
                                  })
                            ],
                          );
                        }
                        break;
                      case "Pickup":
                        {
                          ispickup = true;
                          return CallPage(
                              channelName: widget.channelName,
                              role: ClientRole.Broadcaster,
                              callType: widget.callType);
                        }
                        break;
                      case "Decline":
                        {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Text("${widget.receiver.name} is Busy",
                                  style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold)),
                              RaisedButton.icon(
                                  color: primaryColor,
                                  icon: Icon(
                                    Icons.arrow_back,
                                    color: Colors.white,
                                  ),
                                  label: Text(
                                    "Back",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  onPressed: () async {
                                    Navigator.pop(context);
                                  })
                            ],
                          );
                        }
                        break;
                      case "Not-answer":
                        {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Text("${widget.receiver.name} is Not-answering",
                                  style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold)),
                              RaisedButton.icon(
                                  color: primaryColor,
                                  icon: Icon(
                                    Icons.arrow_back,
                                    color: Colors.white,
                                  ),
                                  label: Text(
                                    "Back",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  onPressed: () async {
                                    Navigator.pop(context);
                                  })
                            ],
                          );
                        }
                        break;
                      //call end
                      default:
                        {
                          Future.delayed(Duration(milliseconds: 500), () {
                            Navigator.pop(context);
                          });
                          return Container(
                            child: Text("Call Ended..."),
                          );
                        }
                        break;
                    }
                  }
                  //  else if (!snapshot.data.documents[0]['calling']) {
                  //   Navigator.pop(context);
                  // }
                  catch (e) {
                    return Container();
                  }
              })),
    );
  }
}
