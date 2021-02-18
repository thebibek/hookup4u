const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });
exports.sendNotification = functions.firestore
    .document('/chats/{chatId}/messages/{msgId}')
    .onCreate(async (snap, context) => {
        console.log('----------------start function--------------------')
        console.log(context.params.chatId)
        const doc = snap.data()
        const idFrom = doc.sender_id
        const idTo = doc.receiver_id
        const contentMessage = doc.text
        var contentType = ""
        if (typeof doc.type !== 'undefined') {
            contentType = doc.type
        }
        console.log(contentType)

        // Get push token user to (receive)
        const ref = admin.firestore().collection('Users').doc(idTo)
        const userIdTo = await ref.get();
        const ref2 = admin.firestore().collection('Users').doc(idFrom)
        const userIdFrom = await ref2.get();
        console.log(userIdTo.data().pushToken);
        const payload = {
            notification: {
                title: contentType === 'Call' ? `call from ${userIdFrom.data().UserName}` : `You have a message from ${userIdFrom.data().UserName}`,
                body: contentMessage,
                badge: '1',
                sound: 'default'
            },
            data: {
                'senderName': userIdFrom.data().UserName,
                'senderPicture': userIdFrom.data().Pictures[0],
                'channel_id': context.params.chatId,
                "type": contentType,
                "category": "${url}?destination=${data.destination}",
                "click_action": "FLUTTER_NOTIFICATION_CLICK",
            }
        }
        if (userIdTo.data().pushToken !== null) {
            admin
                .messaging()
                .sendToDevice(userIdTo.data().pushToken, payload);
        }

    });
exports.sendMatchNotification = functions.firestore
    .document('/Users/{userId}/Matches/{matchUserId}')
    .onCreate(async (snashot, context) => {
        const doc = snashot.data()
        const matchId = doc.Matches
        const matchwith = context.params.userId
        console.log('========')
        const matchUser = await admin.firestore().collection('Users').doc(matchId).get()
        const matchWithUser = await admin.firestore().collection('Users').doc(matchwith).get()
        const payload = {
            notification: {
                title: `It's a new match with ${matchWithUser.data().UserName}`,
                body: `Now you can start chat with ${matchWithUser.data().UserName}`,
                badge: '1',
                sound: 'default'
            }
        }
        if (matchUser.data().pushToken !== null) {
            admin
                .messaging()
                .sendToDevice(matchUser.data().pushToken, payload);
        }

        console.log(matchUser.data().UserName),
            console.log(matchWithUser.data().UserName)


    })
