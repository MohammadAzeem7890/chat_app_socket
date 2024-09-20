class MessageModel {
  // Unique identifier for the message
  final String id;

  // The content of the message (text)
  final String text;

  // The type of message (text, image, video, audio, etc.)
  final MessageType messageType;

  // ID of the user who sent the message
  final String senderId;

  // Name of the user who sent the message
  final String senderName;

  // Profile picture or avatar of the sender (optional)
  final String? senderAvatarUrl;

  // ID of the chat room or conversation
  final String chatRoomId;

  // Timestamp when the message was sent
  final DateTime timestamp;

  // Status of the message (sent, delivered, seen)
  final MessageStatus status;

  // Reactions to the message (could be a list or map of emoji -> userId)
  final Map<String, List<String>> reactions;

  // Optional: URL of the image if the message contains an image
  final String? imageUrl;

  // Optional: URL of the audio file if the message contains an audio message
  final String? audioUrl;

  // Optional: URL of the video if the message contains a video
  final String? videoUrl;

  // Optional: Duration of the audio/video message
  final Duration? mediaDuration;

  // Boolean flag to indicate whether the message was edited
  final bool isEdited;

  // Boolean flag to indicate whether the message was deleted
  final bool isDeleted;

  // Constructor
  MessageModel({
    required this.id,
    required this.text,
    required this.messageType,
    required this.senderId,
    required this.senderName,
    this.senderAvatarUrl,
    required this.chatRoomId,
    required this.timestamp,
    required this.status,
    this.reactions = const {},
    this.imageUrl,
    this.audioUrl,
    this.videoUrl,
    this.mediaDuration,
    this.isEdited = false,
    this.isDeleted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'messageType':
          messageType.toString().split('.').last, // Convert enum to string
      'senderId': senderId,
      'senderName': senderName,
      'senderAvatarUrl': senderAvatarUrl,
      'chatRoomId': chatRoomId,
      'timestamp': timestamp.toIso8601String(), // DateTime to ISO string
      'status': status.toString().split('.').last,
      'reactions': reactions,
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
      'videoUrl': videoUrl,
      'mediaDuration': mediaDuration?.inSeconds,
      'isEdited': isEdited,
      'isDeleted': isDeleted,
    };
  }

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
        id: json['id'],
        text: json['text'],
        messageType: MessageType.values.firstWhere(
            (e) => e.toString() == 'MessageType.${json['messageType']}'),
        senderId: json['senderId'],
        senderName: json['senderName'],
        senderAvatarUrl: json['senderAvatarUrl'],
        chatRoomId: json['chatRoomId'],
        timestamp: DateTime.parse(json['timestamp']),
        status: MessageStatus.values.firstWhere(
            (e) => e.toString() == 'MessageStatus.${json['status']}'),
        reactions: Map<String, List<String>>.from(json['reactions']),
        imageUrl: json['imageUrl'],
        audioUrl: json['audioUrl'],
        videoUrl: json['videoUrl'],
        mediaDuration: json['mediaDuration'] != null
            ? Duration(seconds: json['mediaDuration'])
            : null,
        isEdited: json['isEdited'],
        isDeleted: json['isDeleted']);
  }
}

// Enum to specify the type of message (text, image, video, audio, etc.)
enum MessageType {
  text,
  image,
  video,
  audio,
  file, // For documents or other file types
}

// Enum to track message status (sent, delivered, read)
enum MessageStatus {
  sending,
  sent,
  delivered,
  seen,
  failed, // For handling message failure cases
}
