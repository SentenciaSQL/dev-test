class GroupMemberItem {
  const GroupMemberItem({
    required this.id,
    required this.userId,
    required this.status,
  });

  final String id;
  final String userId;
  final String status;

  factory GroupMemberItem.fromJson(Map<String, dynamic> json) => GroupMemberItem(
        id: json['id'] as String,
        userId: json['userId'] as String,
        status: json['status'] as String,
      );
}

class CampaignGroupItem {
  const CampaignGroupItem({
    required this.id,
    required this.campaignId,
    required this.name,
    required this.targetSize,
    required this.occupiedSeats,
    required this.openSeats,
    required this.status,
    this.campaignName,
    this.members = const [],
    this.myMembershipId,
    this.myMembershipStatus,
  });

  final String id;
  final String campaignId;
  final String? campaignName;
  final String name;
  final int targetSize;
  final int occupiedSeats;
  final int openSeats;
  final String status;
  final List<GroupMemberItem> members;
  final String? myMembershipId;
  final String? myMembershipStatus;

  factory CampaignGroupItem.fromJson(Map<String, dynamic> json) =>
      CampaignGroupItem(
        id: json['id'] as String,
        campaignId: json['campaignId'] as String,
        campaignName: json['campaignName'] as String?,
        name: json['name'] as String,
        targetSize: (json['targetSize'] as num).toInt(),
        occupiedSeats: (json['occupiedSeats'] as num).toInt(),
        openSeats: (json['openSeats'] as num).toInt(),
        status: json['status'] as String,
        members: ((json['members'] as List?) ?? const [])
            .map((e) => GroupMemberItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        myMembershipId: json['myMembershipId'] as String?,
        myMembershipStatus: json['myMembershipStatus'] as String?,
      );
}
