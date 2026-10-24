import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';

class ServiceScreen extends StatefulWidget {
  const ServiceScreen({super.key});
  @override
  State<ServiceScreen> createState() => _ServiceScreenState();
}

class _ServiceScreenState extends State<ServiceScreen> {
  String type = 'Installation';
  final desc = TextEditingController(), addr = TextEditingController();
  DateTime date = DateTime.now().add(const Duration(days: 1));

  @override
  Widget build(BuildContext context) {
    final s = context.read<AppState>();
    return Scaffold(
      appBar: AppBar(title: const Text('Service booking')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        DropdownButtonFormField<String>(
          value: type,
          items: const ['Installation', 'Repair', 'Filter change', 'AMC / Annual service']
              .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (v) => setState(() => type = v!),
          decoration: const InputDecoration(labelText: 'Service type'),
        ),
        TextField(controller: desc, decoration: const InputDecoration(labelText: 'Describe the issue')),
        TextField(controller: addr, decoration: InputDecoration(
            labelText: 'Address', hintText: s.profile?['address'])),
        ListTile(
          title: Text('Preferred date: ${date.toString().substring(0, 10)}'),
          trailing: const Icon(Icons.calendar_today),
          onTap: () async {
            final d = await showDatePicker(context: context, initialDate: date,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 90)));
            if (d != null) setState(() => date = d);
          },
        ),
        FilledButton(
          onPressed: () async {
            await s.bookService(type, desc.text,
                addr.text.isEmpty ? (s.profile?['address'] ?? '') : addr.text, date);
            desc.clear();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Service request sent')));
            }
          },
          child: const Text('Book service'),
        ),
        const Divider(height: 32),
        const Text('My requests', style: TextStyle(fontWeight: FontWeight.bold)),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('services')
              .where('uid', isEqualTo: s.user!.uid).snapshots(),
          builder: (_, snap) => Column(children: [
            for (final d in snap.data?.docs ?? [])
              ListTile(title: Text('${d['type']} · ${d['status']}'),
                  subtitle: Text(d['description'])),
          ]),
        ),
      ]),
    );
  }
}
