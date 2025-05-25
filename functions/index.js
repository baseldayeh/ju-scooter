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
const nodemailer = require('nodemailer');

// إعداد Nodemailer لإرسال البريد الإلكتروني
const functions = require("firebase-functions");
const nodemailer = require("nodemailer");

// إعداد Nodemailer لإرسال البريد الإلكتروني
const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: "your-email@gmail.com", // استبدلي ببريدك الإلكتروني
    pass: "your-app-password", // استبدلي بكلمة مرور التطبيق (App Password)
  },
});

exports.sendVerificationCode = functions.region("us-central1").https.onCall(async (data, context) => {
  const email = data.email;
  const code = data.code;

  if (!email || !code) {
    throw new functions.https.HttpsError("invalid-argument", "Email and code are required");
  }

  const mailOptions = {
    from: "your-email@gmail.com",
    to: email,
    subject: "Your Verification Code",
    text: `Your verification code is: ${code}`,
  };

  try {
    await transporter.sendMail(mailOptions);
    return { success: true, message: "Verification code sent successfully" };
  } catch (error) {
    throw new functions.https.HttpsError("internal", "Failed to send verification code", error.message);
  }
});