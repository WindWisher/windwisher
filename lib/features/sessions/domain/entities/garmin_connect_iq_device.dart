class GarminConnectIqDevice {
  const GarminConnectIqDevice({
    required this.id,
    required this.name,
    required this.status,
    required this.sessionAppId,
    this.partNumber,
  });

  final String id;
  final String name;
  final String status;
  final String sessionAppId;
  final String? partNumber;

  bool get isConnected => status.toLowerCase() == 'connected';
}
