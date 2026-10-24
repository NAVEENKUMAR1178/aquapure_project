import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final uid = context.read<AppState>().user!.uid;
    return Scaffold(
      appBar: AppBar(title: const Text('Order history')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('orders')
            .where('uid', isEqualTo: uid).snapshots(),
        builder: (_, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snap.data!.docs.toList()
            ..sort((a, b) {
              final x = (a['createdAt'] as Timestamp?)?.millisecondsSinceEpoch ?? 0;
              final y = (b['createdAt'] as Timestamp?)?.millisecondsSinceEpoch ?? 0;
              return y.compareTo(x);
            });
          if (docs.isEmpty) return const Center(child: Text('No orders yet'));
          return ListView(children: [
            for (final d in docs)
              Card(
                margin: const EdgeInsets.all(8),
                child: ExpansionTile(
                  title: Text('₹${d['total']} · ${d['status']}'),
                  subtitle: Text('#${d.id.substring(0, 6)}'),
                  children: [
                    for (final it in d['items'])
                      ListTile(dense: true, title: Text(it['name']),
                          trailing: Text('${it['qty']} × ₹${it['price']}')),
                  ],
                ),
              ),
          ]);
        },
      ),
    );
  }
}
