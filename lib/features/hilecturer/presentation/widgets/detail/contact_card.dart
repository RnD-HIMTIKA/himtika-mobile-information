import 'package:flutter/material.dart';
import '../../../data/models/lecturer_model.dart';
import 'contact_item.dart';

class ContactCard extends StatelessWidget {
  final Lecturer lecturer;

  const ContactCard({super.key, required this.lecturer});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 22),
      padding: const EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: 0 // Ubah ini jadi 0 atau 10 sesuai selera
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          ContactItem(
            icon: Icons.badge_outlined,
            label: "NIDN",
            value: lecturer.nidn,
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.grey.shade100, height: 1),
          const SizedBox(height: 16),

          ContactItem(
            icon: Icons.phone_android_outlined,
            label: "No Telp.",
            value: lecturer.phone,
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.grey.shade100, height: 1),
          const SizedBox(height: 16),
          
          ContactItem(
            icon: Icons.email_outlined,
            label: "Email",
            value: lecturer.email,
          ),
        ],
      ),
    );
  }
}
