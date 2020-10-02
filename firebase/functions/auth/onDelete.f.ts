import * as functions from 'firebase-functions'
import { hasuraClient } from '../graphql/graphql-client'

/**
 * This observes a user being deleted in the system.
 */
exports = module.exports = functions.auth.user().onDelete(async (user: functions.auth.UserRecord) => {
  // GraphQL mutation for deleting a user
  const mutation: string = `mutation($identifier: String!) {
    delete_user_keys(where: {user: {_eq: $identifier}}) {
      affected_rows
    }

    delete_user_phone_numbers(where: {user: {_eq: $identifier}}) {
      affected_rows
    }

    delete_user_invite_codes(where: {user: {_eq: $identifier}}) {
      affected_rows
    }

    delete_user_avatars(where: {user: {_eq: $identifier}}) {
      affected_rows
    }

    delete_user_pins(where: {user: {_eq: $identifier}}) {
      affected_rows
    }

    delete_users(where: {identifier: {_eq: $identifier}}) {
      affected_rows
    }
  }`

  try {
    const config: functions.config.Config = functions.config()
    const endpoint: string = config.graphql.endpoint
    const adminSecret: string = config.hasura.admin.secret
    const response: any = await hasuraClient(endpoint, adminSecret).request(mutation, {
      identifier: user.uid,
    })

    return response
  } catch (e) {
    throw new functions.https.HttpsError('aborted', 'sync-failed', JSON.stringify(e, undefined, 2))
  }
})
