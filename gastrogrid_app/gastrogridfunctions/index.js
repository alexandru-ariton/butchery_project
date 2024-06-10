const functions = require("firebase-functions");
const admin = require("firebase-admin");
const serviceAccount = require("./serviceAccountKey.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://gastrogridfirebase.firebaseio.com",
});

exports.sendOrderStatusNotification = functions.firestore
    .document("orders/{orderId}")
    .onUpdate((change, context) => {
      const newValue = change.after.data();
      const oldValue = change.before.data();

      console.log("Order update detected:", context.params.orderId);
      console.log("Old status:", oldValue.status);
      console.log("New status:", newValue.status);

      if (newValue.status !== oldValue.status) {
        const payload = {
          notification: {
            title: "Order Status Updated",
            body: `Order ${context.params.orderId} status is now 
          `+`${newValue.status}`,
          },
          topic: "orderUpdates",
        };

        return admin.messaging().send(payload)
            .then((response) => {
              console.log("Successfully sent message:", response);
            })
            .catch((error) => {
              console.error("Error sending message:", error);
            });
      } else {
        return null;
      }
    });
