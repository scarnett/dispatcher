import * as functions from 'firebase-functions'

const twilio = require('twilio')

/**
 * This observes an sms message being created in the system.
 */
exports = module.exports = functions.firestore
  .document('sms/{documentId}').onCreate(async (smsDocument: functions.firestore.QueryDocumentSnapshot) => {
    try {
      const promises: Array<Promise<any>> = []
      const documentData: FirebaseFirestore.DocumentData = smsDocument.data()

      const twilioClient = new twilio(functions.config().twilio.accountsid, functions.config().twilio.authtoken)
      twilioClient.messages.create({
        to: documentData.inbound_phone,
        from: functions.config().twilio.outbound.phonenumber,
        body: documentData.body
      }, (err: any, data: any) => {
        console.error(err, data)
      })

      return Promise.all(promises)
        .then(() => Promise.resolve('ok'))
        .catch((error: any) => {
          console.error(error)
          return Promise.resolve('error')
        })
    } catch (error) {
      console.error(error)
      return Promise.resolve('error')
    }
  })
