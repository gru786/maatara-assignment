class Notes {
  int? id;
  String title;
  String description;
  String color;

  Notes(
      {this.id,
      required this.title,
      required this.description,
      this.color = "0xffffffff"});

  Map<String, dynamic> toMap() {
    return {
      'id': (id == 0) ? null : id,
      'title': title,
      'description': description,
      'color': color
    };
  }
}
