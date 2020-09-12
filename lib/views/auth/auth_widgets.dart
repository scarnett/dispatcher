import 'package:dispatcher/views/auth/auth_enums.dart';
import 'package:flutter/cupertino.dart';
import 'package:supercharged/supercharged.dart';

Widget wrapAuthPage(
  List<Widget> items,
) =>
    LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: IntrinsicHeight(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 20.0,
                right: 20.0,
                bottom: 0.0,
                top: 170.0,
              ),
              child: Column(children: items),
            ),
          ),
        ),
      ),
    );

void moveToPage(
  PageController pageController,
  AuthFormMode formMode, {
  int pageAnimationDuration: 150,
  Cubic pageAnimationCurve: Curves.easeInOut,
}) {
  pageController.animateToPage(
    formMode.pageIndex,
    duration: pageAnimationDuration.milliseconds,
    curve: pageAnimationCurve,
  );
}
