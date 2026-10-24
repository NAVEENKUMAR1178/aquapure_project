import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../services/app_state.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});
  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  String q = '', cat = 'All';
  static const cats = ['All', 'Purifiers', 'Dispensers', 'Pumps', 'Filters', 'Spares'];

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(
          title: Text(s.isDealer ? 'Wholesale Catalog' : 'AquaPure Store')),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: TextField(
            decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search), hintText: 'Search products',
                border: OutlineInputBorder()),
            onChanged: (v) => setState(() => q = v.toLowerCase()),
          ),
        ),
        SizedBox(
          height: 44,
          child: ListView(scrollDirection: Axis.horizontal, children: [
            for (final c in cats)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                    label: Text(c), selected: cat == c,
                    onSelected: (_) => setState(() => cat = c)),
              )
          ]),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('products').snapshots(),
            builder: (_, snap) {
              if (!snap.hasData) return const Center(child: CircularProgressIndicator());
              final items = snap.data!.docs
                  .map((d) => Product.fromMap(d.id, d.data() as Map<String, dynamic>))
                  .where((p) => (cat == 'All' || p.category == cat) &&
                      p.name.toLowerCase().contains(q))
                  .toList();
              if (items.isEmpty) return const Center(child: Text('No products. Seed them from the admin panel.'));
              return GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, childAspectRatio: .68,
                    crossAxisSpacing: 8, mainAxisSpacing: 8),
                itemCount: items.length,
                itemBuilder: (_, i) => _Card(items[i]),
              );
            },
          ),
        ),
      ]),
    );
  }
}

class _Card extends StatelessWidget {
  final Product p;
  const _Card(this.p);
  @override
  Widget build(BuildContext context) {
    final s = context.read<AppState>();
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => showModalBottomSheet(
            context: context, isScrollControlled: true,
            builder: (_) => _Detail(p)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: CachedNetworkImage(imageUrl: p.image, fit: BoxFit.cover,
              width: double.infinity,
              errorWidget: (_, __, ___) => const Icon(Icons.water_drop))),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(p.name, maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              Row(children: [
                Text('₹${p.priceFor(s.isDealer)}',
                    style: const TextStyle(fontSize: 16, color: Colors.green,
                        fontWeight: FontWeight.bold)),
                if (s.isDealer) ...[
                  const SizedBox(width: 6),
                  Text('₹${p.price}', style: const TextStyle(
                      decoration: TextDecoration.lineThrough, color: Colors.grey)),
                ],
                const Spacer(),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.add_shopping_cart),
                  onPressed: () {
                    s.add(p, s.isDealer ? s.minDealerQty : 1);
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${p.name} added'),
                            duration: const Duration(seconds: 1)));
                  },
                ),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _Detail extends StatelessWidget {
  final Product p;
  const _Detail(this.p);
  @override
  Widget build(BuildContext context) {
    final s = context.read<AppState>();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        SizedBox(height: 220, child: CachedNetworkImage(imageUrl: p.image)),
        Text(p.name, style: Theme.of(context).textTheme.titleLarge),
        Text(p.description),
        const SizedBox(height: 8),
        Text('Stock: ${p.stock}'),
        if (s.isDealer) Text('Minimum bulk qty: ${s.minDealerQty}'),
        const SizedBox(height: 12),
        FilledButton.icon(
          icon: const Icon(Icons.add_shopping_cart),
          label: Text('Add to cart · ₹${p.priceFor(s.isDealer)}'),
          onPressed: () {
            s.add(p, s.isDealer ? s.minDealerQty : 1);
            Navigator.pop(context);
          },
        ),
      ]),
    );
  }
}
