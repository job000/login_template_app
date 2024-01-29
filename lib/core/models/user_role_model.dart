import 'package:parse_server_sdk/parse_server_sdk.dart';

class UserRole {
  late String name;
  late Set<String> accessibleQueues;
  late bool canRead;
  late bool canModify;

  UserRole({
    required this.name,
    this.accessibleQueues = const {},
    this.canRead = false,
    this.canModify = false,
  });

  // Convert UserRole to Pointer (for Parse)
  ParseObject toPointer() {
    return ParseObject('UserRole')..objectId = name;
  }

  // Create UserRole from ParseObject
  static UserRole fromParseObject(ParseObject parseRole) {
    return UserRole(
      name: parseRole.objectId!,
      // Populate other fields as needed based on your Parse Role class
    );
  }
}
