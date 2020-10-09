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
        user_avatar {
          url
        }
        user_connections {
          connect_user
        }
        user_key {
          pubkey
        }
      }
    }
    ''';

const String fetchPINQueryStr = r'''
    query UserPINQuery($identifier: String!) {
      user_pins(where: {user: {_eq: $identifier}}) {
        pin_code
        verification_code
        verification_expire_date
      }
    }
    ''';

const String fetchInviteCodeQueryStr = r'''
    query UserInviteCodeQuery($identifier: String!) {
      user_invite_codes(where: {user: {_eq: $identifier}}) {
        code
        expire_date
      }
    }
    ''';

const String fetchUserByInviteCodeQueryStr = r'''
    query UserInviteCodeQuery($inviteCode: String!) {
      user_invite_codes(where: {code: {_eq: $inviteCode}}) {
        user_fk {
          identifier
          name
          email
          user_avatar {
            url
          }
          user_connections {
            user,
            connect_user
          }
        }
      }
    }
    ''';
