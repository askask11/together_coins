import 'get_env.dart';

/**
 *
 * User's JSON format
 * "user": {
    "user_id": 1,
    "name": "Jianqing",
    "email": "vip@jianqinggao.com",
    "bark_url": null,
    "coin_balance": 0,
    "city": "Los Angeles",
    "time_zone": -8,
    "binded_user": null,
    "token": null,
    "status": 1,
    "avatar_path": null
    }
 */
class User {
  final int userId;
  final String name;
  final String email;
  final String city;
  final int timeZone;
  final String avatarPath;
  int coinBalance;
  final String barkUrl;
  final int? bindedUser;
  final String token;
  final int status;
  final String statusIcon;
  final String statusName;
  String jwtToken = "";

  User({
    required this.userId,
    required this.name,
    required this.email,
    required this.city,
    required this.timeZone,
    required this.avatarPath,
    required this.coinBalance,
    required this.barkUrl,
    required this.bindedUser,
    required this.token,
    required this.status,
    required this.statusName,
    required this.statusIcon,
    this.jwtToken = "",
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'] ?? 0,
      name: json['name'],
      email: json['email'],
      city: json['city'],
      timeZone: json['time_zone'] ?? 8,
      avatarPath:
          json['avatar_path'] ?? "${GetEnv.getApiBaseUrl()}/images/avatar1.png",
      coinBalance: json['coin_balance'] ?? 0,
      barkUrl: json['bark_url'] ?? "",
      bindedUser: json['bind_user'] ?? -1,
      token: json['token'] ?? "",
      status: json['status'] ?? 1,
      statusName: json['status_name'] ?? 'Happy',
      statusIcon: json['status_icon'] ?? '😃',
      jwtToken: json['jwtToken'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'email': email,
      'city': city,
      'time_zone': timeZone,
      'avatar_path': avatarPath,
      'coin_balance': coinBalance,
      'bark_url': barkUrl,
      'bind_user': bindedUser,
      'token': token,
      'status': status,
      'status_name': statusName,
      'status_icon': statusIcon,
      'jwtToken': jwtToken,
    };
  }

  //tostring
  @override
  String toString() {
    return 'User{userId: $userId, name: $name, email: $email, city: $city, timeZone: $timeZone, avatarPath: $avatarPath, coinBalance: $coinBalance, barkUrl: $barkUrl, bindedUser: $bindedUser, token: $token, status: $status, statusIcon: $statusIcon, statusName: $statusName}';
  }
}
