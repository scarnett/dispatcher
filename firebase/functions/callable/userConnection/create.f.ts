import * as functions from 'firebase-functions'
import { hasuraClient } from '../../graphql/graphql-client'

exports = module.exports = functions.https.onCall(async (data: any, context: functions.https.CallableContext) => {
  const user: string = data.user
  const connectUser: any = data.connectUser

  if (!user || !connectUser) {
    throw new functions.https.HttpsError('cancelled', 'user-connection-create-failed', 'missing information')
  }

  // GraphQL mutation for inserting a two-way user connection
  const mutation: string = `mutation($user: String!, $connectUser: String!) {
    insert_user_connections(
      objects: [
        {
          user: $user,
          connect_user: $connectUser
        },
        {
          user: $connectUser,
          connect_user: $user
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
      user: user,
      connectUser: connectUser
    })

    return response
  } catch (e) {
    throw new functions.https.HttpsError('aborted', 'user-connection-create-failed', JSON.stringify(e, undefined, 2))
  }
})
