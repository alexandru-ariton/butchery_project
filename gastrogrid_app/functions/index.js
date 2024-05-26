/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });


const functions = require('firebase-functions');
const admin = require('firebase-admin');
const braintree = require('braintree');

admin.initializeApp();

const gateway = new braintree.BraintreeGateway({
  environment: braintree.Environment.Sandbox, // Sau braintree.Environment.Production pentru producție
  merchantId: 'your_merchant_id',
  publicKey: 'your_public_key',
  privateKey: 'your_private_key',
});

exports.generateClientToken = functions.https.onRequest((request, response) => {
  gateway.clientToken.generate({}, (err, res) => {
    if (err) {
      response.status(500).send(err);
    } else {
      response.send(res.clientToken);
    }
  });
});


