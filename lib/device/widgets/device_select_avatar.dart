import 'dart:io';
import 'package:dispatcher/actions.dart';
import 'package:dispatcher/device/device_model.dart';
import 'package:dispatcher/device/device_viewmodel.dart';
import 'package:dispatcher/device/widgets/device_avatar.dart';
import 'package:dispatcher/localization.dart';
import 'package:dispatcher/model.dart';
import 'package:dispatcher/routes.dart';
import 'package:dispatcher/state.dart';
import 'package:dispatcher/theme.dart';
import 'package:dispatcher/utils/common_utils.dart';
import 'package:dispatcher/utils/snackbar_utils.dart';
import 'package:dispatcher/widgets/spinner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:image_picker/image_picker.dart';

/// Displays the avatar selector
class DeviceSelectAvatar extends StatefulWidget {
  final DeviceUser user;
  final int imageQuality;

  DeviceSelectAvatar({
    Key key,
    this.user,
    this.imageQuality: 85,
  }) : super(key: key);

  @override
  _DeviceSelectAvatarState createState() => _DeviceSelectAvatarState();
}

class _DeviceSelectAvatarState extends State<DeviceSelectAvatar> {
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(
    BuildContext context,
  ) =>
      StoreConnector<AppState, DeviceViewModel>(
        converter: (store) => DeviceViewModel.fromStore(store),
        builder: (_, viewModel) => Padding(
          padding: const EdgeInsets.only(
            top: 10.0,
          ),
          child: Stack(
            children: filterNullWidgets(
              _buildContent(viewModel),
            ),
          ),
        ),
      );

  /// Builds the content
  List<Widget> _buildContent(
    DeviceViewModel viewModel,
  ) =>
      [
        Row(
          children: <Widget>[
            DeviceAvatar(user: widget.user),
            Expanded(
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: FlatButton(
                        color: AppTheme.accent,
                        child: Text(AppLocalizations.of(context).takePhoto),
                        onPressed: () => _tapTakePhoto(),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: FlatButton(
                        color: AppTheme.accent,
                        child: Text(AppLocalizations.of(context).selectPhoto),
                        onPressed: () => _tapSelectPhoto(viewModel),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        _buildSpinner(viewModel),
      ];

  /// Builds the busy spinner
  Widget _buildSpinner(
    DeviceViewModel viewModel,
  ) {
    if (viewModel.busy) {
      return Spinner(fill: true);
    }

    return null;
  }

  /// Handles the form 'take photo' tap
  void _tapTakePhoto() => StoreProvider.of<AppState>(context)
      .dispatch(NavigatePushAction(AppRoutes.avatarCamera));

  /// Handles the form 'select photo' tap
  void _tapSelectPhoto(
    DeviceViewModel viewModel,
  ) async {
    try {
      final PickedFile avatarFile = await _picker.getImage(
        source: ImageSource.gallery,
        imageQuality: widget.imageQuality,
      );

      _uploadImage(viewModel, avatarFile);
    } catch (e) {
      // TODO!
    }
  }

  /// Performs the avatar upload
  void _uploadImage(
    DeviceViewModel viewModel,
    PickedFile avatarFile,
  ) {
    viewModel.uploadAvatar(
      viewModel.device.id,
      File(avatarFile.path),
      context: context,
    );

    Scaffold.of(context).showSnackBar(builSnackBar(Message(
      text: AppLocalizations.of(context).avatarUpdated,
      type: MessageType.SUCCESS,
    )));
  }
}
