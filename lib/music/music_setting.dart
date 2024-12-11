import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../get_env.dart';
import 'add_music.dart';
import 'music_cubit.dart';

class MusicSettingsPage extends StatelessWidget {
  final MusicSessionCubit musicSessionCubit;

  MusicSettingsPage(this.musicSessionCubit, {super.key});

  /*final List<MusicItem> musicList = [
    MusicItem(
      name: "Song One",
      duration: "3:45",
      coverImageUrl: 'https://via.placeholder.com/150/FF0000/FFFFFF',
    ),
    MusicItem(
      name: "Song Two",
      duration: "4:20",
      coverImageUrl: 'https://via.placeholder.com/150/00FF00/FFFFFF',
    ),
    MusicItem(
      name: "Song Three",
      duration: "2:58",
      coverImageUrl: 'https://via.placeholder.com/150/0000FF/FFFFFF',
    ),
    MusicItem(
      name: "Song Four",
      duration: "5:10",
      coverImageUrl: 'https://via.placeholder.com/150/FFFF00/FFFFFF',
    ),
  ];*/

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MusicSessionCubit>.value(
        value: musicSessionCubit,
        child: Scaffold(
            appBar: AppBar(
              title: Text('Music Settings'),
              backgroundColor: Colors.pinkAccent,
            ),
            body: BlocBuilder<MusicSessionCubit, MusicSessionState>(
                builder: (context, state) {
              MusicSessionCubit musicSessionCubit =
                  BlocProvider.of<MusicSessionCubit>(context);
              //print("Music list: ${state.musicLists}");
              //print("Current music list: ${state.currentMusicListId}");
              //print("Current Music Pos ${state.currentMusicPos}");
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: DropdownButton<String>(
                      hint: Text('Select Music List'),
                      value: state.currentMusicListId.toString(),
                      items: state.musicLists
                          .map((list) => DropdownMenuItem<String>(
                                value: list.listId.toString(),
                                child: Text(list.listName),
                              ))
                          .toList(),
                      onChanged: (value) {
                        // Handle dropdown selection change
                        musicSessionCubit.changeList(int.parse(value!), false);
                      },
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: RefreshIndicator(
                        onRefresh: () {
                          return musicSessionCubit
                              .loadMusicFromCurrentList(context);
                        },
                        child: ListView.builder(
                          itemCount: state.musics.length,
                          itemBuilder: (context, index) {
                            final music = state.musics[index];
                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 8.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: ListTile(
                                selected: index == state.currentMusicPos,
                                selectedColor: Colors.pinkAccent,
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: CachedNetworkImage(
                                    imageUrl: GetEnv.iePath(music.albumPath),
                                    height: 50,
                                    width: 50,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => SizedBox(
                                      height: 50,
                                      width: 50,
                                      child: Icon(
                                        Icons.music_note,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        SizedBox(
                                      height: 50,
                                      width: 50,
                                      child: Icon(
                                        Icons.music_note,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                                title: Text(
                                  music.title,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  'Artist: ${music.author}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                onTap: () {
                                  // Handle selecting music
                                  print("Music selected: $index");
                                  musicSessionCubit.changeMusic(index);
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
            //add music button
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => AddMusicPage()));
              },
              child: Icon(Icons.add, color: Colors.white),
              backgroundColor: Colors.pinkAccent,
            )));
  }
}

class MusicItem {
  final String name;
  final String duration;
  final String coverImageUrl;

  MusicItem({
    required this.name,
    required this.duration,
    required this.coverImageUrl,
  });
}
