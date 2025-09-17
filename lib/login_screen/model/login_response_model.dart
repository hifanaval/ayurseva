// To parse this JSON data, do
//
//     final loginResponseModel = loginResponseModelFromJson(jsonString);

import 'dart:convert';

LoginResponseModel loginResponseModelFromJson(String str) => LoginResponseModel.fromJson(json.decode(str));

String loginResponseModelToJson(LoginResponseModel data) => json.encode(data.toJson());

class LoginResponseModel {
    bool? status;
    String? message;
    String? token;
    bool? isSuperuser;
    UserDetails? userDetails;

    LoginResponseModel({
        this.status,
        this.message,
        this.token,
        this.isSuperuser,
        this.userDetails,
    });

    factory LoginResponseModel.fromJson(Map<String, dynamic> json) => LoginResponseModel(
        status: json["status"],
        message: json["message"],
        token: json["token"],
        isSuperuser: json["is_superuser"],
        userDetails: json["user_details"] == null ? null : UserDetails.fromJson(json["user_details"]),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "token": token,
        "is_superuser": isSuperuser,
        "user_details": userDetails?.toJson(),
    };
}

class UserDetails {
    int? id;
    dynamic lastLogin;
    String? name;
    String? phone;
    String? address;
    String? mail;
    String? username;
    String? password;
    String? passwordText;
    int? admin;
    bool? isAdmin;
    bool? isActive;
    DateTime? createdAt;
    DateTime? updatedAt;
    dynamic branch;

    UserDetails({
        this.id,
        this.lastLogin,
        this.name,
        this.phone,
        this.address,
        this.mail,
        this.username,
        this.password,
        this.passwordText,
        this.admin,
        this.isAdmin,
        this.isActive,
        this.createdAt,
        this.updatedAt,
        this.branch,
    });

    factory UserDetails.fromJson(Map<String, dynamic> json) => UserDetails(
        id: json["id"],
        lastLogin: json["last_login"],
        name: json["name"],
        phone: json["phone"],
        address: json["address"],
        mail: json["mail"],
        username: json["username"],
        password: json["password"],
        passwordText: json["password_text"],
        admin: json["admin"],
        isAdmin: json["is_admin"],
        isActive: json["is_active"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
        branch: json["branch"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "last_login": lastLogin,
        "name": name,
        "phone": phone,
        "address": address,
        "mail": mail,
        "username": username,
        "password": password,
        "password_text": passwordText,
        "admin": admin,
        "is_admin": isAdmin,
        "is_active": isActive,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "branch": branch,
    };
}
