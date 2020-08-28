import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:dispatcher/device/device_viewmodel.dart';
import 'package:dispatcher/state.dart';
import 'package:dispatcher/theme.dart';
import 'package:dispatcher/utils/date_utils.dart';
import 'package:dispatcher/widgets/spinner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class CameraView extends StatefulWidget {
  final void Function(String filePath) saveCallback;
  final void Function() closeCallback;

  CameraView({
    Key key,
    this.saveCallback,
    this.closeCallback,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> with TickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  CameraController _controller;
  List<CameraDescription> _cameras;
  int _selectedCamera = 0;

  double min = (pi * -2.0);
  double max = (pi * 2.0);

  @override
  Widget build(
    BuildContext context,
  ) =>
      StoreConnector<AppState, DeviceViewModel>(
        converter: (store) => DeviceViewModel.fromStore(store),
        onInitialBuild: (viewModel) async {
          await _loadCameras();

          CameraDescription camera = _cameras[_selectedCamera];
          _onNewCameraSelected(camera);
        },
        builder: (_, viewModel) => FutureBuilder<List<CameraDescription>>(
          future: availableCameras(),
          builder: (
            BuildContext context,
            AsyncSnapshot<List<CameraDescription>> snapshot,
          ) {
            if (snapshot.hasData) {
              return _createContent(viewModel);
            }

            return Spinner();
          },
        ),
      );

  Future<void> _loadCameras() async {
    WidgetsFlutterBinding.ensureInitialized();
    _cameras = await availableCameras();
  }

  Widget _createContent(
    DeviceViewModel viewModel,
  ) =>
      Column(
        children: <Widget>[
          Expanded(
            child: Container(
              child: Center(
                child: _cameraPreviewWidget(viewModel),
              ),
            ),
          ),
        ],
      );

  Widget _cameraPreviewWidget(
    DeviceViewModel viewModel,
  ) {
    if (_controller.value.isInitialized) {
      List<Widget> children = List<Widget>();
      children
        ..addAll([
          _buildPreview(),
          _buildPreviewOverlays(viewModel),
          _buildCloseButton(),
        ]);

      return Stack(
        children: children,
      );
    }

    return Container();
  }

  Widget _buildCloseButton() => Positioned(
        top: 40.0,
        left: 20.0,
        child: IconButton(
          icon: Icon(
            Icons.close,
            color: AppTheme.hint,
          ),
          onPressed: widget.closeCallback,
        ),
      );

  Widget _buildPreview() {
    final size = MediaQuery.of(context).size;
    final deviceRatio = (size.width / size.height);

    return Transform.scale(
      scale: _controller.value.aspectRatio / deviceRatio,
      child: Center(
        child: AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: CameraPreview(_controller),
        ),
      ),
    );
  }

  Widget _buildPreviewOverlays(
    DeviceViewModel viewModel,
  ) {
    if ((_controller == null) || !_controller.value.isInitialized) {
      return Container();
    }

    return Container(
      height: MediaQuery.of(context).size.height,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          _buildRuleOfThirdsLayer(),
          _buildControls(viewModel),
        ],
      ),
    );
  }

  Widget _buildRuleOfThirdsLayer() => Expanded(
        child: Container(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    _buildRuleOfThirdsCell(0),
                    _buildRuleOfThirdsCell(1),
                    _buildRuleOfThirdsCell(2),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    _buildRuleOfThirdsCell(3),
                    _buildRuleOfThirdsCell(4),
                    _buildRuleOfThirdsCell(5),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    _buildRuleOfThirdsCell(6),
                    _buildRuleOfThirdsCell(7),
                    _buildRuleOfThirdsCell(8),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildControls(
    DeviceViewModel viewModel,
  ) {
    if ((_controller == null) || !_controller.value.isInitialized) {
      // TODO! loading...
      return Container();
    }

    CameraDescription camera =
        (_controller == null) ? null : _controller.description;

    return ClipRect(
      child: Container(
        width: MediaQuery.of(context).size.width,
        color: Colors.black.withOpacity(0.1),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 5.0,
            sigmaY: 5.0,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 20.0,
              horizontal: 20.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                RawMaterialButton(
                  onPressed: () => _tapSelectCamera(context),
                  child: Icon(
                    _getCameraLensIcon(camera),
                    color: Colors.white,
                  ),
                  shape: CircleBorder(),
                  elevation: 0.0,
                  fillColor: Colors.black87,
                  padding: const EdgeInsets.all(10.0),
                ),
                RawMaterialButton(
                  onPressed: () =>
                      (_controller != null) && _controller.value.isInitialized
                          ? _tapTakePicture(viewModel)
                          : null,
                  child: Container(
                    width: 60.0,
                    height: 60.0,
                    child: Stack(
                      children: <Widget>[
                        Icon(
                          Icons.brightness_1,
                          color: Colors.white,
                          size: 60.0,
                        ),
                        Center(
                          child: Icon(
                            Icons.camera,
                            color: AppTheme.primary,
                            size: 50.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  shape: CircleBorder(),
                  elevation: 0.0,
                  fillColor: Colors.black.withOpacity(0.3),
                  padding: const EdgeInsets.all(2.0),
                ),
                RawMaterialButton(
                  onPressed: () => _tapSelectPhoto(viewModel),
                  child: Icon(
                    Icons.add_a_photo,
                    color: Colors.white,
                  ),
                  shape: CircleBorder(),
                  elevation: 0.0,
                  fillColor: Colors.black87,
                  padding: const EdgeInsets.all(10.0),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRuleOfThirdsCell(
    int index,
  ) =>
      Expanded(
        child: Container(
          height: double.infinity,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.black.withOpacity(0.5),
              ),
              right: BorderSide(
                color: (((index + 1) % 3) == 0)
                    ? Colors.transparent
                    : Colors.black.withOpacity(0.5),
              ),
            ),
          ),
        ),
      );

  void _tapSelectCamera(
    context,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        List<Widget> children = <Widget>[];

        for (CameraDescription camera in _cameras) {
          children
            ..add(
              ListTile(
                leading: const Icon(Icons.image),
                title: Text(_getCameraName(camera)),
                onTap: () => _onNewCameraSelected(camera, popNav: true),
              ),
            );
        }

        return Container(
          child: Wrap(
            children: children,
          ),
        );
      },
    );
  }

  void _tapSelectPhoto(
    DeviceViewModel viewModel,
  ) async {
    try {
      final PickedFile image = await _picker.getImage(
        source: ImageSource.gallery,
      );

      if (mounted) {
        _uploadImage(viewModel, image.path);
      }
    } catch (e) {
      // TODO!
    }
  }

  void _tapTakePicture(
    DeviceViewModel viewModel,
  ) async {
    String filePath = await _takePicture('/dispatcher/photos');

    if (mounted) {
      _uploadImage(viewModel, filePath);
    }
  }

  void _uploadImage(
    DeviceViewModel viewModel,
    String filePath,
  ) async {
    if (widget.saveCallback != null) {
      widget.saveCallback(filePath);
    }
  }

  Future<String> _takePicture(
    String folder,
  ) async {
    if (!_controller.value.isInitialized) {
      return null;
    }

    final String timestamp = getNow().millisecondsSinceEpoch.toString();
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}$folder';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/$timestamp.png';

    if (_controller.value.isTakingPicture) {
      return null;
    }

    try {
      await _controller.takePicture(filePath);
    } on CameraException {
      return null;
    }

    return filePath;
  }

  void _onNewCameraSelected(
    CameraDescription camera, {
    bool popNav = false,
  }) async {
    if (_controller != null) {
      await _controller.dispose();
    }

    _controller = CameraController(
      camera,
      ResolutionPreset.max,
      enableAudio: false,
    );

    _controller.addListener(() {
      if (mounted) {
        setState(() {
          // ...
        });
      }

      if (_controller.value.hasError) {
        // TODO! send message action
        // showInSnackBar('Camera error ${_controller.value.errorDescription}');
      }
    });

    try {
      await _controller.initialize();
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (popNav) {
      Navigator.pop(context);
    }
  }

  void _showCameraException(CameraException e) {
    // logger.d('code: ${e.code}, message: ${e.description}');
    // showInSnackBar('Error: ${e.code}\n${e.description}');
  }

  IconData _getCameraLensIcon(
    CameraDescription camera,
  ) {
    switch (camera.lensDirection) {
      case CameraLensDirection.back:
        return Icons.camera_rear;

      case CameraLensDirection.front:
        return Icons.camera_front;

      case CameraLensDirection.external:
        return Icons.camera;
    }

    throw ArgumentError('Unknown lens direction');
  }

  String _getCameraName(
    CameraDescription camera,
  ) {
    switch (camera.lensDirection) {
      case CameraLensDirection.back:
        return 'Back';

      case CameraLensDirection.front:
        return 'Front';

      case CameraLensDirection.external:
        return 'External';
    }

    throw ArgumentError('Unknown camera');
  }
}
