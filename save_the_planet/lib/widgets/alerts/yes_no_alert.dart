import 'package:flutter/material.dart';
import 'package:savetheplanet/widgets/utils/bound_scale_factor.dart';

class AlertYesNoAlert extends StatelessWidget {
  const AlertYesNoAlert({
    this.title,
    this.body,
    this.yesText,
    this.noText,
    this.onYes,
    this.onNo,
    this.padding,
    this.margin,
    this.hasYes = true,
    this.hasNo = true,
  });

  final String title;
  final String body;
  final String yesText;
  final String noText;
  final VoidCallback onYes;
  final VoidCallback onNo;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final bool hasYes;
  final bool hasNo;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      return Container(
        constraints: constraints,
        color: const Color(0x11000000),
        child: Stack(
          children: <Widget>[
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black, width: 2, style: BorderStyle.solid),
                ),
                child: _buildPage(context),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildPage(BuildContext context) {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          Center(
            child: YesNoAlert(
              title: title,
              body: body,
              yesText: yesText,
              noText: noText,
              onNo: onNo,
              onYes: onYes,
              padding: padding,
              hasYes: hasYes,
              hasNo: hasNo,
            ),
          ),
        ],
      ),
    );
  }
}

class YesNoAlert extends StatelessWidget {
  const YesNoAlert({
    this.title,
    this.body,
    this.yesText,
    this.noText,
    this.onYes,
    this.onNo,
    this.padding,
    this.hasYes = true,
    this.hasNo = true,
  });

  final String title;
  final String body;
  final String yesText;
  final String noText;
  final VoidCallback onYes;
  final VoidCallback onNo;
  final EdgeInsets padding;
  final bool hasYes;
  final bool hasNo;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return BoundScaleFactor(
      maxFactor: 1,
      child: Container(
        padding: padding ?? const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _getTitle(theme),
            _getBody(theme),
            _getButtons(context, theme),
          ],
        ),
      ),
    );
  }

  Widget _getTitle(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        title ?? 'Hey There! Question:',
        style: theme.textTheme.headline5.copyWith(color: Colors.black, fontSize: 40),
      ),
    );
  }

  Widget _getBody(ThemeData theme) {
    return Container(
      child: Text(
        body ?? 'Do you like questions?',
        style: theme.textTheme.bodyText2.copyWith(color: Colors.grey[700], fontSize: 18),
      ),
    );
  }

  Widget _getButtons(BuildContext context, ThemeData theme) {
    final MediaQueryData data = MediaQuery.of(context);

    final List<Widget> children = <Widget>[];
    if (hasNo) {
      children.add(
        _getButton(
          theme,
          noText ?? 'No.',
          onNo ?? () {},
          bgColor: Colors.grey[100],
          fgColor: Colors.grey[800],
          first: true,
          fullWidth: data.size.width < 380,
        ),
      );
    }
    if (hasYes) {
      children.add(
        _getButton(
          theme,
          yesText ?? 'Yes.',
          onYes ?? () {},
          fullWidth: data.size.width < 380,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.only(top: 16),
      width: double.infinity,
      child: Wrap(
        alignment: WrapAlignment.end,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: children,
      ),
    );
  }

  Widget _getButton(
    ThemeData theme,
    String text,
    VoidCallback onTap, {
    Color bgColor,
    Color fgColor,
    bool first = false,
    bool fullWidth = false,
  }) {
    return Container(
      margin: first || fullWidth ? EdgeInsets.zero : const EdgeInsets.only(left: 8),
      child: FlatButton(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          height: null,
          width: fullWidth ? double.infinity : null,
          color: Colors.transparent,
          child: Text(
            text,
            style: (fgColor is Color ? theme.textTheme.button.copyWith(color: fgColor) : theme.textTheme.button).copyWith(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
        onPressed: onTap,
        splashColor: Colors.grey[400],
        color: bgColor ?? Colors.grey[700],
      ),
    );
  }
}
