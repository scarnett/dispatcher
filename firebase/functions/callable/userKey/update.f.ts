import * as functions from 'firebase-functions'
import { hasuraClient } from '../../graphql/graphql-client'

exports = module.exports = functions.https.onCall(async (data: any, context: functions.https.CallableContext) => {
  const identifier: string = data.identifier
  const pubkey: string = data.pubkey

  if (!identifier || !pubkey) {
    throw new functions.https.HttpsError('cancelled', 'user-key-update-failed', 'missing information')
  }

  // GraphQL mutation for updating a user
  const mutation: string = `mutation($identifier: String!, $pubkey: String!) {
    update_user_keys(where: {user: {_eq: $identifier}}, _set: {
      pubkey: $pubkey
    }) {
      affected_rows
    }
  }`

  try {
    const config: functions.config.Config = functions.config()
    const endpoint: string = config.graphql.endpoint
    const adminSecret: string = config.hasura.admin.secret
    const response: any = await hasuraClient(endpoint, adminSecret).request(mutation, {
      identifier: identifier,
      pubkey: pubkey
    })

    return response
  } catch (e) {
    throw new functions.https.HttpsError('aborted', 'user-key-update-failed', JSON.stringify(e, undefined, 2))
  }
})
