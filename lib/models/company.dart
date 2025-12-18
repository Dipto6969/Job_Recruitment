class Company {
  final String id;
  final String employerId;
  final String name;
  final String? description;

  Company({
    required this.id,
    required this.employerId,
    required this.name,
    this.description,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'],
      employerId: json['employer_id'],
      name: json['name'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employer_id': employerId,
      'name': name,
      'description': description,
    };
  }
}