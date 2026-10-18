importScripts('https://www.gstatic.com/firebasejs/10.12.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.12.0/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: 'AIzaSyDLZr4hM-aYSckpFVSYZilsJAhgQqsK0yE',
  authDomain: 'smart-locker-iot-10a0e.firebaseapp.com',
  projectId: 'smart-locker-iot-10a0e',
  storageBucket: 'smart-locker-iot-10a0e.firebasestorage.app',
  messagingSenderId: '651310592592',
  appId: '1:651310592592:web:d34f6f7012b9eb56251755'
});

const messaging = firebase.messaging();