import * as functions from 'firebase-functions'
import { hasuraClient } from '../../graphql/graphql-client'

exports = module.exports = functions.https.onCall(async (data: any, context: functions.https.CallableContext) => {
  const identifier: string = data.identifier
  const name: string = data.name
  const email: string = data.email
  const phone: any = data.phone

  if (!identifier || !name || !email || !phone) {
    throw new functions.https.HttpsError('cancelled', 'users-update-failed', 'missing information')
  }

  // GraphQL mutation for updating a user
  const mutation: string = `mutation($identifier: String!, $name: String!, $email: String!, $phone: user_phone_numbers_set_input!) {
    update_user_phone_numbers(where: {user: {_eq: $identifier}}, _set: $phone) {
      affected_rows
    }
    
    update_users(where: {identifier: {_eq: $identifier}}, _set: {
      name: $name,
      email: $email
    }) {
      affected_rows
    }
  }`

  try {
    const config: functions.config.Config = functions.config()
    const endpoint: string = config.graphql.endpoint
    const adminSecret: string = config.hasura.admin.secret
    const response: any = await hasuraClient(endpoint, adminSecret)
      .request(mutation, {
        identifier: identifier,
        name: name,
        email: email,
        phone: phone
      })

    return response
  } catch (e) {
    throw new functions.https.HttpsError('aborted', 'users-update-failed', JSON.stringify(e, undefined, 2))
  }
})
