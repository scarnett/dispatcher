import * as functions from 'firebase-functions'
import * as admin from 'firebase-admin'

exports = module.exports = functions.https.onCall(async (data: any, context: functions.https.CallableContext) => {
  const sms: any = data.sms
  if (!sms) {
    throw new functions.https.HttpsError('cancelled', 'sms-send-failed', 'missing information')
  }

  try {
    // Creates the sms record
    await admin.firestore().collection('sms').add({
      'user': sms['user'],
      'inbound_phone': sms['inbound_phone'],
      'body': sms['body'],
      'sent_date': sms['sent_date']
    })

    return {success: true}
  } catch (e) {
    throw new functions.https.HttpsError('aborted', 'sms-send-failed', JSON.stringify(e, undefined, 2))
  }
})
