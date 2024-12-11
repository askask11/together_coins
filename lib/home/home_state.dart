import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:together_coins/get_env.dart';

import '../user.dart';

class HomeState {
  //User user;
  TextEditingController textEditingController;
  User user;
  User bindUser;

  HomeState(
      {required this.textEditingController,
      required this.user,
      required this.bindUser});

  HomeState.init(User user, User binduser)
      : this(
            textEditingController: TextEditingController(),
            user: user,
            bindUser: binduser);

  HomeState.copy(HomeState s)
      : this(
            textEditingController: s.textEditingController,
            user: s.user,
            bindUser: s.bindUser);
}

class HomeCubic extends Cubit<HomeState> {
  HomeCubic(User user, User bindUser) : super(HomeState.init(user, bindUser));

  void updateText(String text) {
    emit(HomeState.copy(state)..textEditingController.text = text);
  }

  Future<bool> loadCoins() async {
    var resp = await http
        .get(Uri.parse("${GetEnv.getApiBaseUrl()}/user/getCoins"), headers: {
      "Authorization": "Bearer ${state.user.jwtToken}",
      "Content-Type": "application/json"
    });
    if (resp.statusCode != 200) {
      //print("failed to get coins");
      return false;
    }
    Map<String, dynamic> data = jsonDecode(resp.body);
    state.user.coinBalance = data["data"]["coin_balance"];
    //print("coin balance is ${state.user.coinBalance}");
    emit(HomeState.copy(state));
    return true;
  }
}
