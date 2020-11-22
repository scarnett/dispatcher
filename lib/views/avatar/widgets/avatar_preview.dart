import 'package:cached_network_image/cached_network_image.dart';
import 'package:dispatcher/localization.dart';
import 'package:dispatcher/models/models.dart';
import 'package:dispatcher/theme.dart';
import 'package:dispatcher/views/avatar/avatar_enums.dart';
import 'package:dispatcher/views/avatar/bloc/avatar_bloc.dart';
import 'package:dispatcher/views/avatar/widgets/avatar_delete_confirm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AvatarPreview extends StatelessWidget {
  final User user;
  final AvatarBloc avatarBloc;

  AvatarPreview({
    this.user,
    this.avatarBloc,
  })  : assert(user != null),
        assert(avatarBloc != null);

  @override
  Widget build(
    BuildContext context,
  ) =>
      BlocProvider<AvatarBloc>.value(
        value: avatarBloc,
        child: BlocListener<AvatarBloc, AvatarState>(
          listener: (
            BuildContext context,
            AvatarState state,
          ) {
            switch (state.deleteStatus) {
              case AvatarDeleteStatus.DELETED:
                Navigator.pop(context);
                break;

              default:
                break;
            }
          },
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  width: 200.0,
                  height: 200.0,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(
                        user.avatar?.thumbUrl,
                      ),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Tooltip(
                    message: AppLocalizations.of(context).avatarDelete,
                    child: CircleAvatar(
                      radius: 20.0,
                      backgroundColor: AppTheme.error,
                      child: IconButton(
                        icon: Icon(Icons.delete),
                        color: Colors.white,
                        iconSize: 20.0,
                        splashRadius: 20.0,
                        onPressed: () async =>
                            await showAvatarDeleteConfirm(context),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Future<void> showAvatarDeleteConfirm(
    BuildContext context,
  ) async =>
      showDialog(
        context: context,
        builder: (BuildContext context) => AvatarDeleteConfirm(
          user: user,
          avatarBloc: avatarBloc,
        ),
      );
}
