import 'package:dispatcher/device/device_viewmodel.dart';
import 'package:dispatcher/device/widgets/device_avatar.dart';
import 'package:dispatcher/localization.dart';
import 'package:dispatcher/model.dart';
import 'package:dispatcher/state.dart';
import 'package:dispatcher/theme.dart';
import 'package:dispatcher/utils/snackbar_utils.dart';
import 'package:dispatcher/views/camera/camera_view.dart';
import 'package:dispatcher/widgets/form_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

class AvatarCameraView extends StatefulWidget {
  AvatarCameraView({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AvatarCameraViewState();
}

class _AvatarCameraViewState extends State<AvatarCameraView> {
  String _filePath;

  @override
  Widget build(
    BuildContext context,
  ) =>
      StoreConnector<AppState, DeviceViewModel>(
        converter: (store) => DeviceViewModel.fromStore(store),
        builder: (_, viewModel) => Scaffold(
          body: _buildContext(viewModel),
        ),
      );

  Widget _buildContext(
    DeviceViewModel viewModel,
  ) {
    if (_filePath != null) {
      return _buildAvatarConfirmation(viewModel);
    }

    return _buildCameraView(viewModel);
  }

  Widget _buildAvatarConfirmation(
    DeviceViewModel viewModel,
  ) =>
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Align(
          alignment: Alignment.center,
          child: Column(
            children: <Widget>[
              _buildAvatarConfirmationContent(viewModel),
            ],
          ),
        ),
      );

  Widget _buildAvatarConfirmationContent(
    DeviceViewModel viewModel,
  ) =>
      Container(
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
              padding: const EdgeInsets.only(bottom: 10.0),
              child: DeviceAvatar(
                user: viewModel.device.user,
                avatarRadius: 48.0,
              ),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 5.0),
                    child: FormButton(
                      color: AppTheme.primary,
                      text: AppLocalizations.of(context).avatarReTake,
                      onPressed: _tapRetake,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 5.0),
                    child: FormButton(
                      color: AppTheme.primary,
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

  Widget _buildCameraView(
    DeviceViewModel viewModel,
  ) =>
      Builder(
        builder: (context) => CameraView(
          saveCallback: (String filePath) =>
              _uploadAvatar(context, viewModel, filePath),
          closeCallback: () => Navigator.pop(context),
        ),
      );

  _uploadAvatar(
    BuildContext context,
    DeviceViewModel viewModel,
    String filePath,
  ) {
    setState(() => _filePath = filePath);

    /*
    viewModel.uploadAvatar(
      viewModel.device.id,
      File(filePath),
      context: context,
    );
    */

    Scaffold.of(context).showSnackBar(buildSnackBar(Message(
      text: AppLocalizations.of(context).avatarUpdated,
      type: MessageType.SUCCESS,
    )));
  }

  void _tapRetake() => setState(() => _filePath = null);

  void _tapDone() => Navigator.pop(context);
}
