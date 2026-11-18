class Student {
  Student({required this.id, required this.name});

  final String id;
  String name;

  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  factory Student.fromJson(Map<String, dynamic> json) => Student(
        id: json['id'] as String,
        name: json['name'] as String,
      );

  Student copyWith({String? name}) => Student(id: id, name: name ?? this.name);
}