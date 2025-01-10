const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.sendNotification = functions.firestore
  .document("notifications/{notificationId}")
  .onCreate(async (snap, context) => {
    const notification = snap.data();

    const message = {
      token: notification.to,
      notification: {
        title: notification.title,
        body: notification.body,
      },
    };

    try {
      await admin.messaging().send(message);
      console.log("Notification sent successfully");
    } catch (error) {
      console.log("Error sending notification:", error);
    }
  });
