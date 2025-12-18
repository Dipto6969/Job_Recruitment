class Job {
  final String id;
  final String title;
  final String description;
  final String location;
  final String jobType;
  final String? salary;
  final String companyId;
  final String? companyName;
  final List<String>? requirements;
  final DateTime? postedDate;  // ✅ CHANGED to nullable
  final DateTime? deadline;
  final bool isActive;

  Job({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.jobType,
    this.salary,
    required this.companyId,
    this.companyName,
    this.requirements,
    this.postedDate,  // ✅ CHANGED to nullable
    this.deadline,
    required this.isActive,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      location: json['location'] as String,
      jobType: json['job_type'] as String,
      salary: json['salary'] as String?,
      companyId: json['company_id'] as String,
      companyName: json['company_name'] as String?,
      requirements: json['requirements'] != null
          ? List<String>.from(json['requirements'] as List)
          : null,
      postedDate: json['posted_date'] != null  // ✅ CHANGED - handle null
          ? DateTime.parse(json['posted_date'] as String)
          : json['created_at'] != null  // ✅ Fallback to created_at
              ? DateTime.parse(json['created_at'] as String)
              : DateTime.now(),  // ✅ Ultimate fallback
      deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'] as String)
          : null,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'location': location,
      'job_type': jobType,
      'salary': salary,
      'company_id': companyId,
      'company_name': companyName,
      'requirements': requirements,
      'posted_date': postedDate?.toIso8601String(),
      'deadline': deadline?.toIso8601String(),
      'is_active': isActive,
    };
  }
}