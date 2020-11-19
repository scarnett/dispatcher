import * as functions from 'firebase-functions'
import { hasuraClient } from '../../graphql/graphql-client'
import { generatePushID } from '../../utils/id_utils'

exports = module.exports = functions.https.onCall(async (data: any, context: functions.https.CallableContext) => {
  const users: string[] = data.users

  if (!users) {
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
    if ((rooms.length !== 1)) {
      throw new functions.https.HttpsError('aborted', 'rooms-create-bad-length', `${rooms.length} rooms found. 1 needed`)
    }

    const userList: any[] = []

    // Build the user data list
    users.forEach((user: string) => {
      userList.push({
        'room_id': rooms[0].id,
        'user': user
      })
    })

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
