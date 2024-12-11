///import 'package:audioplayers/audioplayers.dart';
///
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../user.dart';
import 'image_setting.dart';
import 'music_cubit.dart';
import 'music_setting.dart';

class MusicSessionBoard extends StatelessWidget {
  final User user;
  final User bindUser;

  const MusicSessionBoard(
      {super.key, required this.user, required this.bindUser});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MusicSessionCubit>(
      create: (context) => MusicSessionCubit(user, bindUser)..load(context),
      child: BlocBuilder<MusicSessionCubit, MusicSessionState>(
          builder: (context, state) {
        MusicSessionCubit cubit = BlocProvider.of<MusicSessionCubit>(context);
        //cubit.printLyrics();
        return Scaffold(
          appBar: AppBar(
            iconTheme: const IconThemeData(color: Colors.white),
            title: const Text('Our Time Together ♥',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.pinkAccent,
            actions: [
              PopupMenuButton<String>(
                onSelected: (String value) {
                  // Handle menu selection
                  if (value == 'Image Setting') {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (newContext) => ImageSettingPage(
                            BlocProvider.of<MusicSessionCubit>(context))));
                  } else {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (newContext) => MusicSettingsPage(
                            BlocProvider.of<MusicSessionCubit>(context))));
                  }
                },
                itemBuilder: (BuildContext context) {
                  return {'Image Setting', 'Music Setting'}
                      .map((String choice) {
                    return PopupMenuItem<String>(
                      value: choice,
                      child: Text(choice),
                    );
                  }).toList();
                },
                icon: const Icon(Icons.settings, color: Colors.white),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: BlocBuilder<MusicSessionCubit, MusicSessionState>(
              builder: (context, state) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Picture Memory Area
                  Expanded(
                    child: Center(
                      child: Container(
                        decoration: BoxDecoration(
                          //border: Border.all(color: Colors.pinkAccent, width: 4.0),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: state.isLoading()
                            ? const SizedBox(
                                height: 300,
                                width: 300,
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : CachedNetworkImage(
                                imageUrl: state.images[state.currentImagePos]
                                    .getRealPath(),
                                height: 300,
                                width: 300,
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    const CircularProgressIndicator(),
                              ),
                      ),
                    ),
                  ),
                  //SizedBox(height: 15),
                  // Lyrics Section

                  /*Lyrics Section*/

                  StreamBuilder<Duration?>(
                      stream: state.audioPlayer.durationStream,
                      builder: (context_, durationSnapshot) {
                        final duration = durationSnapshot.data ?? Duration.zero;
                        return StreamBuilder<Duration?>(
                            stream: state.audioPlayer.positionStream,
                            builder: (context, snapshot) {
                              //print('Position: ${snapshot.data}');
                              final position = snapshot.data ?? Duration.zero;
                              final currentLyric =
                                  cubit.getCurrentLyricLine(position);
                              final nextLyric = cubit.getNextLyricLine();
                              final prevLyric = cubit.getPreviousLyricLine();
                              return Column(
                                children: [
                                  Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          prevLyric,
                                          style: TextStyle(
                                              fontSize: 14, color: Colors.grey),
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          currentLyric,
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.pinkAccent,
                                              fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          nextLyric,
                                          style: TextStyle(
                                              fontSize: 14, color: Colors.grey),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  // Music Player Controls make it like 00:00 ========== 00:00
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                        '${position.inMinutes.toString().padLeft(2, '0')}:${position.inSeconds.remainder(60).toString().padLeft(2, '0')}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.pinkAccent,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Expanded(
                                        child: Slider(
                                          value: position.inSeconds.toDouble(),
                                          min: 0.0,
                                          max: duration.inSeconds.toDouble(),
                                          onChanged: (value) {
                                            state.audioPlayer.seek(Duration(
                                                seconds: value.toInt()));
                                          },
                                        ),
                                      ),
                                      Text(
                                        '${duration.inMinutes.toString().padLeft(2, '0')}:${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.pinkAccent,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            });
                      }),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.skip_previous,
                          size: 48,
                          color: Colors.pinkAccent,
                        ),
                        onPressed: () {
                          // Handle previous action
                          cubit.previous();
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          state.audioPlayer.playing
                              ? Icons.pause_circle_filled
                              : Icons.play_circle_filled,
                          size: 64,
                          color: Colors.pinkAccent,
                        ),
                        onPressed: () {
                          // Handle play action
                          if (state.audioPlayer.playing) {
                            cubit.pause();
                          } else {
                            cubit.play();
                          }
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.skip_next,
                          size: 48,
                          color: Colors.pinkAccent,
                        ),
                        onPressed: () {
                          // Handle next action
                          cubit.next();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
