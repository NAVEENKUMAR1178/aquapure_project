// Sends an FCM push. Needs FIREBASE_SERVICE_ACCOUNT env var (free; no Cloud Functions needed).
import admin from 'firebase-admin';

export async function POST(req) {
  try {
    if (!process.env.FIREBASE_SERVICE_ACCOUNT) return Response.json({ skipped: true });
    if (!admin.apps.length) {
      admin.initializeApp({ credential: admin.credential.cert(JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT)) });
    }
    const idToken = (req.headers.get('authorization') || '').replace('Bearer ', '');
    const caller = await admin.auth().verifyIdToken(idToken);
    const me = await admin.firestore().doc(`users/${caller.uid}`).get();
    if (me.data()?.role !== 'Admin') return Response.json({ error: 'forbidden' }, { status: 403 });
    const { uid, title, body } = await req.json();
    const u = await admin.firestore().doc(`users/${uid}`).get();
    const token = u.data()?.fcmToken;
    if (!token) return Response.json({ skipped: 'no token' });
    await admin.messaging().send({ token, notification: { title, body } });
    return Response.json({ ok: true });
  } catch (e) {
    return Response.json({ error: String(e) }, { status: 500 });
  }
}
