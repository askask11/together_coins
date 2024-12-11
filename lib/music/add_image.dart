import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:rflutter_alert/rflutter_alert.dart';

import '../get_env.dart';
import 'music_cubit.dart';

class AddImageCubit extends Cubit<AddImageState> {
  AddImageCubit() : super(AddImageState(isUploadImageSelected: true));

  void toggleOption(bool isUpload) {
    emit(state.copyWith(isUploadImageSelected: isUpload));
  }

  void updateSelectedList(String newList) {
    emit(state.copyWith(selectedList: newList));
  }
}

class AddImageState {
  final bool isUploadImageSelected;
  final String selectedList;

  AddImageState({this.isUploadImageSelected = false, this.selectedList = ''});

  AddImageState.fromMain(MusicSessionCubit mc)
      : this(selectedList: mc.state.imageLists[0].listId.toString());

  AddImageState copyWith({bool? isUploadImageSelected, String? selectedList}) {
    return AddImageState(
      isUploadImageSelected:
          isUploadImageSelected ?? this.isUploadImageSelected,
      selectedList: selectedList ?? this.selectedList,
    );
  }
}

class AddImagePage extends StatelessWidget {
  final TextEditingController _urlController = TextEditingController();

  //final List<String> imageLists = ['List 1', 'List 2', 'List 3'];
  final MusicSessionCubit musicSessionCubit;

  AddImagePage(this.musicSessionCubit, {super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AddImageCubit(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Add Image'),
          backgroundColor: Colors.pinkAccent,
        ),
        body: Padding(
          padding: const EdgeInsets.all(14.0),
          child: BlocBuilder<AddImageCubit, AddImageState>(
            builder: (context, state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  /*DropdownButton<String>(
                    value: state.selectedList,
                    items: musicSessionCubit.state.imageLists.map((DisplayImageMusicListObj obj) {
                      return DropdownMenuItem<String>(
                        value: obj.listId.toString(),
                        child: Text(obj.listName),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        context.read<AddImageCubit>().updateSelectedList(value);
                      }
                    },
                  ),*/
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<bool>(
                          title: Text('Upload'),
                          value: true,
                          groupValue: state.isUploadImageSelected,
                          onChanged: (value) {
                            if (value != null) {
                              context.read<AddImageCubit>().toggleOption(value);
                            }
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<bool>(
                          title: Text('Enter URL'),
                          value: false,
                          groupValue: state.isUploadImageSelected,
                          onChanged: (value) {
                            if (value != null) {
                              context.read<AddImageCubit>().toggleOption(value);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  if (state.isUploadImageSelected)
                    ElevatedButton.icon(
                      onPressed: () async {
                        // Handle image upload action
                        // Open file picker
                        FilePickerResult? result = await FilePicker.platform
                            .pickFiles(
                                allowMultiple: true, type: FileType.image);
                        if (result == null) {
                          return;
                        }
                        //Show loading alert
                        Alert(
                          context: context,
                          title: "Uploading",
                          content: SizedBox(
                            width: 100,
                            height: 100,
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        ).show();
                        List<String> paths = [];
                        for (var file in result.files) {
                          /*print(file.name);
                          print(file.bytes);
                          print(file.size);
                          print(file.extension);
                          print(file.path);*/
                          //upload file to server
                          //get the file path and add to the selected list
                          if (file.path == null) {
                            continue;
                          }
                          paths.add(file.path!);
                        }
                        //get the file path and add to the selected list
                        //upload to base+/upload
                        var response = await GetEnv.uploadFile(
                            paths.map((e) => File(e)).toList(),musicSessionCubit.state.user.jwtToken);
                        if (response.statusCode != 200) {
                          //show error message
                          if (!context.mounted) {
                            return;
                          }
                          print(response.statusCode);
                          Map<String, dynamic> jsonr = jsonDecode(await response.stream.bytesToString());
                          GetEnv.alert(context, "File upload failed due to ${jsonr["data"]}");
                          return;
                        }

                        //convert response to json
                        final Map<String, dynamic> data =
                            jsonDecode(await response.stream.bytesToString());

                        var pathsUploaded = data["data"];
                        // Add the image URLs to the selected list
                        /*
                        * {
    "external":1,
    "paths":[
        "https://viterbi-web.usc.edu/~gaojohns/fileshare/files/temp/6749e7b4a863d.jpg?33",
        "https://viterbi-web.usc.edu/~gaojohns/fileshare/files/temp/6749e7c944289.jpeg?2"
    ]*/
                        final body = jsonEncode({
                          "external": 1,
                          "paths": pathsUploaded,
                        });
                        //print("selected list is ${state.selectedList}");

                        final response2 = await http.post(
                          Uri.parse(
                              '${GetEnv.getApiBaseUrl()}/playback/image/lists/${musicSessionCubit.state.currentImageListId.toString()}/add_images'),
                          headers: <String, String>{
                            'Content-Type': 'application/json; charset=UTF-8',
                            'Authorization':
                                "Bearer ${musicSessionCubit.state.user.jwtToken}",
                          },
                          body: body,
                        );
                        print("response2 is ${response2.statusCode}");
                        if (!context.mounted) {
                          //print("context is not mounted");
                          return;
                        }
                        if (response2.statusCode != 200) {
                          //show error message
                          print(response2.body);
                          GetEnv.alert(context, "Image submission failed");
                          return;
                        }
                        // Add the image URLs to the selected list
                        Alert(
                          context: context,
                          title: "Success",
                          desc: "Image uploaded successfully",
                        ).show().then((b){
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        });
                        //

                        //Navigator.of(context).pop();
                      },
                      icon: Icon(Icons.upload_file, color: Colors.white),
                      label: Text('Upload Image',
                          style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pinkAccent,
                        padding: EdgeInsets.symmetric(vertical: 15.0),
                      ),
                    ),
                  if (!state.isUploadImageSelected)
                    Column(
                      children: [
                        TextField(
                          controller: _urlController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Image URLs (separated by lines)',
                          ),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            if (_urlController.text.isNotEmpty) {
                              // Add the image URLs to the selected list
                              Navigator.of(context).pop();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pinkAccent,
                            padding: EdgeInsets.symmetric(vertical: 15.0),
                          ),
                          child: Text('Add',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
