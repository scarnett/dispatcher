import 'package:contacts_service/contacts_service.dart';
import 'package:dispatcher/theme.dart';
import 'package:dispatcher/utils/shadow_utils.dart';
import 'package:dispatcher/utils/user_utils.dart';
import 'package:dispatcher/widgets/progress.dart';
import 'package:flutter/material.dart';

class ContactAvatar extends StatefulWidget {
  // The contact object
  final Contact contact;

  // The radius of the avatar
  final double avatarRadius;

  ContactAvatar({
    @required this.contact,
    this.avatarRadius: 28.0,
  });

  @override
  _ContactAvatarState createState() => _ContactAvatarState();
}

class _ContactAvatarState extends State<ContactAvatar> {
  @override
  Widget build(
    BuildContext context,
  ) {
    double size = (widget.avatarRadius * 2.0);
    List<Widget> widgets = List<Widget>();

    widgets
      ..add(
        Container(
          width: size,
          height: size,
          child: _buildAvatar(),
          padding: const EdgeInsets.all(2.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(
              Radius.circular(widget.avatarRadius),
            ),
            boxShadow: commonBoxShadow(),
          ),
        ),
      );

    return Stack(
      overflow: Overflow.visible,
      children: widgets,
    );
  }

  /// Builds the avatar widget.
  Widget _buildAvatar() => Container(
      width: (widget.avatarRadius * 2.0),
      height: (widget.avatarRadius * 2.0),
      child: (widget.contact.avatar != null)
          ? _buildImage(widget.avatarRadius)
          : _buildInitials(widget.avatarRadius));

  /// Builds the avatar image if it exists.
  Widget _buildImage(
    double radius,
  ) {
    if ((widget.contact.avatar == null) ||
        (widget.contact.avatar.length == 0)) {
      return Padding(
        padding: const EdgeInsets.all(10.0),
        child: Progress(),
      );
    }

    return CircleAvatar(
      backgroundColor: Colors.white,
      backgroundImage: MemoryImage(widget.contact.avatar),
      radius: radius,
    );
  }

  /// Builds the name initial.
  /// This is used if there is no avatar.
  Widget _buildInitials(
    double radius,
  ) =>
      CircleAvatar(
        backgroundColor: AppTheme.avatar,
        child: Align(
          alignment: Alignment.center,
          child: Text(
            getNameInitials(widget.contact.displayName),
            style: TextStyle(
              fontSize: (radius / 1.5),
              color: Colors.white,
              fontWeight: FontWeight.w700,
              letterSpacing: -2.0,
            ),
          ),
        ),
        radius: radius,
      );
}
