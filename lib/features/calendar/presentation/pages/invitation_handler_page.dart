import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:himtika_mobile_information/core/injection_container.dart';
import 'package:himtika_mobile_information/features/calendar/presentation/bloc/invitation/invitation_bloc.dart';
import 'package:himtika_mobile_information/features/calendar/presentation/pages/calendar_screen.dart';
import 'package:himtika_mobile_information/features/home/presentation/pages/home.dart';

class InvitationHandlerPage extends StatelessWidget {
  final String token;
  const InvitationHandlerPage({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<InvitationBloc>()..add(AcceptInvitationByTokenPressed(token)),
      child: BlocListener<InvitationBloc, InvitationState>(
        listener: (context, state) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (state.status == InvitationStatus.actionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Berhasil bergabung ke workspace!'),
                  backgroundColor: Colors.green,
                ),
              );
              // Arahkan ke halaman kalender agar pengguna bisa melihat workspace baru
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const CalendarScreen()),
                (route) => false,
              );
            } else if (state.status == InvitationStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? 'Gagal memproses undangan. Token mungkin sudah tidak valid.'),
                  backgroundColor: Colors.red,
                ),
              );
              // Kembalikan pengguna ke halaman utama jika gagal
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const HomePage()),
                (route) => false,
              );
            }
          });
        },
        child: const Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text('Memproses undangan Anda...'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}