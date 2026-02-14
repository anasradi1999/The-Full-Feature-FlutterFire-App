const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.sendNotificationOnProductAdd =
functions.firestore
.document("products/{productId}")
.onCreate(async (snapshot, context) => {

  const product = snapshot.data();

  const payload = {
    notification: {
      title: "منتج جديد 🛍️",
      body: `تمت إضافة ${product.name}`
    },
    topic: "allUsers"
  };

  await admin.messaging().send(payload);

  await admin.firestore().collection("notifications").add({
    title: "منتج جديد 🛍️",
    body: `تمت إضافة ${product.name}`,
    isRead: false,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

});