import * as functions from 'firebase-functions'
import { hasuraClient } from '../../graphql/graphql-client'

exports = module.exports = functions.https.onCall(async (data: any, context: functions.https.CallableContext) => {
  const user: string = data.user
  const connectUser: any = data.connectUser

  if (!user || !connectUser) {
    throw new functions.https.HttpsError('cancelled', 'user-connection-create-failed', 'missing information')
  }

  // GraphQL query for selecting a prekey for the user
  const userPreKeyQuery: string = `query UserPreKeyQuery($user: String!, $connectUser: String!) {
    user: user_prekeys(where: {user: {_eq: $user}, _not: {prekey_connection: {user: {_eq: $user}}}}, limit: 1, order_by: {id: asc}) {
      id
      user
      public_key
    }
    
    connectUser: user_prekeys(where: {user: {_eq: $connectUser}, _not: {prekey_connection: {user: {_eq: $connectUser}}}}, limit: 1, order_by: {id: asc}) {
      id
      user
      public_key
    }
  }`

  // GraphQL mutation for inserting a two-way user connection
  const userConnectionMutation: string = `mutation($user: String!, $userPreKeyId: Int!, $connectUser: String!, $connectUserPreKeyId: Int!) {
    insert_user_connections(
      objects: [
        {
          user: $user,
          connect_user: $connectUser,
          prekey_id: $userPreKeyId
        },
        {
          user: $connectUser,
          connect_user: $user,
          prekey_id: $connectUserPreKeyId
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
    const userPreKeyResponse: any = await hasuraClient(endpoint, adminSecret)
      .request(userPreKeyQuery, {
        user: user,
        connectUser: connectUser
      })

    if (!userPreKeyResponse) {
      throw new functions.https.HttpsError('aborted', 'user-connection-prekey-bad-response', '0 prekeys found')
    }

    const userPreKeys: any[] = userPreKeyResponse.user
    if ((userPreKeys.length !== 1)) {
      throw new functions.https.HttpsError('aborted', 'user-connection-user-prekey-bad-length', `${userPreKeys.length} prekeys found. 1 needed`)
    }

    const connectUserPreKeys: any[] = userPreKeyResponse.connectUser
    if ((connectUserPreKeys.length !== 1)) {
      throw new functions.https.HttpsError('aborted', 'user-connection-connect-user-prekey-bad-length', `${connectUserPreKeys.length} prekeys found. 1 needed`)
    }

    const userConnectionResponse: Promise<any> = await hasuraClient(endpoint, adminSecret)
      .request(userConnectionMutation, {
        user: user,
        userPreKeyId: userPreKeys[0].id,
        connectUser: connectUser,
        connectUserPreKeyId: connectUserPreKeys[0].id
      })

    return userConnectionResponse
  } catch (e) {
    throw new functions.https.HttpsError('aborted', 'user-connection-create-failed', JSON.stringify(e, undefined, 2))
  }
})
