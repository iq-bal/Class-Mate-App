import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'dart:math';
import 'dart:async';

class AudioPlayerWidget extends StatefulWidget {
  final String audioUrl;
  final bool isMe;
  final Duration? duration;
  final List<double>? waveformData;

  const AudioPlayerWidget({
    super.key,
    required this.audioUrl,
    required this.isMe,
    this.duration,
    this.waveformData,
  });

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late FlutterSoundPlayer _audioPlayer;
  bool _isPlaying = false;
  bool _isLoading = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  StreamSubscription<PlaybackDisposition>? _positionSubscription;

  // Default waveform data for visualization
  List<double> get _waveformBars {
    if (widget.waveformData != null && widget.waveformData!.isNotEmpty) {
      return widget.waveformData!;
    }
    // Generate default waveform pattern
    return List.generate(30, (index) {
      final random = Random(index);
      return 0.2 + random.nextDouble() * 0.8;
    });
  }

  @override
  void initState() {
    super.initState();
    _audioPlayer = FlutterSoundPlayer();
    _initializeAudio();
  }

  Future<void> _initializeAudio() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Open the audio player
      await _audioPlayer.openPlayer();

      // Use provided duration if available
      if (widget.duration != null) {
        setState(() {
          _totalDuration = widget.duration!;
        });
      }

    } catch (e) {
      print('Error initializing audio: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _togglePlayPause() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pausePlayer();
        setState(() {
          _isPlaying = false;
        });
      } else {
        // Start playing and listen to progress
        _positionSubscription = _audioPlayer.onProgress!.listen((disposition) {
          if (mounted) {
            setState(() {
              _currentPosition = disposition.position;
              if (disposition.duration != Duration.zero) {
                _totalDuration = disposition.duration;
              }
            });
          }
        });
        
        await _audioPlayer.startPlayer(
          fromURI: widget.audioUrl,
          whenFinished: () {
            if (mounted) {
              setState(() {
                _isPlaying = false;
                _currentPosition = Duration.zero;
              });
              _positionSubscription?.cancel();
            }
          },
        );
        
        setState(() {
          _isPlaying = true;
        });
      }
    } catch (e) {
      print('Error toggling play/pause: $e');
    }
  }

  void _seekToPosition(double value) {
    final position = Duration(milliseconds: (value * _totalDuration.inMilliseconds).round());
    _audioPlayer.seekToPlayer(position);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    if (_audioPlayer.isPlaying) {
      _audioPlayer.stopPlayer();
    }
    _audioPlayer.closePlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = _totalDuration.inMilliseconds > 0
        ? _currentPosition.inMilliseconds / _totalDuration.inMilliseconds
        : 0.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Play/Pause Button
        GestureDetector(
          onTap: _isLoading ? null : _togglePlayPause,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: widget.isMe ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: _isLoading
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        widget.isMe ? Colors.white : Colors.black87,
                      ),
                    ),
                  )
                : Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: widget.isMe ? Colors.white : Colors.black87,
                    size: 20,
                  ),
          ),
        ),
        const SizedBox(width: 8),
        
        // Waveform Visualization
        Expanded(
          child: GestureDetector(
            onTapDown: (details) {
              if (_totalDuration.inMilliseconds > 0) {
                final RenderBox box = context.findRenderObject() as RenderBox;
                final localPosition = box.globalToLocal(details.globalPosition);
                final waveformWidth = box.size.width - 56; // Account for button and padding
                final tapPosition = (localPosition.dx - 56) / waveformWidth;
                if (tapPosition >= 0 && tapPosition <= 1) {
                  _seekToPosition(tapPosition.clamp(0.0, 1.0));
                }
              }
            },
            child: Container(
              height: 32,
              child: CustomPaint(
                painter: WaveformPainter(
                  waveformData: _waveformBars,
                  progress: progress,
                  isMe: widget.isMe,
                ),
                size: Size.infinite,
              ),
            ),
          ),
        ),
        
        const SizedBox(width: 8),
        
        // Duration Text
        Text(
          _isPlaying || _currentPosition.inMilliseconds > 0
              ? _formatDuration(_currentPosition)
              : _formatDuration(_totalDuration),
          style: TextStyle(
            fontSize: 12,
            color: widget.isMe ? Colors.white70 : Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class WaveformPainter extends CustomPainter {
  final List<double> waveformData;
  final double progress;
  final bool isMe;

  WaveformPainter({
    required this.waveformData,
    required this.progress,
    required this.isMe,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.5;

    final playedPaint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.5
      ..color = isMe ? Colors.white : Colors.blue[700]!;

    final unplayedPaint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.5
      ..color = isMe ? Colors.white.withOpacity(0.4) : Colors.grey[500]!;

    final barWidth = size.width / waveformData.length;
    final centerY = size.height / 2;
    final maxBarHeight = size.height * 0.8;

    for (int i = 0; i < waveformData.length; i++) {
      final x = i * barWidth + barWidth / 2;
      final barHeight = waveformData[i] * maxBarHeight;
      final barProgress = (i + 1) / waveformData.length;
      
      // Determine if this bar should be painted as played or unplayed
      final barPaint = barProgress <= progress ? playedPaint : unplayedPaint;
      
      // Draw the bar
      canvas.drawLine(
        Offset(x, centerY - barHeight / 2),
        Offset(x, centerY + barHeight / 2),
        barPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! WaveformPainter ||
           oldDelegate.progress != progress ||
           oldDelegate.waveformData != waveformData ||
           oldDelegate.isMe != isMe;
  }
}