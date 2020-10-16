import 'package:dispatcher/localization.dart';
import 'package:dispatcher/models/models.dart';
import 'package:dispatcher/theme.dart';
import 'package:dispatcher/views/avatar/avatar_enums.dart';
import 'package:dispatcher/views/avatar/bloc/avatar_bloc.dart';
import 'package:dispatcher/widgets/progress.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AvatarDeleteConfirm extends StatelessWidget {
  final User user;
  final AvatarBloc avatarBloc;

  AvatarDeleteConfirm({
    this.user,
    this.avatarBloc,
  })  : assert(user != null),
        assert(avatarBloc != null);

  @override
  Widget build(
    BuildContext context,
  ) {
    AppLocalizations i18n = AppLocalizations.of(context);

    return BlocProvider<AvatarBloc>.value(
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
        child: AlertDialog(
          title: Text(i18n.avatarDelete),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(i18n.avatarDeleteConfirm),
              (avatarBloc.state.deleteStatus == AvatarDeleteStatus.CANT_DELETE)
                  ? Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Text(
                        i18n.avatarDeleteError,
                        style: TextStyle(
                          color: AppTheme.error,
                        ),
                      ),
                    )
                  : Container()
            ],
          ),
          actions:
              (avatarBloc.state.deleteStatus == AvatarDeleteStatus.DELETING)
                  ? [Progress(size: 20.0, strokeWidth: 2.0)]
                  : [
                      FlatButton(
                        color: AppTheme.hint,
                        child: (avatarBloc.state.deleteStatus ==
                                AvatarDeleteStatus.CANT_DELETE)
                            ? Text(i18n.cancel)
                            : Text(i18n.no),
                        onPressed: () => Navigator.pop(context),
                      ),
                      FlatButton(
                        color: AppTheme.primary,
                        child: (avatarBloc.state.deleteStatus ==
                                AvatarDeleteStatus.CANT_DELETE)
                            ? Text(i18n.tryAgain)
                            : Text(i18n.yes),
                        onPressed: () => avatarBloc.add(
                          DeleteAvatar(user.identifier, user.avatar),
                        ),
                      ),
                    ],
        ),
      ),
    );
  }
}
