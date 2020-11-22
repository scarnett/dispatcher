import * as functions from 'firebase-functions'
import { hasuraClient } from '../../graphql/graphql-client'

exports = module.exports = functions.https.onCall(async (data: any, context: functions.https.CallableContext) => {
  const users: string[] = data.users
  if (!users) {
    throw new functions.https.HttpsError('cancelled', 'rooms-fetch-failed', 'missing information')
  }

  // GraphQL query for selecting user rooms
  const roomsQuery: string = `query RoomsQuery($users: [String!]!) {
    rooms(where: {room_users: {user_identifier: {_in: $users}}}) {
      id
      identifier
      room_users {
        user {
          identifier
          name
          email
          user_key {
            sig_identity_public_key
            sig_registration_id
            sig_signed_prekey_signature
            sig_signed_public_key
          }
        }
        preKey {
          key_id
          public_key
        }
      }
      room_messages {
        message
        user_identifier
        created_date
      }
    }
  }`

  try {
    const config: functions.config.Config = functions.config()
    const endpoint: string = config.graphql.endpoint
    const adminSecret: string = config.hasura.admin.secret
    const roomsResponse: any = await hasuraClient(endpoint, adminSecret)
      .request(roomsQuery, {
        users: users
      })

    if (!roomsResponse) {
      throw new functions.https.HttpsError('aborted', 'rooms-fetch-bad-response', '0 rooms found')
    }

    const rooms: any[] = roomsResponse['rooms']
    if (!rooms || (rooms.length === 0)) {
      throw new functions.https.HttpsError('aborted', 'rooms-fetch-bad-length', `0 rooms found`)
    }

    for (const room of rooms) {
      const roomUsers: any[] = room['room_users']
      if (users.length === roomUsers.length) {
        const userIdentifiers: string[] = roomUsers.map(entry => entry.user.identifier)
        const roomUsersSorted: any[] = userIdentifiers.slice().sort()

        // Here we make sure that the room user list matches exactly
        // @see https://stackoverflow.com/a/19746771/13197894
        if (users.slice().sort().every((userId: string, index: number) => (userId === roomUsersSorted[index]))) {
          return room
        }
      }
    }

    throw new functions.https.HttpsError('aborted', 'rooms-fetch-bad-result', `0 rooms found`)
  } catch (e) {
    throw new functions.https.HttpsError('aborted', 'rooms-fetch-failed', JSON.stringify(e, undefined, 2))
  }
})
