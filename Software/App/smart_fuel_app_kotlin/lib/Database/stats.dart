class Client {
  int id;
  String firstName;
  String lastName;

  String? day;
  int? waterLevel;
  List<List<int>>? drinkPoints;

  Client({
    required this.id,
    required this.firstName,
    required this.lastName,
  });

  factory Client.fromMap(Map<String, dynamic> json) => Client(
    id: json["id"],
    firstName: json["first_name"],
    lastName: json["last_name"],
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "first_name": firstName,
    "last_name": lastName,
  };
}