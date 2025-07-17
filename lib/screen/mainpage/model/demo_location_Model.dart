class LocationResponse {
  final int data;
  final String message;
  final bool completed;

  LocationResponse({
    required this.data,
    required this.message,
    required this.completed,
  });

  factory LocationResponse.fromJson(Map<String, dynamic> json) {
    return LocationResponse(
      data: json['Data'],
      message: json['Message'],
      completed: json['Completed'],
    );
  }
}
