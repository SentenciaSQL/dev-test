class MissionItem {
  const MissionItem({
    required this.id,
    required this.campaignId,
    required this.title,
    required this.missionType,
    required this.rewardTc,
    required this.evidenceRequired,
    required this.status,
    this.description,
    this.instructions,
  });

  final String id;
  final String campaignId;
  final String title;
  final String? description;
  final String? instructions;
  final String missionType;
  final int rewardTc;
  final bool evidenceRequired;
  final String status;

  factory MissionItem.fromJson(Map<String, dynamic> json) => MissionItem(
        id: json['id'] as String,
        campaignId: json['campaignId'] as String,
        title: json['title'] as String,
        description: json['description'] as String?,
        instructions: json['instructions'] as String?,
        missionType: json['missionType'] as String,
        rewardTc: (json['rewardTc'] as num).toInt(),
        evidenceRequired: (json['evidenceRequired'] as bool?) ?? true,
        status: json['status'] as String,
      );
}

class SubmissionItem {
  const SubmissionItem({
    required this.id,
    required this.missionId,
    required this.userId,
    required this.status,
    required this.evidenceCount,
    this.description,
    this.reviewerNotes,
  });

  final String id;
  final String missionId;
  final String userId;
  final String? description;
  final String status;
  final String? reviewerNotes;
  final int evidenceCount;

  factory SubmissionItem.fromJson(Map<String, dynamic> json) => SubmissionItem(
        id: json['id'] as String,
        missionId: json['missionId'] as String,
        userId: json['userId'] as String,
        description: json['description'] as String?,
        status: json['status'] as String,
        reviewerNotes: json['reviewerNotes'] as String?,
        evidenceCount: (json['evidenceCount'] as num?)?.toInt() ?? 0,
      );
}
