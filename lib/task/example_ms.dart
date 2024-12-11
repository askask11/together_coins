import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

// Audio Progress Tracker Example
//
// This example demonstrates how to create a simple audio player with a progress
// tracker using the just_audio package.
//

//bro it works on ios but not on mac. it's always

void main() {
  runApp(MaterialApp(home: BufferedProgressBar()));
}

class BufferedProgressBar extends StatefulWidget {
  @override
  _BufferedProgressBarState createState() => _BufferedProgressBarState();
}

class _BufferedProgressBarState extends State<BufferedProgressBar> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _audioPlayer.setUrl(
        "https://viterbi-web.usc.edu/~gaojohns/fileshare/files/perma/ai_de_cheng_bao.wav");
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return "0:00";
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return "$minutes:${seconds.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Buffered Progress Bar")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          StreamBuilder<Duration?>(
            stream: _audioPlayer.positionStream,
            builder: (context, positionSnapshot) {
              final position = positionSnapshot.data ?? Duration.zero;

              return StreamBuilder<Duration?>(
                stream: _audioPlayer.bufferedPositionStream,
                builder: (context, bufferedSnapshot) {
                  final buffered = bufferedSnapshot.data ?? Duration.zero;

                  return StreamBuilder<Duration?>(
                    stream: _audioPlayer.durationStream,
                    builder: (context, durationSnapshot) {
                      final duration = durationSnapshot.data ?? Duration.zero;

                      return Column(
                        children: [
                          // Progress Bar
                          Slider(
                            value: position.inSeconds.toDouble(),
                            max: duration.inSeconds.toDouble(),
                            onChanged: (value) async {
                              await _audioPlayer
                                  .seek(Duration(seconds: value.toInt()));
                            },
                          ),
                          // Buffered Bar
                          LinearProgressIndicator(
                            value: buffered.inMilliseconds /
                                duration.inMilliseconds,
                          ),
                          Text(
                            "${_formatDuration(position)} / ${_formatDuration(duration)}",
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.play_arrow),
                onPressed: () => _audioPlayer.play(),
              ),
              IconButton(
                icon: Icon(Icons.pause),
                onPressed: () => _audioPlayer.pause(),
              ),
              IconButton(
                icon: Icon(Icons.stop),
                onPressed: () => _audioPlayer.stop(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
