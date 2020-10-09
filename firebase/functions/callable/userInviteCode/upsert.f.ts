import * as functions from 'firebase-functions'
import * as admin from 'firebase-admin'
import { hasuraClient } from '../../graphql/graphql-client'
import { generateInviteCode } from '../../utils/user_utils'
import moment = require('moment')

exports = module.exports = functions.https.onCall(async (data: any, context: functions.https.CallableContext) => {
  const identifier: string = data.identifier

  if (!identifier) {
    throw new functions.https.HttpsError('cancelled', 'user-invite-code-upsert-failed', 'missing information')
  }

  // GraphQL mutation for inserting or updating (upserting) an invite code
  const mutation: string = `mutation($identifier: String!, $code: String!, $expireDate: timestamptz!) {
    insert_user_invite_codes(
      objects: [
        {
          user: $identifier,
          code: $code,
          expire_date: $expireDate
        }
      ],
      on_conflict: {
        constraint: invite_code_user,
        update_columns: [code, expire_date]
      }
    ) {
      affected_rows
      returning {
        code
        expire_date
      }
    }
  }`

  try {
    const config: functions.config.Config = functions.config()
    const endpoint: string = config.graphql.endpoint
    const adminSecret: string = config.hasura.admin.secret

    const dateNow: FirebaseFirestore.Timestamp = admin.firestore.Timestamp.now()
    const inviteCodeDateExpire: Date = moment(dateNow.toDate()).add(5, 'days').toDate()

    const response: any = await hasuraClient(endpoint, adminSecret).request(mutation, {
      identifier: identifier,
      code: generateInviteCode(),
      expireDate: inviteCodeDateExpire.toUTCString()
    })

    return response
  } catch (e) {
    throw new functions.https.HttpsError('aborted', 'user-invite-code-upsert-failed', JSON.stringify(e, undefined, 2))
  }
})
