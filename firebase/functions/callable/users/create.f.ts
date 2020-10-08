import * as functions from 'firebase-functions'
import * as admin from 'firebase-admin'
import { generateInviteCode } from '../../utils/user_utils'
import moment = require('moment')

exports = module.exports = functions.https.onCall(async (data: any, context: functions.https.CallableContext) => {
  const displayName: string = data.displayName
  const password: string = data.password
  const email: string = data.email
  const phone: any = data.phone

  if (!displayName || !password || !email || !phone) {
    throw new functions.https.HttpsError('cancelled', 'user-create-failed', 'missing information')
  }

  try {
    // Creates the auth record
    const authRecord: admin.auth.UserRecord = await admin.auth().createUser({
      displayName: displayName,
      password: password,
      email: email,
      phoneNumber: phone['phone_number']
    })

    const user: string = authRecord.uid
    const dateNow: FirebaseFirestore.Timestamp = admin.firestore.Timestamp.now()
    const inviteCodeDateExpire: Date = moment(dateNow.toDate()).add(5, 'days').startOf('day').toDate()

    // Creates the user record
    await admin.firestore().collection('users').doc(user).set({
      'name': displayName,
      'email': email,
      'phone': {
        'user': user,
        ...phone
      },
      'invite_code': {
        'user': user,
        'code': generateInviteCode(),
        'expire_date': inviteCodeDateExpire.toUTCString()
      }
    })

    // Hasura custom claims
    const customClaims: any = {
      'https://hasura.io/jwt/claims': {
        'x-hasura-default-role': 'user',
        'x-hasura-allowed-roles': ['user'],
        'x-hasura-user-id': user
      }
    }

    await admin.auth().setCustomUserClaims(user, customClaims)
    return authRecord.toJSON()
  } catch (e) {
    throw new functions.https.HttpsError('aborted', 'user-create-failed', JSON.stringify(e, undefined, 2))
  }
})
