import 'package:dispatcher/device/device_utils.dart';
import 'package:dispatcher/device/device_viewmodel.dart';
import 'package:dispatcher/state.dart';
import 'package:dispatcher/widgets/spinner.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

class LandingView extends StatefulWidget {
  LandingView({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LandingViewState();
}

class _LandingViewState extends State<LandingView> {
  bool _loadedDevice = false;
  bool _requestedConnections = false;

  @override
  Widget build(
    BuildContext context,
  ) =>
      StoreConnector<AppState, DeviceViewModel>(
        converter: (store) => DeviceViewModel.fromStore(store),
        onInitialBuild: (viewModel) async {
          String deviceId = await getDeviceId();

          if ((viewModel.device == null) ||
              (viewModel.device.publicKey == null)) {
            viewModel.registerDevice(deviceId);
          } else {
            viewModel.requestDevice(deviceId);
          }
        },
        onDidChange: (viewModel) {
          // Loads the data from the device collections and redirects afterwards
          if (!_loadedDevice && (viewModel.device?.id != null)) {
            if (!_loadedDevice && !_requestedConnections) {
              viewModel.requestDeviceConnections(viewModel.device.id);
              setState(() => _requestedConnections = true);
            } else if (_requestedConnections) {
              setState(() => _loadedDevice = true);
              viewModel.loadedDevice();
            }
          }
        },
        builder: (_, viewModel) => Scaffold(
          body: Spinner(),
        ),
      );
}
