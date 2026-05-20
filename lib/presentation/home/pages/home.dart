import 'package:fitnow/common/widgets/appbar/app_bar.dart';
import 'package:fitnow/core/configs/services/notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: BasicAppBar(),
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
