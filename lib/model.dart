enum MessageType {
  INFO,
  SUCCESS,
  WARNING,
  ERROR,
}

class Message {
  String text;
  MessageType type;
  int duration;

  Message({
    this.text,
    this.type: MessageType.INFO,
    this.duration: 3,
  });

  @override
  String toString() => 'Message{text: $text, type: $type, duration: $duration}';
}
