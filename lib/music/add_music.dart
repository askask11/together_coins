import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddMusicPage extends StatelessWidget {
  final TextEditingController _musicUrlController = TextEditingController();
  final TextEditingController _musicNameController = TextEditingController();
  final TextEditingController _lrcContentController = TextEditingController();
  final TextEditingController _albumImageUrlController =
      TextEditingController();
  final List<String> musicLists = ['List 1', 'List 2', 'List 3'];
  String selectedList = 'List 1';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AddMusicCubit(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Add Music', style: TextStyle()),
          backgroundColor: Colors.pinkAccent,
        ),
        body: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: BlocBuilder<AddMusicCubit, AddMusicState>(
            builder: (context, state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButton<String>(
                    dropdownColor: Colors.pinkAccent,
                    value: selectedList,
                    items: musicLists.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: TextStyle()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        selectedList = value;
                      }
                    },
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<bool>(
                          title: Text('Upload Music', style: TextStyle()),
                          value: true,
                          groupValue: state.isUploadMusicSelected,
                          onChanged: (value) {
                            if (value != null) {
                              context.read<AddMusicCubit>().toggleOption(value);
                            }
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<bool>(
                          title: Text('Enter Music URL', style: TextStyle()),
                          value: false,
                          groupValue: state.isUploadMusicSelected,
                          onChanged: (value) {
                            if (value != null) {
                              context.read<AddMusicCubit>().toggleOption(value);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  if (!state.isUploadMusicSelected)
                    TextField(
                      controller: _musicUrlController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Music File URL',
                        labelStyle: TextStyle(),
                      ),
                      style: TextStyle(),
                    ),
                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Handle music upload action
                    },
                    icon: Icon(
                      Icons.upload_file,
                    ),
                    label: Text(
                      state.isUploadMusicSelected
                          ? 'Upload Music'
                          : 'Add Music URL',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pinkAccent,
                      padding: EdgeInsets.symmetric(vertical: 15.0),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _musicNameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Music Name',
                      labelStyle: TextStyle(),
                    ),
                    style: TextStyle(),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _lrcContentController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'LRC Content (lyrics)',
                      labelStyle: TextStyle(),
                    ),
                    style: TextStyle(),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Handle LRC file upload action
                    },
                    icon: Icon(
                      Icons.upload_file,
                    ),
                    label: Text('Upload LRC File'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pinkAccent,
                      padding: EdgeInsets.symmetric(vertical: 15.0),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _albumImageUrlController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Album Image URL',
                      labelStyle: TextStyle(),
                    ),
                    style: TextStyle(),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Handle album image upload action
                    },
                    icon: Icon(
                      Icons.upload_file,
                    ),
                    label: Text('Upload Album Image'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pinkAccent,
                      padding: EdgeInsets.symmetric(vertical: 15.0),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Handle submit action
                    },
                    child: Text('Submit'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pinkAccent,
                      padding: EdgeInsets.symmetric(vertical: 15.0),
                    ),
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

class AddMusicCubit extends Cubit<AddMusicState> {
  AddMusicCubit() : super(AddMusicState(isUploadMusicSelected: true));

  void toggleOption(bool isUpload) {
    emit(state.copyWith(isUploadMusicSelected: isUpload));
  }
}

class AddMusicState {
  final bool isUploadMusicSelected;

  AddMusicState({required this.isUploadMusicSelected});

  AddMusicState copyWith({bool? isUploadMusicSelected}) {
    return AddMusicState(
      isUploadMusicSelected:
          isUploadMusicSelected ?? this.isUploadMusicSelected,
    );
  }
}
