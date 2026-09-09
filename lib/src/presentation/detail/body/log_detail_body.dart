import 'package:flutter/material.dart';

import '../../../model/network_log_entry.dart';
import '../controller/log_detail_controller.dart';
import '../view/log_detail_request_view.dart';
import '../view/log_detail_response_view.dart';
import '../widget/copy_curl_button.dart';
import '../widget/log_detail_tab_button.dart';

/// Composes the detail screen. It renders no control of its own.
class LogDetailBody extends StatelessWidget {
  const LogDetailBody({
    super.key,
    required this.entry,
    required this.controller,
  });

  final NetworkLogEntry entry;
  final LogDetailController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail', style: TextStyle(fontSize: 18)),
        actions: [CopyCurlButton(entry: entry)],
      ),
      body: ValueListenableBuilder<LogDetailTab>(
        valueListenable: controller.tab,
        builder: (_, tab, __) {
          return switch (tab) {
            LogDetailTab.request => LogDetailRequestView(entry: entry),
            LogDetailTab.response => LogDetailResponseView(entry: entry),
          };
        },
      ),
      persistentFooterButtons: [
        Row(
          children: [
            for (final tab in LogDetailTab.values)
              Expanded(
                child: LogDetailTabButton(
                  controller: controller,
                  tab: tab,
                  label: tab == LogDetailTab.response && entry.hasError
                      ? 'ERROR'
                      : tab.label,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
