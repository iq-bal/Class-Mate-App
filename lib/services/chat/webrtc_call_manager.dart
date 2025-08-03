import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';

class WebRTCCallManager {
  late IO.Socket socket;
  RTCPeerConnection? peerConnection;
  MediaStream? localStream;
  MediaStream? remoteStream;
  bool isCallActive = false;
  String? callType;
  String? currentCallParticipant;
  
  // Callbacks for UI updates
  Function(MediaStream stream)? onLocalStream;
  Function(MediaStream stream)? onRemoteStream;
  Function(Map<String, dynamic> callData)? onIncomingCall;
  Function()? onCallAccepted;
  Function()? onCallRejected;
  Function()? onCallEnded;
  Function(String error)? onCallError;
  
  // WebRTC configuration
  final Map<String, dynamic> configuration = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun1.l.google.com:19302'},
    ]
  };

  WebRTCCallManager(this.socket) {
    _setupSocketListeners();
  }

  void _setupSocketListeners() {
    socket.on('incomingCall', (data) {
      print('📞 Incoming call from: ${data['from']}');
      _handleIncomingCall(data);
    });

    socket.on('callAccepted', (signalData) {
      print('📞 Call accepted');
      _handleCallAccepted(signalData);
    });

    socket.on('callRejected', (_) {
      print('📞 Call rejected');
      _handleCallRejected();
    });

    socket.on('callEnded', (_) {
      print('📞 Call ended');
      endCall(notifyOther: false);
    });

    socket.on('error', (data) {
      print('📞 Call error: ${data['message']}');
      onCallError?.call(data['message']);
    });
  }

  Future<void> _createPeerConnection() async {
    peerConnection = await createPeerConnection(configuration);
    
    peerConnection!.onTrack = (RTCTrackEvent event) {
      print('📞 Remote stream received');
      remoteStream = event.streams[0];
      onRemoteStream?.call(remoteStream!);
    };

    peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
      print('📞 ICE candidate generated');
      // For simplicity, we're including candidates in offer/answer
      // In production, you might want to send candidates separately
    };

    peerConnection!.onConnectionState = (RTCPeerConnectionState state) {
      print('📞 Connection state: $state');
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateDisconnected ||
          state == RTCPeerConnectionState.RTCPeerConnectionStateFailed) {
        endCall();
      }
    };
  }

  Future<void> initiateCall(String recipientId, String callType) async {
    try {
      print('📞 Initiating $callType call to $recipientId');
      
      this.callType = callType;
      currentCallParticipant = recipientId;
      
      // Request permissions
      await _requestPermissions(callType);
      
      await _createPeerConnection();
      
      // Get user media
      final Map<String, dynamic> constraints = {
        'audio': true,
        'video': callType == 'video',
      };
      
      localStream = await navigator.mediaDevices.getUserMedia(constraints);
      onLocalStream?.call(localStream!);
      
      // Add local stream to peer connection
      localStream!.getTracks().forEach((track) {
        peerConnection!.addTrack(track, localStream!);
      });
      
      // Create offer
      RTCSessionDescription offer = await peerConnection!.createOffer();
      await peerConnection!.setLocalDescription(offer);
      
      // Send call request
      socket.emit('callUser', {
        'to': recipientId,
        'signalData': offer.toMap(),
        'callType': callType,
      });
      
      isCallActive = true;
      print('📞 Call initiated successfully');
      
    } catch (error) {
      print('📞 Error initiating call: $error');
      onCallError?.call('Failed to initiate call: $error');
      _cleanup();
    }
  }

  Future<void> _handleIncomingCall(Map<String, dynamic> data) async {
    try {
      callType = data['callType'];
      currentCallParticipant = data['from'];
      
      // Notify UI about incoming call
      onIncomingCall?.call(data);
      
    } catch (error) {
      print('📞 Error handling incoming call: $error');
      rejectCall(data['from']);
    }
  }

  Future<void> answerCall(Map<String, dynamic> callData) async {
    try {
      print('📞 Answering ${callData['callType']} call from ${callData['from']}');
      
      // Request permissions
      await _requestPermissions(callData['callType']);
      
      await _createPeerConnection();
      
      // Get user media
      final Map<String, dynamic> constraints = {
        'audio': true,
        'video': callData['callType'] == 'video',
      };
      
      localStream = await navigator.mediaDevices.getUserMedia(constraints);
      onLocalStream?.call(localStream!);
      
      // Add local stream to peer connection
      localStream!.getTracks().forEach((track) {
        peerConnection!.addTrack(track, localStream!);
      });
      
      // Set remote description (offer)
      await peerConnection!.setRemoteDescription(
        RTCSessionDescription(
          callData['signalData']['sdp'],
          callData['signalData']['type'],
        ),
      );
      
      // Create answer
      RTCSessionDescription answer = await peerConnection!.createAnswer();
      await peerConnection!.setLocalDescription(answer);
      
      // Send answer
      socket.emit('answerCall', {
        'to': callData['from'],
        'signalData': answer.toMap(),
      });
      
      isCallActive = true;
      onCallAccepted?.call();
      print('📞 Call answered successfully');
      
    } catch (error) {
      print('📞 Error answering call: $error');
      rejectCall(callData['from']);
    }
  }

  Future<void> _handleCallAccepted(Map<String, dynamic> signalData) async {
    try {
      // Set remote description (answer)
      await peerConnection!.setRemoteDescription(
        RTCSessionDescription(
          signalData['sdp'],
          signalData['type'],
        ),
      );
      
      onCallAccepted?.call();
      print('📞 Call connected successfully');
      
    } catch (error) {
      print('📞 Error handling call accepted: $error');
      endCall();
    }
  }

  void rejectCall(String callerId) {
    print('📞 Rejecting call from $callerId');
    socket.emit('rejectCall', {'to': callerId});
    _cleanup();
  }

  void _handleCallRejected() {
    print('📞 Call was rejected');
    onCallRejected?.call();
    _cleanup();
  }

  void endCall({bool notifyOther = true}) {
    print('📞 Ending call');
    
    if (notifyOther && isCallActive && currentCallParticipant != null) {
      socket.emit('endCall', {'to': currentCallParticipant});
    }
    
    onCallEnded?.call();
    _cleanup();
  }

  void _cleanup() {
    print('📞 Cleaning up call resources');
    
    isCallActive = false;
    callType = null;
    currentCallParticipant = null;
    
    // Stop local stream
    localStream?.getTracks().forEach((track) {
      track.stop();
    });
    localStream?.dispose();
    localStream = null;
    
    // Stop remote stream
    remoteStream?.getTracks().forEach((track) {
      track.stop();
    });
    remoteStream?.dispose();
    remoteStream = null;
    
    // Close peer connection
    peerConnection?.close();
    peerConnection = null;
  }

  Future<void> _requestPermissions(String callType) async {
    // Request microphone permission
    var micStatus = await Permission.microphone.request();
    if (!micStatus.isGranted) {
      throw Exception('Microphone permission denied');
    }
    
    // Request camera permission for video calls
    if (callType == 'video') {
      var cameraStatus = await Permission.camera.request();
      if (!cameraStatus.isGranted) {
        throw Exception('Camera permission denied');
      }
    }
  }

  // Call control methods
  void toggleMute() {
    if (localStream != null) {
      final audioTracks = localStream!.getAudioTracks();
      if (audioTracks.isNotEmpty) {
        final audioTrack = audioTracks.first;
        audioTrack.enabled = !audioTrack.enabled;
        print('📞 Audio ${audioTrack.enabled ? "unmuted" : "muted"}');
      }
    }
  }

  void toggleVideo() {
    if (localStream != null && callType == 'video') {
      final videoTracks = localStream!.getVideoTracks();
      if (videoTracks.isNotEmpty) {
        final videoTrack = videoTracks.first;
        videoTrack.enabled = !videoTrack.enabled;
        print('📞 Video ${videoTrack.enabled ? "enabled" : "disabled"}');
      }
    }
  }

  bool get isMuted {
    if (localStream != null) {
      final audioTracks = localStream!.getAudioTracks();
      if (audioTracks.isNotEmpty) {
        return !audioTracks.first.enabled;
      }
    }
    return false;
  }

  bool get isVideoEnabled {
    if (localStream != null && callType == 'video') {
      final videoTracks = localStream!.getVideoTracks();
      if (videoTracks.isNotEmpty) {
        return videoTracks.first.enabled;
      }
    }
    return false;
  }

  void dispose() {
    _cleanup();
  }
}