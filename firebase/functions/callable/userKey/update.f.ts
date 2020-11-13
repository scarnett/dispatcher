import * as functions from 'firebase-functions'
import { hasuraClient } from '../../graphql/graphql-client'

exports = module.exports = functions.https.onCall(async (data: any, context: functions.https.CallableContext) => {
  console.log(JSON.stringify(data))

  const identifier: string = data.identifier
  const publicKey: string = data.public_key
  const sigRegistrationId: number = data.sig_registration_id
  const sigSignedPublicKey: string = data.sig_signed_public_key
  const sigSignedPreKeySignature: string = data.sig_signed_prekey_signature
  const sigIdentityPublicKey: string = data.sig_identity_public_key
  const sigPreKeys: any[] = data.sig_prekeys

  if (!identifier || !publicKey) {
    throw new functions.https.HttpsError('cancelled', 'user-key-update-failed', 'missing information')
  }

  // GraphQL mutation for updating a user
  const mutation: string = `mutation($identifier: String!, $publicKey: String!, $sigRegistrationId: Int!, $sigSignedPublicKey: String!, $sigSignedPreKeySignature: String!, $sigIdentityPublicKey: String!, $sigPreKeys: [user_prekeys_insert_input!]!) {
    update_user_keys(where: {user: {_eq: $identifier}}, _set: {
      public_key: $publicKey
      sig_registration_id: $sigRegistrationId
      sig_signed_public_key: $sigSignedPublicKey
      sig_signed_prekey_signature: $sigSignedPreKeySignature
      sig_identity_public_key: $sigIdentityPublicKey
    }) {
      affected_rows
    }

    insert_user_prekeys(
      objects: $sigPreKeys
    ) {
      affected_rows
    }
  }`

  try {
    sigPreKeys.forEach((prekey: any) => {
      prekey['user'] = identifier
    })

    const config: functions.config.Config = functions.config()
    const endpoint: string = config.graphql.endpoint
    const adminSecret: string = config.hasura.admin.secret
    const response: any = await hasuraClient(endpoint, adminSecret).request(mutation, {
      identifier: identifier,
      publicKey: publicKey,
      sigRegistrationId: sigRegistrationId,
      sigSignedPublicKey: sigSignedPublicKey,
      sigSignedPreKeySignature: sigSignedPreKeySignature,
      sigIdentityPublicKey: sigIdentityPublicKey,
      sigPreKeys: sigPreKeys
    })

    return response
  } catch (e) {
    throw new functions.https.HttpsError('aborted', 'user-key-update-failed', JSON.stringify(e, undefined, 2))
  }
})
