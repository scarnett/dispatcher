import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dispatcher/models/models.dart';
import 'package:dispatcher/theme.dart';
import 'package:dispatcher/utils/shadow_utils.dart';
import 'package:dispatcher/utils/user_utils.dart';
import 'package:dispatcher/widgets/progress.dart';
import 'package:flutter/material.dart';

class AvatarDisplay extends StatefulWidget {
  // The user object
  final User user;

  // The image url
  final String imageUrl;

  // The image file path
  final String filePath;

  // The display name
  final String displayName;

  // The radius of the avatar
  final double avatarRadius;

  AvatarDisplay({
    this.user,
    this.imageUrl,
    this.filePath,
    this.displayName,
    this.avatarRadius: 36.0,
  });

  @override
  _AvatarDisplayState createState() => _AvatarDisplayState();
}

class _AvatarDisplayState extends State<AvatarDisplay> {
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
      child: ((getImageUrl() != null) || (widget.filePath != null))
          ? _buildImage(widget.avatarRadius)
          : _buildInitials(widget.avatarRadius));

  /// Builds the avatar image if it exists.
  Widget _buildImage(
    double radius,
  ) {
    String imageUrl = getImageUrl();
    if ((imageUrl == null) || (imageUrl.length == 0)) {
      if (widget.filePath != null) {
        return CircleAvatar(
          backgroundColor: Colors.white,
          backgroundImage: FileImage(File(widget.filePath)),
          radius: radius,
        );
      }

      return Padding(
        padding: const EdgeInsets.all(6.0),
        child: Icon(
          Icons.face,
          size: (widget.avatarRadius * 1.5),
          color: AppTheme.accent,
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      placeholder: (
        BuildContext context,
        String url,
      ) =>
          Padding(
        padding: const EdgeInsets.all(20.0),
        child: Progress(),
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
            getNameInitials(getDisplayName()),
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

  /// Gets the image url
  String getImageUrl() {
    String imageUrl;

    if (widget.user != null) {
      imageUrl = widget.user.avatar?.url;
    } else {
      imageUrl = widget.imageUrl;
    }

    return imageUrl;
  }

  /// Gets the display name
  String getDisplayName() {
    String displayName;

    if (widget.user != null) {
      displayName = widget.user.name;
    } else {
      displayName = widget.displayName;
    }

    return displayName;
  }
}