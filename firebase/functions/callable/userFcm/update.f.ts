import * as functions from 'firebase-functions'
import { hasuraClient } from '../../graphql/graphql-client'

exports = module.exports = functions.https.onCall(async (data: any, context: functions.https.CallableContext) => {
  const identifier: string = data.identifier
  const token: any = data.token

  if (!identifier || !token) {
    throw new functions.https.HttpsError('cancelled', 'user-fcm-update-failed', 'missing information')
  }

  // GraphQL mutation for updating a user FCM
  const mutation: string = `mutation($identifier: String!, $fcm: user_fcms_set_input!) {
    update_user_fcms(where: {user: {_eq: $identifier}}, _set: $fcm) {
      affected_rows
    }
  }`

  try {
    const config: functions.config.Config = functions.config()
    const endpoint: string = config.graphql.endpoint
    const adminSecret: string = config.hasura.admin.secret
    const response: any = await hasuraClient(endpoint, adminSecret).request(mutation, {
      identifier: identifier,
      fcm: {
        token: token
      }
    })

    return response
  } catch (e) {
    throw new functions.https.HttpsError('aborted', 'user-fcm-update-failed', JSON.stringify(e, undefined, 2))
  }
})
