import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:lrc/lrc.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

//import 'package:flutter_lyric/lyrics_reader.dart';

import '../get_env.dart';
import '../home/login.dart';
import '../user.dart';

class MusicSessionCubit extends Cubit<MusicSessionState> {
  Timer? timer;

  MusicSessionCubit(User user, User bindUser)
      : super(MusicSessionState(
          user: user,
          bindUser: bindUser,
          audioPlayer: AudioPlayer(),
        ));

  void play() {
    state.audioPlayer.play();
    timer = Timer.periodic(Duration(seconds: 4), (timer) {
      nextImage();
    });
    emit(MusicSessionState.copy(state));
  }

  void pause() {
    state.audioPlayer.pause();
    timer?.cancel();
    timer = null;
    emit(MusicSessionState.copy(state));
  }

  void next() {
    state.audioPlayer.seekToNext();
    emit(MusicSessionState.copy(state));
  }

  void previous() {
    state.audioPlayer.seekToPrevious();
    emit(MusicSessionState.copy(state));
  }

  Future<bool> loadImageFromList(BuildContext context, int listId) async {
    //load image
    state.currentImageListId = listId;
    http.Response response = await http.get(
        Uri.parse(
            "${GetEnv.getApiBaseUrl()}/playback/image/lists/${listId.toString()}/get_images"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${state.user.jwtToken}',
        });
    if (response.statusCode == 200) {
      //parse response as JSON Map
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      final List<dynamic> imagesJson = jsonResponse["data"];
      state.images = imagesJson.map((e) => DisplayImage.fromJson(e)).toList();
      emit(MusicSessionState.copy(state));
      return true;
    } else if (response.statusCode == 403) {
      // Unauthorized//tell user to login again
      //alert fire
      if (!context.mounted) {
        return false;
      }
      Alert(
        context: context,
        title: "Unauthorized",
        desc: "Please login again",
        buttons: [
          DialogButton(
            onPressed: () {
              //keep popping until login page so you don't end up with a looooooong stack of pages
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => LoginPage()),
                (Route<dynamic> route) => false,
              );
            },
            width: 120,
            child: const Text(
              "OK",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ],
      ).show();
    } else {
      //unexpected error
      if (!context.mounted) {
        return false;
      }
      Alert(
        context: context,
        title: "Unexpected Error",
        desc: "Please try again",
        buttons: [
          DialogButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            width: 120,
            child: const Text(
              "OK",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ],
      ).show();
    }
    return false;
  }

  Future<bool> loadImageFromCurrentList(BuildContext context) async {
    return loadImageFromList(context, state.currentImageListId);
  }

  Future<bool> loadMusicFromCurrentList(BuildContext context) async {
    return loadMusicFromList(context, state.currentMusicListId);
  }

  void nextImage() {
    if (state.currentImagePos < state.images.length - 1) {
      state.currentImagePos++;
    } else {
      state.currentImagePos = 0;
    }
    emit(MusicSessionState.copy(state));
  }

  // GET /playback/music/lists/1/get_musics
  // response: 200
  //{
  //     "status": "ok",
  //     "data": [
  //         {
  //             "music_id": 1,
  //             "list_id": 1,
  //             "title": "恋爱频率",
  //             "author": "abc",
  //             "is_external": 1,
  //             "path": "https://viterbi-web.usc.edu/~gaojohns/fileshare/files/temp/6749d9b6405aa.m4a",
  //             "album_path": "album",
  //             "lyric_path": null
  //         }
  //     ]
  // }
  Future<bool> loadMusicFromList(BuildContext context, int listId) async {
    //load music
    state.currentMusicListId = listId;
    http.Response response = await http.get(
        Uri.parse(
            "${GetEnv.getApiBaseUrl()}/playback/music/lists/${listId.toString()}/get_musics"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${state.user.jwtToken}',
        });
    if (response.statusCode == 200) {
      //parse response as JSON Map
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      final List<dynamic> musicsJson = jsonResponse["data"];
      //clear the current music list
      state.musics.clear();
      state.musics = musicsJson.map((e) => DisplayMusic.fromJson(e)).toList();
      //reset the audio player
      state.audioPlayer.setAudioSource(
        ConcatenatingAudioSource(
          children: state.musics
              .map((e) => AudioSource.uri(Uri.parse(e.getRealPath())))
              .toList(),
          useLazyPreparation: true,
        ),
      );
      //when the audio player changes to new music, update the current music position
      /*state.audioPlayer.currentIndexStream.listen((event) {
        state.currentMusicPos = event??0;
        emit(MusicSessionState.copy(state));
      });*/
      state.audioPlayer.seek(Duration.zero, index: 0);
      emit(MusicSessionState.copy(state));
      return true;
    } else if (response.statusCode == 403) {
      // Unauthorized//tell user to login again
      //alert fire
      if (!context.mounted) {
        return false;
      }
      Alert(
        context: context,
        title: "Timed out",
        desc: "Please login again",
        buttons: [
          DialogButton(
            onPressed: () {
              //keep popping until login page so you don't end up with a looooooong stack of pages
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => LoginPage()),
                (Route<dynamic> route) => false,
              );
            },
            width: 120,
            child: const Text(
              "OK",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ],
      ).show();
    } else {
      //unexpected error
      if (!context.mounted) {
        return false;
      }
      Alert(
        context: context,
        title: "Unexpected Error",
        desc: "Please try again",
        buttons: [
          DialogButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            width: 120,
            child: const Text(
              "OK",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ],
      ).show();
    }
    return false;
  }

  void load(BuildContext context) {
    /**
     * Sample response JSON:
     * {
        "status": "ok",
        "data": {
        "image_lists": [
        {
        "list_id": 1,
        "list_name": "Memories",
        "user_id": 1
        }
        ],
        "music_lists": [
        {
        "list_id": 1,
        "list_name": "My Songs",
        "user_id": 1
        }
        ],
        "images_from_list": [
        {
        "image_id": 1,
        "list_id": 1,
        "is_external": 1,
        "path": "https://viterbi-web.usc.edu/~gaojohns/fileshare/files/temp/67442330dd204.jpg"
        },
        {
        "image_id": 2,
        "list_id": 1,
        "is_external": 1,
        "path": "https://viterbi-web.usc.edu/~gaojohns/fileshare/files/temp/67442330dd204.jpg"
        },
        {
        "image_id": 3,
        "list_id": 1,
        "is_external": 1,
        "path": "https://viterbi-web.usc.edu/~gaojohns/fileshare/files/temp/67442b4e87e6d.jpg"
        },
        {
        "image_id": 4,
        "list_id": 1,
        "is_external": 1,
        "path": "https://viterbi-web.usc.edu/~gaojohns/fileshare/files/temp/67442b668591b.jpeg"
        }
        ],
        "musics_from_list": [
        {
        "music_id": 1,
        "list_id": 1,
        "title": "恋爱频率",
        "author": "abc",
        "path": "https://viterbi-web.usc.edu/~gaojohns/fileshare/files/temp/6749d9b6405aa.m4a",
        "album_path": "album",
        "lyric_path": null
        }
        ]
        }
        }
     */
    http.get(Uri.parse("${GetEnv.getApiBaseUrl()}/playback/init_page"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${state.user.jwtToken}',
        }).then((response) {
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final List<dynamic> imageListsJson =
            jsonResponse["data"]["image_lists"];
        final List<dynamic> imagesJson =
            jsonResponse["data"]["images_from_list"];
        final List<dynamic> musicListsJson =
            jsonResponse["data"]["music_lists"];
        final List<dynamic> musicsJson =
            jsonResponse["data"]["musics_from_list"];

        state.imageLists = imageListsJson
            .map((e) => DisplayImageMusicListObj.fromJson(e))
            .toList();
        state.images = imagesJson.map((e) => DisplayImage.fromJson(e)).toList();
        state.musicLists = musicListsJson
            .map((e) => DisplayImageMusicListObj.fromJson(e))
            .toList();
        state.musics = musicsJson.map((e) => DisplayMusic.fromJson(e)).toList();

        //successfully loaded

        //load music list to the audio player
        state.audioPlayer.setAudioSource(
          ConcatenatingAudioSource(
            children: state.musics
                .map((e) => AudioSource.uri(Uri.parse(e.getRealPath())))
                .toList(),
            useLazyPreparation: true,
          ),
        );

        //when the audio player changes to new music, update the current music position
        state.audioPlayer.currentIndexStream.listen((event) {
          print("current music pos: $event");
          state.currentMusicPos = event ?? 0;
          //get the newest lyric
          if (state.musics[event ?? 0].lyricPath != null) {
            http
                .get(Uri.parse(state.musics[event ?? 0].getRealLyricPath()))
                .then((response) {
              if (response.statusCode == 200) {
                Lrc? lrc;
                String utf8Body = utf8.decode(response.bodyBytes);
                //print(utf8Body);
                if (Lrc.isValid(utf8Body)) {
                  lrc = Lrc.parse(utf8Body);
                  //filter out empty lines
                  lrc.lyrics.removeWhere((element) => element.lyrics.isEmpty);
                } else {
                  print("Lyric is not valid");
                }
                state.lyric = lrc;
                state.currentLyricPos = 0;
                emit(MusicSessionState.copy(state));
              } else {
                state.lyric = null;
                print("Lyric did not load");
                emit(MusicSessionState.copy(state));
              }
            });
          } else {
            state.lyric = null;
            print("Lyric is null");
            emit(MusicSessionState.copy(state));
          }
        });

        emit(MusicSessionState.copy(state));
        //print(state);
      } else if (response.statusCode == 403) {
        // Unauthorized//tell user to login again
        //alert fire
        if (!context.mounted) {
          return;
        }
        Alert(
          context: context,
          title: "Timed out",
          desc: "Please login again",
          buttons: [
            DialogButton(
              onPressed: () {
                //keep popping until login page so you don't end up with a looooooong stack of pages
                GetEnv.goLogin(context);
              },
              width: 120,
              child: const Text(
                "OK",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            )
          ],
        ).show();
      } else {
        //unexpected error
        if (!context.mounted) {
          return;
        }
        Alert(
          context: context,
          title: "Unexpected Error",
          desc: "Please try again",
          buttons: [
            DialogButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              width: 120,
              child: const Text(
                "OK",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            )
          ],
        ).show();
      }
    }).catchError((onError) {
      //unexpected error
      if (!context.mounted) {
        return;
      }
      Alert(
        context: context,
        title: "Unexpected Error",
        desc: "Please try again",
        buttons: [
          DialogButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            width: 120,
            child: const Text(
              "OK",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ],
      ).show();
    });
  }

  void changeList(int listId, bool isImage) {
    if (isImage) {
      state.currentImageListId = listId;
    } else {
      state.currentMusicListId = listId;
    }
    emit(MusicSessionState.copy(state));
  }

  void changeImage(int imagePos) {
    state.currentImagePos = imagePos;
    emit(MusicSessionState.copy(state));
  }

  void changeMusic(int musicPos) {
    //print("changing music to $musicPos");
    state.currentMusicPos = musicPos;
    state.audioPlayer.seek(Duration.zero, index: musicPos);
    emit(MusicSessionState.copy(state));
  }

  String getCurrentLyricLine(Duration? duration) {
    if (state.lyric == null) {
      return "欢迎使用音乐播放器";
    }
    if (duration == null) {
      return "";
    }
    //check if we have passed the next line time stamp, if we have, update the current lyric pos forward until the next line timestamp is greater than the current time. Also check if we have passed the last line, if we have, return all the way to line we are at now.
    if (state.currentLyricPos < state.lyric!.lyrics.length - 1) {
      while (state.lyric!.lyrics[state.currentLyricPos].timestamp
              .compareTo(duration) <
          0) {
        state.currentLyricPos++;
        if (state.currentLyricPos >= state.lyric!.lyrics.length - 1) {
          break;
        }
      }

      //check if we are behind the previous line, if we are, update the current lyric pos backward until the previous line timestamp is less than the current time.
      while (state.lyric!.lyrics[state.currentLyricPos].timestamp
              .compareTo(duration) >
          0) {
        state.currentLyricPos--;
        if (state.currentLyricPos <= 0) {
          break;
        }
      }
    }
    return state.lyric!.lyrics[state.currentLyricPos].lyrics;
  }

  String getPreviousLyricLine() {
    if (state.lyric == null) {
      return "";
    }
    if (state.currentLyricPos == 0) {
      return "";
    }
    return state.lyric!.lyrics[state.currentLyricPos - 1].lyrics;
  }

  String getNextLyricLine() {
    if (state.lyric == null) {
      return "";
    }
    if (state.currentLyricPos >= state.lyric!.lyrics.length - 1) {
      return "";
    }
    return state.lyric!.lyrics[state.currentLyricPos + 1].lyrics;
  }

  @override
  Future<void> close() {
    state.audioPlayer.dispose();
    return super.close();
  }

// Music player functions...
}

//enum PlayerState { stopped, playing, paused }

class MusicSessionState {
  User user;
  User bindUser;
  List<DisplayImageMusicListObj> imageLists = [];
  List<DisplayImage> images = [];
  List<DisplayImageMusicListObj> musicLists = [];
  List<DisplayMusic> musics = [];
  int currentImagePos = 0;
  int currentMusicPos = 0;
  int currentImageListId = 1;
  int currentMusicListId = 1;
  Lrc? lyric;
  int currentLyricPos = 0;

  //PlayerState playerState = PlayerState.stopped;
  AudioPlayer audioPlayer = AudioPlayer();

  MusicSessionState(
      {required this.user,
      required this.bindUser,
      this.imageLists = const [],
      this.images = const [],
      this.musicLists = const [],
      this.musics = const [],
      this.currentImagePos = 0,
      this.currentMusicPos = 0,
      this.currentImageListId = 1,
      this.currentMusicListId = 1,
      //this.playerState = PlayerState.stopped,
      required this.audioPlayer,
      this.lyric});

  MusicSessionState.copy(MusicSessionState state)
      : this(
          user: state.user,
          bindUser: state.bindUser,
          imageLists: state.imageLists,
          images: state.images,
          musicLists: state.musicLists,
          musics: state.musics,
          currentImagePos: state.currentImagePos,
          currentMusicPos: state.currentMusicPos,
          //playerState: state.playerState,
          currentImageListId: state.currentImageListId,
          currentMusicListId: state.currentMusicListId,
          audioPlayer: state.audioPlayer,
          lyric: state.lyric,
        );

  bool isLoading() {
    return imageLists.isEmpty &&
        images.isEmpty &&
        musicLists.isEmpty &&
        musics.isEmpty;
  }

  @override
  String toString() {
    return 'MusicSessionState{user: $user, bindUser: $bindUser, imageLists: $imageLists, images: $images, musicLists: $musicLists, musics: $musics, currentImagePos: $currentImagePos, currentMusicPos: $currentMusicPos, playerState: $audioPlayer}';
  }
}

// This file contains the classes for the music list and the music list items
class DisplayImageMusicListObj {
  final int listId;
  final String listName;
  final int userId;

  DisplayImageMusicListObj({
    required this.listId,
    required this.listName,
    required this.userId,
  });

  factory DisplayImageMusicListObj.fromJson(Map<String, dynamic> json) {
    return DisplayImageMusicListObj(
      listId: json['list_id'],
      listName: json['list_name'],
      userId: json['user_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'list_id': listId,
      'list_name': listName,
      'user_id': userId,
    };
  }

  @override
  String toString() {
    return 'DisplayImageMusicListObj{listId: $listId, listName: $listName, userId: $userId}';
  }
}

/*{
                "image_id": 1,
                "list_id": 1,
                "path": "https://viterbi-web.usc.edu/~gaojohns/fileshare/files/temp/67442330dd204.jpg"
            }
 */
//display image class
class DisplayImage {
  final int imageId;
  final int listId;
  final String path;

  DisplayImage({
    required this.imageId,
    required this.listId,
    required this.path,
  });

  factory DisplayImage.fromJson(Map<String, dynamic> json) {
    return DisplayImage(
      imageId: json['image_id'],
      listId: json['list_id'],
      path: json['path'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'image_id': imageId,
      'list_id': listId,
      'path': path,
    };
  }

  String getRealPath() {
    return GetEnv.iePath(path);
  }

  @override
  String toString() {
    return 'DisplayImage{imageId: $imageId, listId: $listId, path: $path}';
  }
}

/**
 * {
    "music_id": 1,
    "list_id": 1,
    "title": "恋爱频率",
    "author": "abc",
    "path": "https://viterbi-web.usc.edu/~gaojohns/fileshare/files/temp/6749d9b6405aa.m4a",
    "album_path": "album",
    "lyric_path": null
    }
 */
class DisplayMusic {
  final int musicId;
  final int listId;
  final String title;
  final String author;
  final String path;
  final String albumPath;
  final String? lyricPath;

  DisplayMusic({
    required this.musicId,
    required this.listId,
    required this.title,
    required this.author,
    required this.path,
    required this.albumPath,
    required this.lyricPath,
  });

  factory DisplayMusic.fromJson(Map<String, dynamic> json) {
    return DisplayMusic(
      musicId: json['music_id'],
      listId: json['list_id'],
      title: json['title'],
      author: json['author'],
      path: json['path'],
      albumPath: json['album_path'],
      lyricPath: json['lyric_path'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'music_id': musicId,
      'list_id': listId,
      'title': title,
      'author': author,
      'path': path,
      'album_path': albumPath,
      'lyric_path': lyricPath,
    };
  }

  String getRealPath() {
    //print(GetEnv.iePath(path));
    return GetEnv.iePath(path);
  }

  String getRealAlbumPath() {
    return GetEnv.iePath(albumPath);
  }

  String getRealLyricPath() {
    return GetEnv.iePath(lyricPath ?? "");
  }

  @override
  String toString() {
    return 'DisplayMusic{musicId: $musicId, listId: $listId, title: $title, author: $author, path: $path, albumPath: $albumPath, lyricPath: $lyricPath}';
  }
}
