import 'package:flutter/material.dart';

import '../controller/logs_controller.dart';
import '../widget/clear_logs_button.dart';
import '../widget/close_logs_button.dart';
import '../widget/logs_filter_bar.dart';
import '../widget/logs_list.dart';
import '../widget/logs_search_field.dart';
import '../widget/logs_title.dart';

/// Composes the inspector screen. It renders no control of its own.
class LogsBody extends StatelessWidget {
  const LogsBody({super.key, required this.controller});

  final LogsController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const CloseLogsButton(),
        title: LogsTitle(controller: controller),
        actions: [ClearLogsButton(controller: controller)],
      ),
      body: Column(
        children: [
          LogsSearchField(controller: controller),
          LogsFilterBar(controller: controller),
          const Divider(height: 1),
          Expanded(child: LogsList(controller: controller)),
        ],
      ),
    );
  }
}
