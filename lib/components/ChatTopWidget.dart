import 'package:chat/components/Permissions.dart';
import 'package:chat/main.dart';
import 'package:chat/models/UserModel.dart';
import 'package:chat/screens/UserProfileScreen.dart';
import 'package:chat/utils/AppColors.dart';
import 'package:chat/utils/AppCommon.dart';
import 'package:chat/utils/AppConstants.dart';
import 'package:chat/utils/AppDataProvider.dart';
import 'package:chat/utils/CallFunctions.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';

class ChatAppBarWidget extends StatefulWidget {
  final UserModel? receiverUser;

  ChatAppBarWidget({required this.receiverUser});

  @override
  ChatAppBarWidgetState createState() => ChatAppBarWidgetState();
}

class ChatAppBarWidgetState extends State<ChatAppBarWidget> {
  bool isRequestAccept = false;
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    await chatRequestService
        .isRequestsUserExist(widget.receiverUser!.uid!)
        .then((value) {
      isRequestAccept = !value;
      setState(() {});
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    String getTime(int val) {
      String? time;
      DateTime date = DateTime.fromMicrosecondsSinceEpoch(val * 1000);
      if (date.day == DateTime.now().day) {
        time = "at ${DateFormat('hh:mm a').format(date)}";
      } else {
        time = date.timeAgo;
      }
      return time;
    }

    return AppBar(
      automaticallyImplyLeading: false,
      title: StreamBuilder<UserModel>(
        stream: userService.singleUser(widget.receiverUser!.uid),
        builder: (context, snap) {
          if (snap.hasError) {
            return Container();
          }
          if (snap.hasData) {
            UserModel data = snap.data!;

            return Row(
              children: [
                Row(
                  children: [
                    Icon(Icons.arrow_back, color: whiteColor),
                    4.width,
                    data.photoUrl!.isEmpty
                        ? Hero(
                            tag: data.uid.validate(),
                            child: Image.asset("assets/app_icon.png",
                                    height: 35, width: 35, fit: BoxFit.cover)
                                .cornerRadiusWithClipRRect(50))
                        : Hero(
                            tag: data.uid!,
                            child: Image.network(data.photoUrl.validate(),
                                    height: 35, width: 35, fit: BoxFit.cover)
                                .cornerRadiusWithClipRRect(50)),
                  ],
                ).paddingSymmetric(vertical: 16).onTap(() => finish(context)),
                10.width,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data.name!, style: TextStyle(color: whiteColor)),
                    data.isPresence!
                        ? Text('Online',
                            style: secondaryTextStyle(color: Colors.white70))
                        : Text(
                            "Last seen ${getTime(data.lastSeen!.validate())}",
                            style: secondaryTextStyle(color: Colors.white70)),
                  ],
                ).paddingSymmetric(vertical: 16).onTap(
                  () {
                    UserProfileScreen(user: data).launch(context);
                  },
                ).expand(),
              ],
            );
          }

          return snapWidgetHelper(snap, loadingWidget: Container());
        },
      ),
      actions: [
        // IconButton(
        //   icon: Icon(Icons.video_call),
        //   onPressed: isRequestAccept
        //       ? () async {
        //           return await Permissions.cameraAndMicrophonePermissionsGranted() ? CallFunctions.dial(context: context, from: sender, to: widget.receiverUser!) : {};
        //         }
        //       : null,
        // ),
        // IconButton(
        //   icon: Icon(Icons.call),
        //   onPressed: isRequestAccept
        //       ? () async {
        //           return await Permissions.cameraAndMicrophonePermissionsGranted() ? CallFunctions.voiceDial(context: context, from: sender, to: widget.receiverUser!) : {};
        //         }
        //       : null,
        // ),
        PopupMenuButton(
          padding: EdgeInsets.zero,
          offset: Offset(10, -50),
          icon: Icon(Icons.more_vert),
          color: context.cardColor,
          onSelected: (dynamic value) async {
            if (value == 1) {
              UserProfileScreen(user: widget.receiverUser).launch(context);
            } else if (value == 2) {
              toast(COMING_SOON);
            } else if (value == 3) {
              toast(COMING_SOON);
            } else if (value == 4) {
              bool? res = await showConfirmDialog(
                  context, "clear_chats".translate,
                  buttonColor: secondaryColor);
              if (res ?? false) {
                chatMessageService
                    .clearAllMessages(
                        senderId: sender.uid,
                        receiverId: widget.receiverUser!.uid!)
                    .then((value) {
                  toast("chat_clear".translate);
                  hideKeyboard(context);
                }).catchError((e) {
                  toast(e);
                });
              }
            }
          },
          itemBuilder: (context) =>
              isRequestAccept ? chatScreenPopUpMenuItem : <PopupMenuItem>[],
        ),
      ],
      backgroundColor: context.primaryColor,
    );
  }
}
