import 'package:lifeos_client/features/security/presentation/pages/unlock_page.dart';
import 'package:lifeos_client/features/security/presentation/bloc/security_bloc.dart';
import 'package:lifeos_client/features/security/presentation/bloc/security_event.dart';
import 'package:lifeos_client/features/security/presentation/bloc/security_state.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _showUnlock = false;
  bool _unlocked = false;

  @override
  void initState() {
    super.initState();
    _checkSecurity();
  }

  void _checkSecurity() {
    context.read<SecurityBloc>().add(SecurityCheckRequested());
  }

  void _handleUnlocked() {
    setState(() {
      _unlocked = true;
    });
    context.read<SecurityBloc>().add(SecurityUnlockSuccessful());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SecurityBloc, SecurityState>(
      listener: (context, state) {
        if (state is SecurityLocked && !_unlocked) {
          setState(() {
            _showUnlock = true;
          });
        } else if (state is SecuritySettingsLoaded && !state.settings.hasPasscode) {
          setState(() {
            _showUnlock = false;
          });
        } else if (state is SecurityUnlocked) {
          setState(() {
            _showUnlock = false;
            _unlocked = true;
          });
        }
      },
      child: _showUnlock
          ? UnlockPage(onUnlocked: _handleUnlocked)
          : Scaffold(
              child: SafeArea(
                child: Stack(
                  children: [
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.5),
                            duration: Duration(milliseconds: 1500),
                            curve: Curves.easeOutBack,
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: value,
                                child: Opacity(
                                  opacity: (value / 1.5).clamp(0.0, 1.0),
                                  child: child,
                                ),
                              );
                            },
                            child: ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                Theme.of(context).colorScheme.foreground,
                                BlendMode.srcIn,
                              ),
                              child: Image.asset(
                                'assets/logo.png',
                                width: 150,
                                height: 150,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
