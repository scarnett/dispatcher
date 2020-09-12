// ------------------------------------------------------------ Fetch Device
import 'package:graphql_flutter/graphql_flutter.dart';

const String fetchDeviceQueryStr = """
    query DeviceQuery(\$identifier: String!) {
      devices(where: {identifier: {_eq: \$identifier}}) {
        id
        identifier
        public_key
        registered_date
        device_invite_code {
          code
          device_id
          expire_date
          id
        }
      }
    }
    """;

QueryOptions getFetchDeviceQuery(
  String identifier,
) =>
    QueryOptions(
      fetchPolicy: FetchPolicy.networkOnly,
      documentNode: gql(fetchDeviceQueryStr),
      variables: {
        'identifier': identifier,
      },
    );

// ------------------------------------------------------------ Add Device
const String addDeviceMutationStr = """
    mutation addDevice(\$identifier: String!, \$publicKey: String!) {
      action: insert_devices(objects: { identifier: \$identifier, public_key: \$publicKey }) {
        returning {
          id
          identifier
          public_key
          registered_date
        }
      }
    }
    """;

MutationOptions addDeviceMutation(
  Map<String, dynamic> deviceData,
) =>
    MutationOptions(
      documentNode: gql(addDeviceMutationStr),
      variables: deviceData,
      update: (
        Cache cache,
        QueryResult result,
      ) {
        if (result.hasException) {
          // TODO!
          print(result.exception);
        } else {
          cache.write(typenameDataIdFromObject(deviceData), deviceData);
        }

        return cache;
      },
    );
