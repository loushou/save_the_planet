import 'package:flutter/material.dart';
import 'package:savetheplanet/widgets/alerts/yes_no_alert.dart';

class ProtectExit extends StatelessWidget {
  const ProtectExit({
    this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: child,
      onWillPop: () async {
        bool popped = false;
        bool isFirst = false;
        Navigator.of(context, rootNavigator: true).popUntil((Route<dynamic> r) {
          if (popped || r.isFirst) {
            isFirst = !popped && r.isFirst;
            return true;
          }
          if (!r.isFirst) {
            popped = true;
          }
          return false;
        });

        if (isFirst) {
          return (await showDialog(
                context: context,
                builder: (BuildContext context) => AlertYesNoAlert(
                  title: 'Wait, Really?',
                  body: 'Are you sure you want to exit?',
                  noText: 'Yes. Bye.',
                  onNo: () => Navigator.of(context).pop(true),
                  yesText: 'No. Wait!',
                  onYes: () => Navigator.of(context).pop(false),
                  margin: const EdgeInsets.all(20),
                ),
              )) ??
              false;
        }

        return !popped;
      },
    );
  }
}
