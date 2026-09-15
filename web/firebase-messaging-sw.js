/* -------------------------------------------------------------
   Firebase Messaging Service Worker
--------------------------------------------------------------*/

importScripts("https://www.gstatic.com/firebasejs/10.12.2/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.12.2/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyCIberUASN5W6CgMIE1f00kwNMJY5HwVQg",
  authDomain: "communication-40093.firebaseapp.com",
  projectId: "communication-40093",
  storageBucket: "communication-40093.appspot.com",
  messagingSenderId: "114032294912",
  appId: "1:114032294912:web:cd373273ae45e626d92ce5",
});

const messaging = firebase.messaging();
console.log("[SW] Firebase service worker initialized");

/* -------------------------------------------------------------
   1️⃣ Background FCM → show incoming call notification
--------------------------------------------------------------*/
//messaging.onBackgroundMessage((payload) => {
//  console.log("[SW] Background FCM received:", payload);
//
//  const data = payload.data || {};
//  const n = payload.notification || {};
//
//  // Use your fields
//  const type = data.type || "";
//  const callerName = data.callerName || "Unknown";
//  const callId = data.callId || "";
//  const channelName = data.channelName || "";
//  const appId = data.appId || "";
//  const token = data.token || "";
//  const notificationId = data.notificationId || "";
//
//  // Only show call notification for CALL_INCOMING
//  if (type !== "CALL_INCOMING") {
//    console.log("[SW] Not a CALL_INCOMING, skipping special UI");
//    return;
//  }
//
//  const title = n.title || "Incoming call";
//  const body = n.body || `${callerName} is calling you`;
//
//  self.registration.showNotification(title, {
//    body,
//    icon: "/icons/Icon-192.png",
//    badge: "/icons/Icon-192.png",
//    vibrate: [200, 100, 200],
//    requireInteraction: true,
//    tag: "incoming-call",
//    actions: [
//      { action: "accept_call", title: "Accept" },
//      { action: "reject_call", title: "Reject" },
//    ],
//    data: {
//      // put everything Flutter might need:
//      type,
//      callId,
//      callerName,
//      channelName,
//      appId,
//      token,
//      notificationId,
//    },
//  });
//});
//
///* -------------------------------------------------------------
//   2️⃣ Send event from SW → Flutter Web
//--------------------------------------------------------------*/
//function broadcastToClients(message) {
//  console.log("[SW] Broadcasting to clients:", message);
//
//  return clients
//    .matchAll({ type: "window", includeUncontrolled: true })
//    .then((clientList) => {
//      console.log("[SW] Open window clients:", clientList.length);
//
//      if (clientList.length === 0) {
//        // No tab open → open your app. You can also pass query params here.
//        console.log("[SW] No clients, opening new window");
//        return clients.openWindow(
//          "/?notif_action=" +
//            message.action +
//            "&callId=" +
//            (message.payload.callId || "") +
//            "&callerName=" +
//            encodeURIComponent(message.payload.callerName || "")
//        );
//      }
//
//      clientList.forEach((client) => {
//        console.log("[SW] Posting message to client:", client.id || client.url);
//        client.postMessage(message);
//        client.focus();
//      });
//    });
//}
//
///* -------------------------------------------------------------
//   3️⃣ Notification click: Accept / Reject / Body click
//--------------------------------------------------------------*/
//self.addEventListener("notificationclick", (event) => {
//  console.log("[SW] notificationclick fired. Action:", event.action);
//  console.log("[SW] notification data:", event.notification.data);
//
//  const payload = event.notification.data || {};
//  const action = event.action || "body_click";
//
//  event.notification.close();
//
//  event.waitUntil(
//    broadcastToClients({
//      type: "INCOMING_CALL_ACTION",
//      action: action,  // "accept_call" | "reject_call" | "body_click"
//      payload: payload,
//    })
//  );
//});
