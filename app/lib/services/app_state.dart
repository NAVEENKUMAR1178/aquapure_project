import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../models/product.dart';

class AppState extends ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;
  Map<String, dynamic>? profile; // users/{uid}
  final Map<String, CartItem> cart = {};

  User? get user => _auth.currentUser;
  String get role => profile?['role'] ?? 'Customer';
  bool get isDealer => role == 'Dealer';
  bool get dealerApproved => profile?['approved'] == true;
  num get total => cart.values
      .fold(0, (s, c) => s + c.product.priceFor(isDealer) * c.qty);
  int get minDealerQty => 5; // bulk-order rule for dealers

  Future<void> loadProfile() async {
    if (user == null) return;
    final d = await _db.collection('users').doc(user!.uid).get();
    profile = d.data();
    try {
      final t = await FirebaseMessaging.instance.getToken();
      await _db.collection('users').doc(user!.uid).update({'fcmToken': t});
    } catch (_) {}
    notifyListeners();
  }

  Future<void> register(String name, String email, String pass, String phone,
      String role) async {
    final c = await _auth.createUserWithEmailAndPassword(
        email: email, password: pass);
    await _db.collection('users').doc(c.user!.uid).set({
      'name': name, 'email': email, 'phone': phone,
      'role': role, // "Customer" | "Dealer"
      'approved': role == 'Customer', // dealers need admin approval
      'address': '', 'createdAt': FieldValue.serverTimestamp(),
    });
    await loadProfile();
  }

  Future<void> login(String email, String pass) async {
    await _auth.signInWithEmailAndPassword(email: email, password: pass);
    await loadProfile();
  }

  Future<void> logout() async {
    await _auth.signOut();
    profile = null; cart.clear();
    notifyListeners();
  }

  Future<void> saveProfile(String name, String phone, String address) async {
    await _db.collection('users').doc(user!.uid)
        .update({'name': name, 'phone': phone, 'address': address});
    await loadProfile();
  }

  void add(Product p, [int q = 1]) {
    cart.update(p.id, (c) => c..qty += q, ifAbsent: () => CartItem(p, q));
    notifyListeners();
  }

  void setQty(String id, int q) {
    q <= 0 ? cart.remove(id) : cart[id]!.qty = q;
    notifyListeners();
  }

  Future<String> placeOrder(String address, String paymentId) async {
    final ref = await _db.collection('orders').add({
      'uid': user!.uid, 'userName': profile?['name'], 'role': role,
      'items': cart.values.map((c) => {
            'id': c.product.id, 'name': c.product.name, 'qty': c.qty,
            'price': c.product.priceFor(isDealer),
          }).toList(),
      'total': total, 'address': address, 'paymentId': paymentId,
      'status': 'Placed', 'createdAt': FieldValue.serverTimestamp(),
    });
    cart.clear();
    notifyListeners();
    return ref.id;
  }

  Future<void> bookService(String type, String desc, String address,
      DateTime date) =>
      _db.collection('services').add({
        'uid': user!.uid, 'userName': profile?['name'], 'type': type,
        'description': desc, 'address': address,
        'date': Timestamp.fromDate(date), 'status': 'Open',
        'createdAt': FieldValue.serverTimestamp(),
      });
}
