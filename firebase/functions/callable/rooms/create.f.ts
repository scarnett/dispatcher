import * as functions from 'firebase-functions'
import { hasuraClient } from '../../graphql/graphql-client'
import { generatePushID } from '../../utils/id_utils'

exports = module.exports = functions.https.onCall(async (data: any, context: functions.https.CallableContext) => {
  const roomUser1: string = data.roomUser1
  const roomUser2: string = data.roomUser2
  if (!roomUser1 || !roomUser2) {
    throw new functions.https.HttpsError('cancelled', 'rooms-create-failed', 'missing information')
  }

  // GraphQL mutation for inserting a room
  const roomMutation: string = `mutation($identifier: String!) {
    insert_rooms(
      objects: [
        {
          identifier: $identifier
        }
      ]
    ) {
      affected_rows
      returning {
        id
      }
    }
  }`

  // GraphQL mutation for inserting some room users
  const roomUsersMutation: string = `mutation($users: [room_users_insert_input!]!) {
    insert_room_users(
      objects: $users
    ) {
      affected_rows
    }
  }`

  try {
    const config: functions.config.Config = functions.config()
    const endpoint: string = config.graphql.endpoint
    const adminSecret: string = config.hasura.admin.secret

    // Create the room
    const roomResponse: any = await hasuraClient(endpoint, adminSecret)
      .request(roomMutation, {
        identifier: generatePushID()
      })

    if (!roomResponse) {
      throw new functions.https.HttpsError('aborted', 'rooms-create-bad-response', '0 rooms found')
    }

    const rooms: any[] = roomResponse['insert_rooms']['returning']
    if (rooms.length !== 1) {
      throw new functions.https.HttpsError('aborted', 'rooms-create-bad-length', `${rooms.length} rooms found. 1 needed`)
    }

    const roomId: string = rooms[0].id
    const userList: any[] = []
    userList.push(addUser(roomId, roomUser1, await requestUserPreKey(roomUser2)))
    userList.push(addUser(roomId, roomUser2, await requestUserPreKey(roomUser1)))

    // Add users to the room
    const roomUsersResponse: any = await hasuraClient(endpoint, adminSecret)
      .request(roomUsersMutation, {
        users: userList
      })

    return roomUsersResponse
  } catch (e) {
    throw new functions.https.HttpsError('aborted', 'rooms-create-failed', JSON.stringify(e, undefined, 2))
  }
})

async function requestUserPreKey(user: string): Promise<string> {
  // GraphQL query for selecting a prekey for the user
  const userPreKeyQuery: string = `query UserPreKeyQuery($user: String!) {
    user_prekeys(where: {user: {_eq: $user}, _not: {prekey_room_user: {user_identifier: {_eq: $user}}}}, limit: 1, order_by: {id: asc}) {
      id
      user
      public_key
    }
  }`

  const config: functions.config.Config = functions.config()
  const endpoint: string = config.graphql.endpoint
  const adminSecret: string = config.hasura.admin.secret
  const userPreKeyResponse: any = await hasuraClient(endpoint, adminSecret)
    .request(userPreKeyQuery, {
      user: user
    })

  if (!userPreKeyResponse) {
    throw new functions.https.HttpsError('aborted', 'rooms-create-prekey-bad-response', '0 prekeys found')
  }

  const userPreKeys: any[] = userPreKeyResponse.user_prekeys
  if ((userPreKeys.length !== 1)) {
    throw new functions.https.HttpsError('aborted', 'rooms-create-prekey-bad-length', `${userPreKeys.length} prekeys found. 1 needed`)
  }

  return userPreKeys[0].id
}

function addUser(roomId: string, user: string, preKeyId: string): any {
  return {
    'room_id': roomId,
    'user_identifier': user,
    'prekey_id': preKeyId
  }
}
