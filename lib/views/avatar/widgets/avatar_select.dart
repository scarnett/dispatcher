import 'package:dispatcher/localization.dart';
import 'package:dispatcher/model.dart';
import 'package:dispatcher/models/models.dart';
import 'package:dispatcher/utils/common_utils.dart';
import 'package:dispatcher/utils/snackbar_utils.dart';
import 'package:dispatcher/views/auth/bloc/bloc.dart';
import 'package:dispatcher/views/avatar/avatar_view.dart';
import 'package:dispatcher/views/avatar/bloc/avatar_bloc.dart';
import 'package:dispatcher/views/avatar/widgets/avatar_display.dart';
import 'package:dispatcher/widgets/form_button.dart';
import 'package:dispatcher/widgets/spinner.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

/// Displays the avatar selector
class UserSelectAvatar extends StatelessWidget {
  final User user;
  final int imageQuality;
  final ScaffoldState scaffoldState;

  const UserSelectAvatar({
    Key key,
    this.user,
    this.imageQuality: 85,
    this.scaffoldState,
  }) : super(key: key);

  @override
  Widget build(
    BuildContext context,
  ) =>
      BlocProvider<AvatarBloc>(
        create: (BuildContext context) => AvatarBloc(),
        child: UserSelectAvatarDisplay(
          user: user,
          imageQuality: imageQuality,
          scaffoldState: scaffoldState,
        ),
      );
}

class UserSelectAvatarDisplay extends StatefulWidget {
  final User user;
  final int imageQuality;
  final ScaffoldState scaffoldState;

  UserSelectAvatarDisplay({
    Key key,
    this.user,
    this.imageQuality,
    this.scaffoldState,
  }) : super(key: key);

  @override
  _UserSelectAvatarDisplayState createState() =>
      _UserSelectAvatarDisplayState();
}

class _UserSelectAvatarDisplayState extends State<UserSelectAvatarDisplay> {
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(
    BuildContext context,
  ) =>
      BlocListener<AvatarBloc, AvatarState>(
        listener: (
          BuildContext context,
          AvatarState state,
        ) {
          switch (state.type) {
            case StorageTaskEventType.success:
              if (widget.scaffoldState != null) {
                widget.scaffoldState.showSnackBar(buildSnackBar(Message(
                  text: AppLocalizations.of(context).avatarUpdated,
                  type: MessageType.SUCCESS,
                )));
              }

              context.bloc<AvatarBloc>().add(ClearStorageTaskEventType());
              context.bloc<AuthBloc>().add(LoadUser());
              break;

            case StorageTaskEventType.failure:
              if (widget.scaffoldState != null) {
                widget.scaffoldState.showSnackBar(buildSnackBar(Message(
                  text: AppLocalizations.of(context).avatarFailed,
                  type: MessageType.ERROR,
                )));
              }

              context.bloc<AvatarBloc>().add(ClearStorageTaskEventType());
              break;

            case StorageTaskEventType.progress:
            case StorageTaskEventType.resume:
            case StorageTaskEventType.pause:
            default:
              break;
          }
        },
        child: BlocBuilder<AvatarBloc, AvatarState>(
          builder: (
            BuildContext context,
            AvatarState state,
          ) =>
              Stack(
            children: filterNullWidgets(
              _buildContent(state),
            ),
          ),
        ),
      );

  /// Builds the content
  List<Widget> _buildContent(
    AvatarState state,
  ) =>
      [
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 10.0,
          ),
          child: Row(
            children: <Widget>[
              AvatarDisplay(user: widget.user),
              Expanded(
                child: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 5,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: FormButton(
                          text: AppLocalizations.of(context).takePhoto,
                          onPressed: _tapTakePhoto,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: FormButton(
                          text: AppLocalizations.of(context).selectPhoto,
                          onPressed: _tapSelectPhoto,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        _buildSpinner(state),
      ];

  /// Builds the busy spinner
  Widget _buildSpinner(
    AvatarState state,
  ) {
    switch (state.type) {
      case StorageTaskEventType.progress:
      case StorageTaskEventType.resume:
        return Spinner(fill: true);

      case StorageTaskEventType.pause:
      case StorageTaskEventType.success:
      case StorageTaskEventType.failure:
      default:
        return null;
    }
  }

  /// Handles the form 'take photo' tap
  void _tapTakePhoto() => Navigator.push(context, AvatarView.route());

  /// Handles the form 'select photo' tap
  void _tapSelectPhoto() async {
    try {
      final PickedFile avatarFile = await _picker.getImage(
        source: ImageSource.gallery,
        imageQuality: widget.imageQuality,
      );

      _uploadImage(avatarFile);
    } catch (e) {
      // TODO!
    }
  }

  /// Performs the avatar upload
  void _uploadImage(
    PickedFile avatarFile,
  ) {
    if (avatarFile != null) {
      context.bloc<AvatarBloc>()
        ..add(SetStorageTaskEventType(StorageTaskEventType.progress))
        ..add(
          Upload(
            context.bloc<AuthBloc>().state.user.identifier,
            avatarFile.path,
          ),
        );
    } else {
      widget.scaffoldState.showSnackBar(buildSnackBar(Message(
        text: AppLocalizations.of(context).avatarFailed,
        type: MessageType.ERROR,
      )));
    }
  }
}
