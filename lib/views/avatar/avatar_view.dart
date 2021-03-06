import 'package:dispatcher/localization.dart';
import 'package:dispatcher/models/models.dart';
import 'package:dispatcher/utils/common_utils.dart';
import 'package:dispatcher/utils/snackbar_utils.dart';
import 'package:dispatcher/views/auth/bloc/bloc.dart';
import 'package:dispatcher/views/avatar/bloc/avatar_bloc.dart';
import 'package:dispatcher/views/avatar/widgets/avatar_display.dart';
import 'package:dispatcher/views/camera/camera_view.dart';
import 'package:dispatcher/widgets/form_button.dart';
import 'package:dispatcher/widgets/spinner.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AvatarView extends StatelessWidget {
  static Route route() => MaterialPageRoute<void>(builder: (_) => AvatarView());

  const AvatarView({
    Key key,
  }) : super(key: key);

  @override
  Widget build(
    BuildContext context,
  ) =>
      BlocProvider<AvatarBloc>(
        create: (BuildContext context) => AvatarBloc(),
        child: AvatarPageView(),
      );
}

class AvatarPageView extends StatefulWidget {
  AvatarPageView({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AvatarPageViewState();
}

class _AvatarPageViewState extends State<AvatarPageView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
              _scaffoldKey.currentState.showSnackBar(buildSnackBar(Message(
                text: AppLocalizations.of(context).avatarUpdated,
                type: MessageType.SUCCESS,
              )));

              context.bloc<AvatarBloc>().add(ClearStorageTaskEventType());
              context.bloc<AuthBloc>().add(LoadUser());
              Navigator.pop(context);
              break;

            case StorageTaskEventType.failure:
              _scaffoldKey.currentState.showSnackBar(buildSnackBar(Message(
                text: AppLocalizations.of(context).avatarFailed,
                type: MessageType.ERROR,
              )));

              context.bloc<AvatarBloc>().add(ClearStorageTaskEventType());
              break;

            default:
              break;
          }
        },
        child: BlocBuilder<AvatarBloc, AvatarState>(
          builder: (
            BuildContext context,
            AvatarState state,
          ) =>
              _buildContent(state),
        ),
      );

  /// Builds the content
  Widget _buildContent(
    AvatarState state,
  ) {
    if (state.filePath != null) {
      List<Widget> children = <Widget>[]..add(_buildAvatarConfirmation());

      if (state.type == StorageTaskEventType.progress) {
        children.add(
          Spinner(
            fill: true,
            message: AppLocalizations.of(context).uploadingPhoto,
          ),
        );
      }

      return Stack(children: filterNullWidgets(children));
    }

    return _buildCameraView();
  }

  /// Builds the avatar confirmation
  Widget _buildAvatarConfirmation() => Scaffold(
        key: _scaffoldKey,
        extendBody: true,
        body: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Align(
            alignment: Alignment.center,
            child: Column(
              children: <Widget>[
                _buildAvatarConfirmationContent(),
              ],
            ),
          ),
        ),
      );

  /// Builds the avatar confirmation content
  Widget _buildAvatarConfirmationContent() => Container(
        padding: const EdgeInsets.only(top: 100.0),
        width: double.infinity,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                top: 10.0,
                bottom: 20.0,
              ),
              child: Text(
                AppLocalizations.of(context).avatarHowsItLike,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18.0,
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: AvatarDisplay(
                filePath: context.bloc<AvatarBloc>().state.filePath,
                avatarRadius: 48.0,
              ),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 5.0),
                    child: FormButton(
                      text: AppLocalizations.of(context).avatarReTake,
                      onPressed: _tapRetake,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 5.0),
                    child: FormButton(
                      text: AppLocalizations.of(context).avatarLikeIt,
                      onPressed: _tapDone,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );

  /// Builds the camera view
  Widget _buildCameraView() => Builder(
        builder: (context) => CameraView(
          saveCallback: (String filePath) => _uploadAvatar(context, filePath),
          closeCallback: () => Navigator.pop(context),
        ),
      );

  /// Handles uploading an avatar
  _uploadAvatar(
    BuildContext context,
    String filePath,
  ) {
    context.bloc<AvatarBloc>().add(SetFilePath(filePath));

    if (filePath == null) {
      _scaffoldKey.currentState.showSnackBar(buildSnackBar(Message(
        text: AppLocalizations.of(context).avatarFailed,
        type: MessageType.ERROR,
      )));
    }
  }

  /// Handles a 'retake' tap
  void _tapRetake() => context.bloc<AvatarBloc>().add(ClearFilePath());

  /// Handles a 'done' tap
  void _tapDone() => context.bloc<AvatarBloc>()
    ..add(SetStorageTaskEventType(StorageTaskEventType.progress))
    ..add(
      Upload(
        context.bloc<AuthBloc>().state.user.identifier,
        context.bloc<AvatarBloc>().state.filePath,
      ),
    );
}
