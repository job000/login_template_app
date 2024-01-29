// ignore_for_file: unused_local_variable
import 'package:parse_server_sdk/parse_server_sdk.dart';
//import '../src/utils/user.dart';

const String kParseApplicationId = 'YOUR_APP_ID_HERE';
const String kParseClientKey = 'YOUR_CLIENT_KEY_HERE';
const String kParseServerUrl = 'https://parseapi.back4app.com/';

class DatabaseHelper {
  // Initialize the Parse client
  Future<void> initializeParse() async {
    await Parse().initialize(
      kParseApplicationId,
      kParseServerUrl,
      clientKey: kParseClientKey,
      autoSendSessionId: true,
      debug: true, // Set to false in production
    );
  }

  // Check if username exists
  Future<bool> checkUsername(String username) async {
    final QueryBuilder<ParseUser> queryBuilder = QueryBuilder<ParseUser>(ParseUser.forQuery())
      ..whereEqualTo('username', username);
    final ParseResponse response = await queryBuilder.query();

    if (response.success && response.results != null) {
      return response.results!.isNotEmpty;
    } else if (response.success && response.results == null) {
      return false;
    } else {
      throw Exception('Failed to check username: ${response.error?.message}');
    }
  }

  
// Register a new user with ACL set to public read and write
Future<ParseResponse> registerUser(String username, String password, String email) async {
  var parseUser = ParseUser(username, password, email);

  // Attempt to sign up the user
  ParseResponse signUpResponse = await parseUser.signUp();

  // Check if sign up was successful
  if (signUpResponse.success) {
    // Create a new ACL with public read and write access
    var acl = ParseACL()
      ..setPublicReadAccess(allowed: true)
      ..setPublicWriteAccess(allowed: true);

    // Set the ACL to the user and save
    parseUser.setACL(acl);
    await parseUser.save();

    return signUpResponse;
  } else {
    // Return the original response if sign up failed
    return signUpResponse;
  }
}




  
//Get the users role:
Future<List<ParseObject>> getUserRoles(ParseUser user) async {
  // Assuming 'UserRole' is the key for the relation in your User class
  // and 'Role' is the name of the class where the roles are defined

  // Get the relation for 'UserRole' from the user
  ParseRelation<ParseObject> userRoleRelation = user.getRelation<ParseObject>('UserRole');

  // The query for roles
  QueryBuilder<ParseObject> query = QueryBuilder<ParseObject>(ParseObject('Role'))
    ..whereRelatedTo('UserRole', '_User', user.objectId.toString());

  // Execute the query
  final ParseResponse response = await query.query();

  if (response.success && response.results != null) {
    return response.results as List<ParseObject>;
  } else {
    throw Exception('Failed to retrieve user roles: ${response.error?.message}');
  }
}







  // Create a new object
  Future<ParseResponse> createObject(ParseObject newObject) async {
    return await newObject.save();
  }

  // Retrieve an object by objectId
  Future<ParseObject> getObject(String className, String objectId) async {
    final ParseObject object = ParseObject(className);
    final ParseResponse response = await object.getObject(objectId);

    if (response.success && response.result != null) {
      return response.result as ParseObject;
    } else {
      throw Exception('Failed to retrieve object: ${response.error?.message}');
    }
  }

  // Update an object
  Future<ParseResponse> updateObject(ParseObject object) async {
    return await object.save();
  }

  // Delete an object
  Future<ParseResponse> deleteObject(ParseObject object) async {
    return await object.delete();
  }

  // Query objects
  Future<List<ParseObject>> queryAll(String className) async {
    final QueryBuilder<ParseObject> queryBuilder = QueryBuilder<ParseObject>(ParseObject(className));
    final ParseResponse response = await queryBuilder.query();

    if (response.success && response.results != null) {
      return response.results as List<ParseObject>;
    } else {
      throw Exception('Failed to query objects: ${response.error?.message}');
    }
  }

}