import * as functions from 'firebase-functions'
import { hasuraClient } from '../../graphql/graphql-client'

exports = module.exports = functions.https.onCall(async (data: any, context: functions.https.CallableContext) => {
  const roomIdentifier: string = data.roomIdentifier
  const userIdentifier: string = data.userIdentifier
  const message: string = data.message
  const type: number = data.type
  if (!roomIdentifier || !userIdentifier || !message) {
    throw new functions.https.HttpsError('cancelled', 'rooms-message-create-failed', 'missing information')
  }

  // GraphQL mutation for inserting a room message
  const roomMessageMutation: string = `mutation($message: [room_messages_insert_input!]!) {
    insert_room_messages(
      objects: $message
    ) {
      affected_rows
    }
  }`

  try {
    const config: functions.config.Config = functions.config()
    const endpoint: string = config.graphql.endpoint
    const adminSecret: string = config.hasura.admin.secret

    // Add a message to the room
    const roomMessageResponse: any = await hasuraClient(endpoint, adminSecret)
      .request(roomMessageMutation, {
        message: {
          'room_identifier': roomIdentifier,
          'user_identifier': userIdentifier,
          'message': message,
          'type': type
        }
      })

    return roomMessageResponse
  } catch (e) {
    throw new functions.https.HttpsError('aborted', 'rooms-message-create-failed', JSON.stringify(e, undefined, 2))
  }
})
