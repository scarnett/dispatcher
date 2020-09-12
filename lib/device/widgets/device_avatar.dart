import 'package:cached_network_image/cached_network_image.dart';
import 'package:dispatcher/device/device_model.dart';
import 'package:dispatcher/theme.dart';
import 'package:dispatcher/utils/shadow_utils.dart';
import 'package:dispatcher/utils/user_utils.dart';
import 'package:flutter/material.dart';

class DeviceAvatar extends StatefulWidget {
  // The user object
  final DeviceUser user;

  // The radius of the avatar
  final double avatarRadius;

  DeviceAvatar({
    @required this.user,
    this.avatarRadius: 36.0,
  });

  @override
  _DeviceAvatarState createState() => _DeviceAvatarState();
}

class _DeviceAvatarState extends State<DeviceAvatar> {
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
      child: (widget.user.avatar != null)
          ? _buildImage(widget.avatarRadius)
          : _buildInitials(widget.avatarRadius));

  /// Builds the avatar image if it exists.
  Widget _buildImage(
    double radius,
  ) {
    if ((widget.user.avatar == null) || (widget.user.avatar.length == 0)) {
      return Padding(
        padding: const EdgeInsets.all(10.0),
        child: CircularProgressIndicator(),
      );
    }

    return CachedNetworkImage(
      imageUrl: widget.user.avatar,
      placeholder: (context, url) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: CircularProgressIndicator(),
      ),
      errorWidget: (context, url, error) => Icon(Icons.error),
      imageBuilder: (context, image) => CircleAvatar(
        backgroundColor: Colors.white,
        backgroundImage: image,
        radius: radius,
      ),
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
            getNameInitials(widget.user.name),
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
