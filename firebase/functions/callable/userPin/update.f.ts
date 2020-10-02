import * as functions from 'firebase-functions'
import { hasuraClient } from '../../graphql/graphql-client'

exports = module.exports = functions.https.onCall(async (data: any, context: functions.https.CallableContext) => {
  const identifier: string = data.identifier
  const pin: any = data.pin

  if (!identifier || !pin) {
    throw new functions.https.HttpsError('cancelled', 'user-pin-update-failed', 'missing information')
  }

  // GraphQL mutation for updating a user PIN
  const mutation: string = `mutation($identifier: String!, $pin: user_pins_set_input!) {
    update_user_pins(where: {user: {_eq: $identifier}}, _set: $pin) {
      affected_rows
    }
  }`

  try {
    const config: functions.config.Config = functions.config()
    const endpoint: string = config.graphql.endpoint
    const adminSecret: string = config.hasura.admin.secret
    const response: any = await hasuraClient(endpoint, adminSecret).request(mutation, {
      identifier: identifier,
      pin: pin
    })

    return response
  } catch (e) {
    throw new functions.https.HttpsError('aborted', 'user-pin-update-failed', JSON.stringify(e, undefined, 2))
  }
})
