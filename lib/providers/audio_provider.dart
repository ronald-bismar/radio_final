import 'dart:async';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

class AudioProvider extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _isMuted = false;
  Duration _elapsedTime = Duration.zero;
  Timer? _timer;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  bool get isPlaying => _isPlaying;
  bool get isMuted => _isMuted;
  Duration get elapsedTime => _elapsedTime;

  static const String _url = 'http://stream.zeno.fm/fd9bandxezzuv';

  AudioProvider() {
    _initAudioPlayer();
    _monitorConnectivity();
  }

  Future<void> _initAudioPlayer() async {
    await _audioPlayer.setAudioSource(AudioSource.uri(
      Uri.parse(_url),
      tag: MediaItem(
        id: '1',
        album: "Radio Filadelfia",
        title: "Radio Filadelfia en vivo",
        artUri: Uri.parse(
            "https://www.google.com/imgres?q=centro%20evangelistico%20filadelfia%20filadelfia%20radio%20bolivia&imgurl=https%3A%2F%2Flookaside.fbsbx.com%2Flookaside%2Fcrawler%2Fmedia%2F%3Fmedia_id%3D3081496891942601&imgrefurl=https%3A%2F%2Fwww.facebook.com%2Fgroups%2F301882104168053%2F&docid=UqpNQSDZwBP-IM&tbnid=EKMMaqDrYD7dHM&vet=12ahUKEwiL35iA2reIAxW5E7kGHRQiOG8QM3oECBkQAA..i&w=640&h=640&hcb=2&ved=2ahUKEwiL35iA2reIAxW5E7kGHRQiOG8QM3oECBkQAA"),
      ),
    ));
  }

  Future<void> togglePlay() async {
    _isPlaying = !_isPlaying;
    notifyListeners();
    if (!_isPlaying) {
      _stopTimer();
      await _audioPlayer.pause();
    } else {
      _startTimer();
      await _audioPlayer.play();
    }
  }

  void toggleMute() {
    _isMuted = !_isMuted;
    _audioPlayer.setVolume(_isMuted ? 0.0 : 1.0);
    notifyListeners();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (_isPlaying) {
        _elapsedTime += const Duration(seconds: 1);
        notifyListeners();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void resetTimer() {
    _elapsedTime = Duration.zero;
    notifyListeners();
  }

  void _monitorConnectivity() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      (ConnectivityResult result) async {
        if (result != ConnectivityResult.none && _isPlaying) {
          try {
            if (!_audioPlayer.playing) {
              await _audioPlayer.play();
            }
          } catch (e) {
            log('Error al intentar reconectar: $e');
          }
        }
      },
    );
  }

  @override
  void dispose() {
    _stopTimer();
    _connectivitySubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
}
