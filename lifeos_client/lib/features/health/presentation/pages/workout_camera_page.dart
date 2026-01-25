import 'dart:io';
import 'package:camera/camera.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:path/path.dart' as path;

class WorkoutCameraPage extends StatefulWidget {
  const WorkoutCameraPage({super.key});

  @override
  State<WorkoutCameraPage> createState() => _WorkoutCameraPageState();
}

class _WorkoutCameraPageState extends State<WorkoutCameraPage> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isCapturing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        setState(() {
          _errorMessage = 'No cameras found';
        });
        return;
      }

      // Use back camera if available
      final backCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras!.first,
      );

      _controller = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to initialize camera: $e';
      });
    }
  }

  Future<void> _capturePhoto() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    setState(() {
      _isCapturing = true;
    });

    try {
      final image = await _controller!.takePicture();

      // Save to app directory
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = path.join(
        directory.path,
        'workout_photos',
        'workout_$timestamp.jpg',
      );

      // Create directory if it doesn't exist
      final dir = Directory(path.dirname(filePath));
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      // Copy the file
      await File(image.path).copy(filePath);

      if (mounted) {
        Navigator.of(context).pop(filePath);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to capture photo: $e';
        _isCapturing = false;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(child: _buildBody(context, theme, colorScheme));
  }

  Widget _buildBody(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            HugeIcon(
              icon: HugeIcons.strokeRoundedAlert02,
              size: 48,
              color: colorScheme.destructive,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _errorMessage!,
                style: theme.typography.small.copyWith(color: colorScheme.mutedForeground),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      );
    }

    if (!_isInitialized || _controller == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // Camera preview - full screen
        SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _controller!.value.previewSize!.height,
              height: _controller!.value.previewSize!.width,
              child: CameraPreview(_controller!),
            ),
          ),
        ),

        // Silhouette overlay
        Positioned.fill(child: Image.asset("assets/silhouette.png")),

        // Capture button
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Center(
              child: GestureDetector(
                onTap: _isCapturing ? null : _capturePhoto,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: colorScheme.primary, width: 4),
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isCapturing
                          ? colorScheme.mutedForeground
                          : colorScheme.primary,
                    ),
                    child: _isCapturing
                        ? const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : null,
                  ),
                ),
              ),
            ),
          ),
        ),

        // Back button
        Positioned(
          top: 24,
          left: 20,
          child: SafeArea(
            child: IconButton.secondary(
              onPressed: () => Navigator.of(context).pop(),
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedArrowLeft01,
                color: colorScheme.foreground,
                size: 24,
              ),
            ),
          ),
        ),

        // Skip button
        Positioned(
          top: 24,
          right: 20,
          child: SafeArea(
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(''),
              child: Text(
                'Skip',
                style: theme.typography.semiBold.copyWith(
                  color: colorScheme.foreground,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
