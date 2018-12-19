import 'package:flutter/material.dart';
import 'package:flutter_sidekick/flutter_sidekick.dart';
import '../../../data/classes/unify/contact_group.dart';

class ContactGroupManageContact extends StatelessWidget {
  final List<ContactGroup> source, initial;
  ContactGroupManageContact({this.source, this.initial});

  @override
  Widget build(BuildContext context) {
    for (var _item in initial) {
      if (source.contains(_item)) {
        source.remove(_item);
      }
    }

    // The SidekickTeamBuilder takes in charge the animations and
    // the state management.
    return SidekickTeamBuilder<ContactGroup>(
      // We can set an optional animation duration (defaults to 300ms).
      animationDuration: Duration(milliseconds: 300),

      // We can set a the initial list of the container denoted the 'source'.
      initialSourceList: source,

      // We can also set a the initial list of the container denoted the 'target'.
      initialTargetList: initial,

      // The builder let you build everything you want.
      // The sourceBuilderDelegates and targetBuilderDelegates let you build
      // your container final widgets.
      builder: (context, sourceBuilderDelegates, targetBuilderDelegates) {
        return Scaffold(
          appBar: AppBar(
            title: Text("Contact Groups"),
            actions: <Widget>[
              IconButton(
                tooltip: "Save Groups",
                icon: Icon(Icons.save),
                onPressed: () {
                  var _results = targetBuilderDelegates
                      ?.map((e) => e == null ? null : e.message)
                      ?.toList();
                  Navigator.pop(context, _results);
                },
              ),
            ],
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView(
                children: <Widget>[
                  ConstrainedBox(
                    constraints: BoxConstraints(minHeight: 150.0),
                    child: Wrap(
                      spacing: 4.0,
                      runSpacing: 4.0,
                      // For each target child, there is a targetBuilderDelegate.
                      children: targetBuilderDelegates.map((builderDelegate) {
                        // We build the child using the build method of the delegate.
                        // This is how the Sidekicks are added automatically.
                        return builderDelegate.build(
                          context,
                          GestureDetector(
                            // We can use the builderDelegate.state property
                            // to trigger the move.
                            // The element to move is determined by the message.
                            // So it should be unique.
                            onTap: () => builderDelegate.state
                                .move(builderDelegate.message),
                            child: Bubble(
                              radius: 30.0,
                              fontSize: 12.0,
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Text(
                                  builderDelegate.message.name,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                          // You can set all the properties you would set on
                          // a Sidekick.
                          animationBuilder: (animation) => CurvedAnimation(
                                parent: animation,
                                curve: FlippedCurve(Curves.easeOut),
                              ),
                          flightShuttleBuilder: (
                            context,
                            animation,
                            type,
                            from,
                            to,
                          ) =>
                              buildShuttle(
                                animation,
                                builderDelegate.message.name,
                              ),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(
                    height: 100.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        CircleButton(
                          text: '>',
                          // We have to get the nearest SidekickTeamBuilderState to
                          // trigger a move.
                          // Here we will move all the children for the target container,
                          // to the source container.
                          onPressed: () =>
                              SidekickTeamBuilder.of<ContactGroup>(context)
                                  .moveAll(SidekickFlightDirection.toSource),
                        ),
                        SizedBox(width: 60.0, height: 60.0),
                        CircleButton(
                          text: '<',
                          // We have to get the nearest SidekickTeamBuilderState to
                          // trigger a move.
                          // Here we will move all the children for the source container,
                          // to the target container.
                          onPressed: () =>
                              SidekickTeamBuilder.of<ContactGroup>(context)
                                  .moveAll(SidekickFlightDirection.toTarget),
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: Wrap(
                      spacing: 4.0,
                      runSpacing: 4.0,
                      // For each source child, there is a sourceBuilderDelegate.
                      children: sourceBuilderDelegates.map((builderDelegate) {
                        // We build the child using the build method of the delegate.
                        // This is how the Sidekicks are added automatically.
                        return builderDelegate.build(
                          context,
                          GestureDetector(
                            // We can use the builderDelegate.state property
                            // to trigger the move.
                            // The element to move is determined by the message.
                            // So it should be unique.
                            onTap: () => builderDelegate.state
                                .move(builderDelegate.message),
                            child: Bubble(
                              radius: 50.0,
                              fontSize: 20.0,
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Text(
                                  builderDelegate.message.name,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                          // You can set all the properties you would set on
                          // a Sidekick.
                          animationBuilder: (animation) => CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOut,
                              ),
                          flightShuttleBuilder: (
                            context,
                            animation,
                            type,
                            from,
                            to,
                          ) =>
                              buildShuttle(
                                animation,
                                builderDelegate.message.name,
                              ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildShuttle(
    Animation<double> animation,
    String message,
  ) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, __) {
        return Bubble(
          radius: Tween<double>(begin: 50.0, end: 30.0).evaluate(animation),
          fontSize: Tween<double>(begin: 20.0, end: 12.0).evaluate(animation),
          backgroundColor: ColorTween(begin: Colors.green, end: Colors.blue)
              .evaluate(animation),
          foregroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Text(
              message,
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }
}

class Bubble extends StatelessWidget {
  const Bubble({
    Key key,
    this.child,
    this.backgroundColor,
    this.foregroundColor,
    this.radius,
    this.fontSize,
  }) : super(key: key);

  final Widget child;

  final Color backgroundColor;

  final Color foregroundColor;

  final double radius;

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    TextStyle textStyle =
        theme.primaryTextTheme.subhead.copyWith(color: foregroundColor);
    Color effectiveBackgroundColor = backgroundColor;
    if (effectiveBackgroundColor == null) {
      switch (ThemeData.estimateBrightnessForColor(textStyle.color)) {
        case Brightness.dark:
          effectiveBackgroundColor = theme.primaryColorLight;
          break;
        case Brightness.light:
          effectiveBackgroundColor = theme.primaryColorDark;
          break;
      }
    } else if (foregroundColor == null) {
      switch (ThemeData.estimateBrightnessForColor(backgroundColor)) {
        case Brightness.dark:
          textStyle = textStyle.copyWith(color: theme.primaryColorLight);
          break;
        case Brightness.light:
          textStyle = textStyle.copyWith(color: theme.primaryColorDark);
          break;
      }
    }

    textStyle = textStyle.copyWith(fontSize: fontSize);

    final double diameter = radius * 2;
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: IconTheme(
          data: theme.iconTheme.copyWith(color: textStyle.color),
          child: DefaultTextStyle(
            style: textStyle,
            child: child,
          ),
        ),
      ),
    );
  }
}

class CircleButton extends StatelessWidget {
  CircleButton({
    @required this.text,
    @required this.onPressed,
  });

  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60.0,
      width: 60.0,
      child: RaisedButton(
        child: RotatedBox(quarterTurns: 1, child: Text(text)),
        color: Colors.blue,
        colorBrightness: Brightness.dark,
        shape: CircleBorder(),
        onPressed: onPressed,
      ),
    );
  }
}
