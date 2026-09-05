// lib/features/search/presentation/widgets/voice_listening_dialog.dart
// Real-time audio waveform dialog matching Android Google Speech Services
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VoiceListeningDialog extends StatefulWidget {
  final String initialText;
  final double soundLevel;
  final VoidCallback onCancel;

  const VoiceListeningDialog({
    super.key,
    required this.initialText,
    required this.soundLevel,
    required this.onCancel,
  });

  @override
  State<VoiceListeningDialog> createState() => _VoiceListeningDialogState();
}

class _VoiceListeningDialogState extends State<VoiceListeningDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    if (!Platform.environment.containsKey('FLUTTER_TEST')) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Fixed-dimension container (140x140) ensures the modal layout never jumps or jitters
          SizedBox(
            width: 140,
            height: 140,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, _) {
                final normalizedLevel = widget.soundLevel.clamp(0.0, 10.0) / 10.0;
                final animValue = _pulseController.value;

                // Dynamic scale factors clamped strictly within the 140x140 boundary
                final outerScale = 1.0 + (normalizedLevel * 0.25) + (animValue * 0.15);
                final middleScale = 1.0 + (normalizedLevel * 0.15) + (animValue * 0.10);

                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer Ripple Halo
                    Transform.scale(
                      scale: outerScale,
                      child: Container(
                        width: 104,
                        height: 104,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF0C831F).withValues(
                            alpha: (0.10 + (normalizedLevel * 0.12)).clamp(0.05, 0.25),
                          ),
                        ),
                      ),
                    ),

                    // Middle Concentric Ring
                    Transform.scale(
                      scale: middleScale,
                      child: Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF0C831F).withValues(
                            alpha: (0.18 + (normalizedLevel * 0.15)).clamp(0.1, 0.35),
                          ),
                        ),
                      ),
                    ),

                    // Inner Solid Mic Core
                    Container(
                      width: 62,
                      height: 62,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0C831F),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0C831F).withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.mic,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.initialText.isEmpty ? 'Listening…' : widget.initialText,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E1E1E),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Google Speech Services · English (India)',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: widget.onCancel,
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFD32F2F),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
