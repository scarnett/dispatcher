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
      }
    }
    ''';

const String fetchUserPINQueryStr = r'''
    query UserPINQuery($identifier: String!) {
      user_pins(where: {user: {_eq: $identifier}}) {
        pin_code
        verification_code
        verification_expire_code
      }
    }
    ''';
