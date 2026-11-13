class ApplicationItem {
  const ApplicationItem({
    required this.id,
    required this.name,
    required this.packageName,
    required this.status,
    this.description,
    this.category,
    this.currentVersion,
    this.closedTestingUrl,
    this.screenshotUrls = const [],
  });

  final String id;
  final String name;
  final String packageName;
  final String status;
  final String? description;
  final String? category;
  final String? currentVersion;
  final String? closedTestingUrl;
  final List<String> screenshotUrls;

  factory ApplicationItem.fromJson(Map<String, dynamic> json) => ApplicationItem(
        id: json['id'] as String,
        name: json['name'] as String,
        packageName: json['packageName'] as String,
        status: json['status'] as String,
        description: json['description'] as String?,
        category: json['category'] as String?,
        currentVersion: json['currentVersion'] as String?,
        closedTestingUrl: json['closedTestingUrl'] as String?,
        screenshotUrls: ((json['screenshotUrls'] as List?) ?? const [])
            .map((e) => e.toString())
            .toList(),
      );
}
