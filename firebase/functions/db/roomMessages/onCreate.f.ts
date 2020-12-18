import * as functions from 'firebase-functions'
import { hasuraClient } from '../../graphql/graphql-client'

/**
 * This observes a room message record being created in the system.
 */
exports = module.exports = functions.firestore
  .document('rooms/{roomIdentifier}/messages/{messageIdentifier}').onCreate(async (messageDocument: functions.firestore.QueryDocumentSnapshot, context: functions.EventContext) => {
    try {
      const promises: Array<Promise<any>> = []
      const messageData: FirebaseFirestore.DocumentData = messageDocument.data()
      const messageIdentifier: string = messageDocument.id
      const roomIdentifier: string = context.params.roomIdentifier

      try {
        const config: functions.config.Config = functions.config()
        const endpoint: string = config.graphql.endpoint
        const adminSecret: string = config.hasura.admin.secret

        // GraphQL mutation for inserting the new user
        const mutation: string = `mutation ($roomIdentifier: String!, $messageIdentifier: String!, $userIdentifier: String!, $message: String!, $type: Int!) {
          insert_room_messages_one(
            object: {
              room_identifier: $roomIdentifier,
              message_identifier: $messageIdentifier,
              user_identifier: $userIdentifier,
              message: $message,
              type: $type
            }
          ) {
            room_identifier
            message_identifier
    				user_identifier
            message
            type
          }
        }`

        // Post the mutation to Hasura GraphQL
        promises.push(hasuraClient(endpoint, adminSecret).request(mutation, {
          roomIdentifier: roomIdentifier,
          messageIdentifier: messageIdentifier,
          userIdentifier: messageData['user_identifier'],
          message: messageData['message'],
          type: messageData['type']
        }))
      } catch (e) {
        functions.logger.error(e)
        return Promise.resolve('error')
      }

      return Promise.all(promises)
        .then(() => Promise.resolve('ok'))
        .catch((error: any) => {
          functions.logger.error(error)
          return Promise.resolve('error')
        })
    } catch (error) {
      functions.logger.error(error)
      return Promise.resolve('error')
    }
  })
