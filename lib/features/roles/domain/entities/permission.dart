class Permission {
  final String featureName;
  final String actionName;

  const Permission ({
    required this.featureName,
    required this.actionName,
  });

  String get key => '$featureName:$actionName';
}