import * as functions from 'firebase-functions'
import * as admin from 'firebase-admin'
import { generateInviteCode } from '../../utils/user_utils'
import moment = require('moment')

exports = module.exports = functions.https.onCall(async (data: any, context: functions.https.CallableContext) => {
  const displayName: string = data.display_name
  const password: string = data.password
  const email: string = data.email
  const phone: any = data.phone
  const fcm: any = data.fcm

  if (!displayName || !password || !email || !phone || !fcm) {
    throw new functions.https.HttpsError('cancelled', 'users-create-failed', 'missing information')
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
    const inviteCodeDateExpire: Date = moment(dateNow.toDate()).add(5, 'days').toDate()

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
      },
      'fcm': {
        'user': user,
        ...fcm
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
    throw new functions.https.HttpsError('aborted', 'users-create-failed', JSON.stringify(e, undefined, 2))
  }
})
