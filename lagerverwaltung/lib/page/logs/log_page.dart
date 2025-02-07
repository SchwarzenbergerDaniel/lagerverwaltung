import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:lagerverwaltung/config/errormessage_constants.dart';
import 'package:lagerverwaltung/service/localsettings_manager_service.dart';
import 'package:lagerverwaltung/service/logger/log_entry.dart';
import 'package:lagerverwaltung/service/logger/logger_service.dart';
import 'package:lagerverwaltung/service/mailsender/mailsender_service.dart';
import 'package:lagerverwaltung/utils/loading_dialog.dart';
import 'package:lagerverwaltung/widget/custom_leading_button.dart';
import 'package:lagerverwaltung/utils/showsnackbar.dart';

class LogPage extends StatefulWidget {
  const LogPage({super.key});

  @override
  State<LogPage> createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> {
  final loggerService = GetIt.instance<LoggerService>();
  bool isDescending = true;
  late Future<List<LogEntryModel>> futureLogs;
  List<String> relevantLogReasons =
      LogReason.values.map((value) => value.name).toList();
  final mailSenderService = GetIt.instance<MailSenderService>();
  final localSettingsManagerService =
      GetIt.instance<LocalSettingsManagerService>();

  @override
  void initState() {
    super.initState();
    futureLogs = getLogs();
  }

  void sendLogs() async {
    LoadingDialog.showLoadingDialog(
        context, "Aktivitätsliste wird versendet...");

    bool success = await mailSenderService.sendLogs(
        await loggerService.getLogs(),
        localSettingsManagerService.getMail(),
        false);

    LoadingDialog.hideLoadingDialog(context);
    if (success) {
      Showsnackbar.showSnackBar(context,
          "Die Aktivitätsliste wurde an ${localSettingsManagerService.getMail()} versendet!");
    } else {
      Showsnackbar.showSnackBar(context, ErrorMessageConstants.MAIL_FAILED);
    }
  }

  Future<List<LogEntryModel>> getLogs() async {
    final list = await loggerService.getLogs();
    list.sort((left, right) => isDescending
        ? right.timestamp.compareTo(left.timestamp)
        : left.timestamp.compareTo(right.timestamp));

    return list
        .where((log) => relevantLogReasons.contains(log.logReason.name))
        .toList();
  }

  void updateSorting(bool descending) {
    setState(() {
      isDescending = descending;
      futureLogs = getLogs();
    });
  }

  void showLogReasonSelection() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return CupertinoActionSheet(
              title: Text(
                "Filter Logs",
                style: CupertinoTheme.of(context).textTheme.textStyle,
              ),
              actions: LogReason.values.map((reason) {
                final isSelected = relevantLogReasons.contains(reason.name);
                return CupertinoActionSheetAction(
                  onPressed: () {
                    setModalState(() {
                      if (isSelected) {
                        relevantLogReasons.remove(reason.name);
                      } else {
                        relevantLogReasons.add(reason.name);
                      }
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(reason.name.replaceAll('_', ' ')),
                      if (isSelected)
                        const Icon(Icons.check,
                            color: CupertinoColors.activeBlue),
                    ],
                  ),
                );
              }).toList(),
              cancelButton: CupertinoActionSheetAction(
                isDefaultAction: true,
                onPressed: () {
                  setState(() {
                    futureLogs = getLogs();
                  });
                  Navigator.pop(context);
                },
                child: const Text("Fertig"),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Logs'),
        backgroundColor: CupertinoTheme.of(context).barBackgroundColor,
        leading: CustomBackButton(),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          CupertinoSegmentedControl<bool>(
            groupValue: isDescending,
            onValueChanged: updateSorting,
            children: const {
              true: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
                child: Text('Neueste zuerst'),
              ),
              false: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
                child: Text('Älteste zuerst'),
              ),
            },
          ),
          const SizedBox(height: 10),
          CupertinoButton(
            onPressed: showLogReasonSelection,
            child: const Text("Filter Logs"),
          ),
          Expanded(
            child: FutureBuilder<List<LogEntryModel>>(
              future: futureLogs,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CupertinoActivityIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                final logEntries = snapshot.data ?? [];
                return CupertinoScrollbar(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: logEntries.length,
                    itemBuilder: (context, index) {
                      final entry = logEntries[index];
                      return Container(
                        decoration: BoxDecoration(
                            border:
                                Border.all(color: CupertinoColors.systemGrey)),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12.0, top: 15),
                          child: CupertinoListTile(
                            title: Padding(
                              padding: const EdgeInsets.only(bottom: 4.0),
                              child: Text(
                                DateFormat('yyyy-MM-dd HH:mm')
                                    .format(entry.timestamp),
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 4.0),
                                  child: Text(
                                      entry.logReason.name.replaceAll('_', ' '),
                                      style: CupertinoTheme.of(context)
                                          .textTheme
                                          .textStyle),
                                ),
                                if (entry.lagerplatzId != null)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 2.0),
                                    child: Text(
                                        "Lagerplatz: ${entry.lagerplatzId}",
                                        style: const TextStyle(
                                            color: CupertinoColors.systemGrey),
                                        softWrap: true,
                                        overflow: TextOverflow.visible),
                                  ),
                                if (entry.artikelGWID != null)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 2.0),
                                    child: Text("Artikel: ${entry.artikelGWID}",
                                        style: const TextStyle(
                                            color: CupertinoColors.systemGrey),
                                        softWrap: true,
                                        overflow: TextOverflow.visible),
                                  ),
                                if (entry.menge != null)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 2.0),
                                    child: Text("Menge: ${entry.menge}",
                                        style: const TextStyle(
                                            color: CupertinoColors.systemGrey),
                                        softWrap: true,
                                        overflow: TextOverflow.visible),
                                  ),
                                if (entry.neueMenge != null)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 2.0),
                                    child: Text(
                                        "Neue Menge: ${entry.neueMenge}",
                                        style: const TextStyle(
                                            color: CupertinoColors.systemGrey),
                                        softWrap: true,
                                        overflow: TextOverflow.visible),
                                  ),
                                if (entry.zusatzInformationen != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 6.0),
                                    child: Text(
                                      entry.zusatzInformationen!,
                                      style: const TextStyle(
                                          color: CupertinoColors.systemGrey),
                                      softWrap: true,
                                      overflow: TextOverflow.visible,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          CupertinoButton(
            onPressed: sendLogs,
            child: const Text("Logs via Mail versenden"),
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }
}
