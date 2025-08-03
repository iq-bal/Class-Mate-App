import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../services/chat/webrtc_call_manager.dart';
import '../../controllers/chat/chat_controller.dart';
import '../../config/app_config.dart';

class CallScreen extends StatefulWidget {
  final ChatController chatController;
  final String participantId;
  final String participantName;
  final String? participantProfilePicture;
  final String callType; // 'voice' or 'video'
  final bool isIncoming;
  final Map<String, dynamic>? incomingCallData;

  const CallScreen({
    Key? key,
    required this.chatController,
    required this.participantId,
    required this.participantName,
    this.participantProfilePicture,
    required this.callType,
    this.isIncoming = false,
    this.incomingCallData,
  }) : super(key: key);

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  late WebRTCCallManager callManager;
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  
  bool _isCallConnected = false;
  bool _isMuted = false;
  bool _isVideoEnabled = true;
  bool _isCallEnded = false;
  String _callStatus = 'Connecting...';

  @override
  void initState() {
    super.initState();
    _initializeRenderers();
    _initializeCallManager();
    
    if (widget.isIncoming && widget.incomingCallData != null) {
      _handleIncomingCall();
    } else {
      _initiateCall();
    }
  }

  Future<void> _initializeRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  void _initializeCallManager() {
    callManager = WebRTCCallManager(widget.chatController.socket);
    
    // Set up callbacks
    callManager.onLocalStream = (stream) {
      setState(() {
        _localRenderer.srcObject = stream;
      });
    };
    
    callManager.onRemoteStream = (stream) {
      setState(() {
        _remoteRenderer.srcObject = stream;
        _isCallConnected = true;
        _callStatus = 'Connected';
      });
    };
    
    callManager.onCallAccepted = () {
      setState(() {
        _callStatus = 'Call accepted';
      });
    };
    
    callManager.onCallRejected = () {
      setState(() {
        _callStatus = 'Call rejected';
      });
      _endCall();
    };
    
    callManager.onCallEnded = () {
      _endCall();
    };
    
    callManager.onCallError = (error) {
      setState(() {
        _callStatus = 'Call failed: $error';
      });
      _endCall();
    };
  }

  void _handleIncomingCall() {
    setState(() {
      _callStatus = 'Incoming ${widget.callType} call';
    });
  }

  void _initiateCall() {
    setState(() {
      _callStatus = 'Calling...';
    });
    callManager.initiateCall(widget.participantId, widget.callType);
  }

  void _answerCall() {
    if (widget.incomingCallData != null) {
      callManager.answerCall(widget.incomingCallData!);
    }
  }

  void _rejectCall() {
    callManager.rejectCall(widget.participantId);
    _endCall();
  }

  void _endCall() {
    if (!_isCallEnded) {
      setState(() {
        _isCallEnded = true;
        _callStatus = 'Call ended';
      });
      
      callManager.endCall();
      
      // Navigate back after a short delay
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.of(context).pop();
        }
      });
    }
  }

  void _toggleMute() {
    callManager.toggleMute();
    setState(() {
      _isMuted = callManager.isMuted;
    });
  }

  void _toggleVideo() {
    if (widget.callType == 'video') {
      callManager.toggleVideo();
      setState(() {
        _isVideoEnabled = callManager.isVideoEnabled;
      });
    }
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    callManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Video content
            if (widget.callType == 'video') ..._buildVideoContent(),
            
            // Voice call content
            if (widget.callType == 'voice') ..._buildVoiceContent(),
            
            // Call controls overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildCallControls(),
            ),
            
            // Call status overlay
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: _buildCallStatus(),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildVideoContent() {
    return [
      // Remote video (full screen)
      if (_isCallConnected)
        Positioned.fill(
          child: RTCVideoView(
            _remoteRenderer,
            objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
          ),
        ),
      
      // Local video (small overlay)
      if (_localRenderer.srcObject != null)
        Positioned(
          top: 100,
          right: 20,
          child: Container(
            width: 120,
            height: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: RTCVideoView(
                _localRenderer,
                mirror: true,
                objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
              ),
            ),
          ),
        ),
    ];
  }

  List<Widget> _buildVoiceContent() {
    return [
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Profile picture
            CircleAvatar(
              radius: 80,
              backgroundImage: widget.participantProfilePicture != null
                  ? NetworkImage('${AppConfig.imageServer}${widget.participantProfilePicture}')
                  : null,
              child: widget.participantProfilePicture == null
                  ? Text(
                      widget.participantName.isNotEmpty
                          ? widget.participantName[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 24),
            
            // Participant name
            Text(
              widget.participantName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            
            // Call status
            Text(
              _callStatus,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    ];
  }

  Widget _buildCallStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Text(
            widget.participantName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          Text(
            _callStatus,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallControls() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black54],
        ),
      ),
      child: widget.isIncoming && !_isCallConnected && !_isCallEnded
          ? _buildIncomingCallControls()
          : _buildActiveCallControls(),
    );
  }

  Widget _buildIncomingCallControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Reject call
        _buildControlButton(
          icon: Icons.call_end,
          color: Colors.red,
          onPressed: _rejectCall,
        ),
        
        // Accept call
        _buildControlButton(
          icon: Icons.call,
          color: Colors.green,
          onPressed: _answerCall,
        ),
      ],
    );
  }

  Widget _buildActiveCallControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Mute/Unmute
        _buildControlButton(
          icon: _isMuted ? Icons.mic_off : Icons.mic,
          color: _isMuted ? Colors.red : Colors.white,
          backgroundColor: _isMuted ? Colors.white : Colors.black54,
          onPressed: _toggleMute,
        ),
        
        // End call
        _buildControlButton(
          icon: Icons.call_end,
          color: Colors.white,
          backgroundColor: Colors.red,
          onPressed: _endCall,
        ),
        
        // Video toggle (only for video calls)
        if (widget.callType == 'video')
          _buildControlButton(
            icon: _isVideoEnabled ? Icons.videocam : Icons.videocam_off,
            color: _isVideoEnabled ? Colors.white : Colors.red,
            backgroundColor: _isVideoEnabled ? Colors.black54 : Colors.white,
            onPressed: _toggleVideo,
          ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required Color color,
    Color? backgroundColor,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.black54,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: 32),
        onPressed: onPressed,
        iconSize: 64,
      ),
    );
  }
}