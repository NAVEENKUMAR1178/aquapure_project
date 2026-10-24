<<<<<<< HEAD
# AquaPure – E-Commerce Water Purifier App (₹0 stack)

```
app/       Flutter Android app (Customer + Dealer roles)
admin/     Next.js admin panel (deploy to Vercel)
firebase/  Firestore security rules
```
Stack: Flutter · Firebase Auth + Firestore (Spark) · FCM · Razorpay Test · OpenStreetMap · Vercel.
Product images are hosted free by the admin site (`admin/public/images`), so no paid Firebase Storage.

## 1. Firebase (5 min)
1. console.firebase.google.com → new project (Spark plan).
2. Authentication → enable **Email/Password**.
3. Firestore Database → create (production mode) → Rules tab → paste `firebase/firestore.rules` → Publish.
4. Project settings → add **Android app** (package `com.example.aquapure`) → download `google-services.json`
   → put in `app/android/app/`. Also add a **Web app** and copy its config for the admin panel.

## 2. Admin panel on Vercel
```
cd admin
cp .env.example .env.local   # fill NEXT_PUBLIC_FIREBASE_* values
npm install && npm run dev   # test locally
```
Deploy: push `admin/` to GitHub → vercel.com → Import → add the same env vars → Deploy.
(Optional push: add `FIREBASE_SERVICE_ACCOUNT` env var = service account JSON, from Project settings → Service accounts.)
Add your Vercel domain in Firebase → Authentication → Settings → Authorized domains.

**Create the Admin user:** register any account in the Flutter app (or Firebase console → Authentication → Add user),
then in Firestore → `users/{thatUid}` set `role` = `Admin` (and `approved` = true).
Log into the admin site → **Products → Seed 52 sample products**.

## 3. Flutter app
```
cd app
flutter create . --platforms=android --org com.example --project-name aquapure
flutter pub get
```
`flutter create .` generates the android/ folder without touching lib/ or pubspec.yaml.
Then:
- Put `google-services.json` in `android/app/`.
- In `android/settings.gradle(.kts)` add plugin `com.google.gms.google-services` and apply it in `android/app/build.gradle(.kts)`
  (follow the Firebase "Add Firebase SDK" step in the console).
- Set `minSdk` to 21+ (23 if the build asks) in `android/app/build.gradle`.
- Set your Razorpay **test** key in `lib/screens/checkout_screen.dart` (`rzp_test_...`).
```
flutter run
flutter build apk --release
```

## Features
- Customer: 50+ item catalog with search/categories, cart, Razorpay test checkout, order history, service booking, profile + OSM map, FCM token saved.
- Dealer: register as Dealer → pending until admin approves → sees wholesale price (22% off), bulk min qty 5, own order history.
- Admin: orders + status, approve/reject dealers, service desk, edit prices, seed products, push notifications on updates.

## Notes
- Product images are generated placeholders matching each product name. Replace by uploading real photos to Cloudinary/ImgBB and updating `image` in Firestore.
- Email/SMS (EmailJS/TextBee) can be added by calling their REST APIs from `admin/app/api/notify/route.js`.
- Razorpay test mode is client-side only; for production create orders server-side.
=======
# aquapure_project
>>>>>>> 87ebae1aa985fb047ec35f85ef0ebfb7e5f945c2
