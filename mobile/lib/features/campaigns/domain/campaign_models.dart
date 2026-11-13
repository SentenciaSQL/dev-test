class CampaignItem {
  const CampaignItem({
    required this.id,
    required this.applicationId,
    required this.name,
    required this.durationDays,
    required this.targetTesters,
    required this.status,
    required this.costPerTesterTc,
    required this.totalCostTc,
    this.applicationName,
    this.description,
    this.testType = 'CLOSED',
    this.allowedCountries = const [],
    this.minAndroidSdk,
    this.maxAndroidSdk,
    this.instructions,
  });

  final String id;
  final String applicationId;
  final String? applicationName;
  final String name;
  final String? description;
  final String testType;
  final int durationDays;
  final int targetTesters;
  final List<String> allowedCountries;
  final int? minAndroidSdk;
  final int? maxAndroidSdk;
  final String? instructions;
  final String status;
  final int costPerTesterTc;
  final int totalCostTc;

  factory CampaignItem.fromJson(Map<String, dynamic> json) => CampaignItem(
        id: json['id'] as String,
        applicationId: json['applicationId'] as String,
        applicationName: json['applicationName'] as String?,
        name: json['name'] as String,
        description: json['description'] as String?,
        testType: (json['testType'] as String?) ?? 'CLOSED',
        durationDays: (json['durationDays'] as num).toInt(),
        targetTesters: (json['targetTesters'] as num).toInt(),
        allowedCountries: ((json['allowedCountries'] as List?) ?? const [])
            .map((e) => e.toString())
            .toList(),
        minAndroidSdk: (json['minAndroidSdk'] as num?)?.toInt(),
        maxAndroidSdk: (json['maxAndroidSdk'] as num?)?.toInt(),
        instructions: json['instructions'] as String?,
        status: json['status'] as String,
        costPerTesterTc: (json['costPerTesterTc'] as num).toInt(),
        totalCostTc: (json['totalCostTc'] as num).toInt(),
      );
}
