import 'dart:io';
import 'package:camera/camera.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:lifeos_client/features/navigation/presentation/widgets/custom_app_bar.dart';
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

      // Use front camera if available
      final frontCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras!.first,
      );

      _controller = CameraController(
        frontCamera,
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

  void _switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) return;

    final currentCamera = _controller!.description;
    final newCamera = _cameras!.firstWhere(
      (camera) => camera.lensDirection != currentCamera.lensDirection,
      orElse: () => currentCamera,
    );

    await _controller?.dispose();

    _controller = CameraController(
      newCamera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    await _controller!.initialize();

    if (mounted) {
      setState(() {});
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

    return Scaffold(
      headers: [
        CustomAppBar(
          title: 'Take Photo',
          leftActions: [
            AppBarAction(
              icon: HugeIcons.strokeRoundedArrowLeft01,
              tooltip: 'Back',
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
          rightActions: [
            if (_cameras != null && _cameras!.length > 1)
              AppBarAction(
                icon: HugeIcons.strokeRoundedCamera02,
                tooltip: 'Switch Camera',
                onTap: _switchCamera,
              ),
          ],
        ),
      ],
      child: _buildBody(context, colorScheme),
    );
  }

  Widget _buildBody(BuildContext context, ColorScheme colorScheme) {
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
                style: Theme.of(context).typography.small.copyWith(
                      color: colorScheme.mutedForeground,
                    ),
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
        // Camera preview
        Center(
          child: AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: CameraPreview(_controller!),
          ),
        ),

        // Silhouette overlay
        Positioned.fill(
          child: CustomPaint(
            painter: _SilhouettePainter(
              color: colorScheme.foreground.withAlpha(128),
            ),
          ),
        ),

        // Capture button
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Center(
            child: GestureDetector(
              onTap: _isCapturing ? null : _capturePhoto,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorScheme.primary,
                    width: 4,
                  ),
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
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          ),
                        )
                      : null,
                ),
              ),
            ),
          ),
        ),

        // Instructions
        Positioned(
          top: 20,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: colorScheme.background.withAlpha(204),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Position yourself within the silhouette outline',
              style: Theme.of(context).typography.small.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}

class _SilhouettePainter extends CustomPainter {
  final Color color;

  _SilhouettePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    
    // Draw a simple human silhouette outline
    final path = Path();
    
    // Head (circle)
    final headRadius = size.width * 0.08;
    final headY = centerY - size.height * 0.25;
    path.addOval(Rect.fromCircle(
      center: Offset(centerX, headY),
      radius: headRadius,
    ));
    
    // Neck
    final neckTop = headY + headRadius;
    final shoulderY = neckTop + size.height * 0.05;
    
    // Torso
    final shoulderWidth = size.width * 0.25;
    final hipY = shoulderY + size.height * 0.25;
    final hipWidth = size.width * 0.2;
    
    // Body outline
    path.moveTo(centerX - shoulderWidth, shoulderY);
    path.lineTo(centerX - hipWidth, hipY);
    path.lineTo(centerX + hipWidth, hipY);
    path.lineTo(centerX + shoulderWidth, shoulderY);
    
    // Arms
    final armLength = size.height * 0.25;
    path.moveTo(centerX - shoulderWidth, shoulderY);
    path.lineTo(centerX - shoulderWidth - size.width * 0.05, shoulderY + armLength);
    
    path.moveTo(centerX + shoulderWidth, shoulderY);
    path.lineTo(centerX + shoulderWidth + size.width * 0.05, shoulderY + armLength);
    
    // Legs
    final legLength = size.height * 0.3;
    path.moveTo(centerX - hipWidth * 0.5, hipY);
    path.lineTo(centerX - hipWidth * 0.7, hipY + legLength);
    
    path.moveTo(centerX + hipWidth * 0.5, hipY);
    path.lineTo(centerX + hipWidth * 0.7, hipY + legLength);
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
