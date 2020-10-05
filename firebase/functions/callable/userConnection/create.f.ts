import * as functions from 'firebase-functions'
import { hasuraClient } from '../../graphql/graphql-client'

exports = module.exports = functions.https.onCall(async (data: any, context: functions.https.CallableContext) => {
  const userId: string = data.userId
  const connectUserId: any = data.connectUserId

  if (!userId || !connectUserId) {
    throw new functions.https.HttpsError('cancelled', 'user-connection-create-failed', 'missing information')
  }

  // GraphQL mutation for inserting a two-way user connection
  const mutation: string = `mutation($userId: String!, $connectUserId: String!) {
    insert_user_connections(
      objects: [
        {
          user_id: $userId,
          connect_user_id: $connectUserId
        },
        {
          user_id: $connectUserId,
          connect_user_id: $userId
        }
      ]
    ) {
      affected_rows
    }
  }`

  try {
    const config: functions.config.Config = functions.config()
    const endpoint: string = config.graphql.endpoint
    const adminSecret: string = config.hasura.admin.secret
    const response: any = await hasuraClient(endpoint, adminSecret).request(mutation, {
      userId: userId,
      connectUserId: connectUserId
    })

    return response
  } catch (e) {
    throw new functions.https.HttpsError('aborted', 'user-connection-create-failed', JSON.stringify(e, undefined, 2))
  }
})
