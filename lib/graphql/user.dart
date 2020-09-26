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
        user_invite_code {
          code
          expire_date
        }
        user_avatar {
          url
        }
        user_pin {
          pin_code
          verification_code
          verification_expire_date
        }
        user_key {
          pubkey
        }
      }
    }
    ''';
