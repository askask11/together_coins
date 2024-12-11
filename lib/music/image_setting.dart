import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'add_image.dart';
import 'music_cubit.dart';

void main0() {
  //databaseFactory = databaseFactoryFfi;
  //runApp(MyApp());
}

/*class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Setting Page',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: ImageSettingPage(),
    );
  }
}*/

Future<bool> refreshImageList(BuildContext context) async {
  final musicSessionCubit = BlocProvider.of<MusicSessionCubit>(context);
  // Load image list
  return musicSessionCubit.loadImageFromCurrentList(context);
}

class ImageSettingPage extends StatelessWidget {
  final MusicSessionCubit musicSessionCubit;

  ImageSettingPage(this.musicSessionCubit, {super.key});

  /*final List<String> imageUrls = [
    'https://viterbi-web.usc.edu/~gaojohns/fileshare/files/temp/67442330dd204.jpg?dd=3wdeee23',
    'https://viterbi-web.usc.edu/~gaojohns/fileshare/files/temp/67442330dd204.jpg?f3=2w233',
    'https://viterbi-web.usc.edu/~gaojohns/fileshare/files/temp/67442b4e87e6d.jpg?fff=f23w23',
    'https://viterbi-web.usc.edu/~gaojohns/fileshare/files/temp/67442b668591b.jpeg?d=2w23',
  ];*/

  @override
  Widget build(BuildContext context) {
    CachedNetworkImage.logLevel = CacheManagerLogLevel.debug;

    return BlocProvider<MusicSessionCubit>.value(
        value: musicSessionCubit,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Image Setting',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.pinkAccent,
            //have a setting button and on click diplay a dropdown menu with option to clear cache
            actions: [
              PopupMenuButton<String>(
                onSelected: (String value) {
                  // Handle menu selection
                  if (value == 'Clear Cache') {
                    // Clear cache
                    clearImageCache(context);
                  }
                },
                itemBuilder: (BuildContext context) {
                  return {'Clear Cache'}.map((String choice) {
                    return PopupMenuItem<String>(
                      value: choice,
                      child: Text(choice),
                    );
                  }).toList();
                },
                icon: Icon(Icons.settings, color: Colors.white),
              ),
            ],
          ),
          body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: BlocBuilder<MusicSessionCubit, MusicSessionState>(
                  builder: (context, state) => Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          DropdownButton<String>(
                            hint: const Text('Select Image List'),
                            value: state.currentImageListId.toString(),
                            items: state.imageLists
                                .map((DisplayImageMusicListObj obj) {
                              return DropdownMenuItem<String>(
                                value: obj.listId.toString(),
                                child: Text(obj.listName),
                              );
                            }).toList(),
                            onChanged: (value) {
                              // Handle dropdown selection change
                              musicSessionCubit.changeList(
                                  int.parse(value!), true);
                            },
                          ),
                          Expanded(
                            child: RefreshIndicator(
                                onRefresh: () => refreshImageList(context),
                                child: GridView.builder(
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 8.0,
                                    mainAxisSpacing: 8.0,
                                    childAspectRatio: 1.0,
                                  ),
                                  itemCount: state.images.length,
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                      onLongPress: () {
                                        // Handle long press to delete image, first confirm with user then do the deletion
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: Text('Delete Image'),
                                              content: Text(
                                                  'Are you sure you want to delete this image?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    // Delete image
                                                    Navigator.of(context).pop();
                                                    //TODO: Implement image deletion
                                                  },
                                                  child: Text('Delete'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      onTap: () {
                                        // Handle tap to select image as main session
                                        musicSessionCubit.changeImage(index);
                                      },
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12.0),
                                              child: CachedNetworkImage(
                                                //color: Colors.pinkAccent,
                                                imageUrl: state.images[index]
                                                    .getRealPath(),
                                                placeholder: (context, url) =>
                                                    const SizedBox(
                                                  width: 10,
                                                  height: 10,
                                                  child:
                                                      CircularProgressIndicator(
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                                Color>(
                                                            Colors.pinkAccent),
                                                  ),
                                                ),
                                                errorWidget: (context, url,
                                                        error) =>
                                                    Icon(Icons.error,
                                                        color:
                                                            Colors.pinkAccent),
                                              ),
                                            ),
                                            //TODO: only show this if the current image is here.
                                            index == state.currentImagePos
                                                ? Align(
                                                    alignment:
                                                        Alignment.bottomCenter,
                                                    child: Container(
                                                      color: Colors.black54,
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 4.0,
                                                              horizontal: 8.0),
                                                      child: Text(
                                                        '👆',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                : SizedBox(),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                )),
                          ),
                        ],
                      ))),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              // Handle add new image action
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (newContext) => AddImagePage(musicSessionCubit)));
            },
            backgroundColor: Colors.pinkAccent,
            child: Icon(Icons.add, color: Colors.white),
          ),
        ));
  }

  void clearImageCache(BuildContext context) async {
    await DefaultCacheManager().emptyCache();
    //alert user that cache has been cleared
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Cache Cleared'),
      duration: Duration(seconds: 2),
    ));
  }
}
