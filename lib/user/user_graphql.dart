const String fetchUserQueryStr = r'''
    query UserQuery($identifier: String!) {
      users(where: {identifier: {_eq: $identifier}}) {
        identifier
        name
        email
        user_phone_number {
          dial_code
          iso_code
          phone_number
        }
      }
    }
    ''';
