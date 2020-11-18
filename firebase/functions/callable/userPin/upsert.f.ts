import * as functions from 'firebase-functions'
import * as admin from 'firebase-admin'
import { hasuraClient } from '../../graphql/graphql-client'

exports = module.exports = functions.https.onCall(async (data: any, context: functions.https.CallableContext) => {
  const identifier: string = data.identifier
  const pinCode: string = data.pinCode
  const verificationCode: string = data.verificationCode
  const verificationExpireDate: string = data.verificationExpireDate
  const sms: any = data.sms

  if (!identifier) {
    throw new functions.https.HttpsError('cancelled', 'user-pin-upsert-failed', 'missing information')
  }

  // GraphQL mutation for inserting or updating (upserting) a user PIN
  const mutation: string = `mutation($identifier: String!, $pin_code: String, $verification_code: String, $verification_expire_date: timestamptz) {
    insert_user_pins(
      objects: [
        {
          user: $identifier,
          pin_code: $pin_code,
          verification_code: $verification_code,
          verification_expire_date: $verification_expire_date
        }
      ],
      on_conflict: {
        constraint: user_pins_user_key,
        update_columns: [pin_code, verification_code, verification_expire_date]
      }
    ) {
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
        pin_code: pinCode,
        verification_code: verificationCode,
        verification_expire_date: verificationExpireDate
      })

    if (sms) {
      // Creates the sms record
      await admin.firestore().collection('sms').add({
        'user': sms['user'],
        'inbound_phone': sms['inbound_phone'],
        'body': sms['body'],
        'sent_date': sms['sent_date']
      })
    }

    return response
  } catch (e) {
    throw new functions.https.HttpsError('aborted', 'user-pin-upsert-failed', JSON.stringify(e, undefined, 2))
  }
})
