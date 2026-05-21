import 'package:fitnow/common/widgets/appbar/app_bar.dart';
import 'package:fitnow/core/configs/services/notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: BasicAppBar(
        hideBack: true,
        centerTitle: false,
        title: InkWell(
          onTap: () => context.push('/profile'),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.white38,
                  child: Icon(Icons.person, color: Colors.white, size: 20),
                ),
                SizedBox(width: 10),
                Text(
                  'Привет, Александр',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(icon: const Icon(Icons.person_outline), onPressed: () {}),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ElevatedButton(
            onPressed: () {
              NotificationService().showNotification(
                body: "body test",
                title: "test title",
                id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
              );
            },
            child: Text("test push"),
          ),
        ),
      ),
    );
  }
}
