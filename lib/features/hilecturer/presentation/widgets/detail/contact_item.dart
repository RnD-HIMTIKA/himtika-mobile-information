import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Buat fitur copy clipboard

class ContactItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const ContactItem({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24), // Jarak antar item
      child: Row(
        children: [
          // 1. KOTAK ICON (Kiri)
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.blue.shade50, // Biru muda banget
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade100),
            ),
            child: Icon(icon, color: Colors.blue, size: 24),
          ),

          const SizedBox(width: 16),

          // 2. TEXT INFO (Tengah)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value, // "040204..."
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label, // "NIDN"
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // 3. TOMBOL COPY (Kanan)
          InkWell(
            onTap: () {
              // Fitur Copy ke Clipboard
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('$label disalin!'),
                    duration: const Duration(seconds: 1)),
              );
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(0),
              child: const Icon(Icons.copy, color: Colors.grey, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
