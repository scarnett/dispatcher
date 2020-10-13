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
      const config: functions.config.Config = functions.config()
      const twilioClient = new twilio(config.twilio.accountsid, config.twilio.authtoken)
      twilioClient.messages.create({
        to: documentData.inbound_phone,
        from: config.twilio.outbound.phonenumber,
        body: documentData.body
      }, (err: any, data: any) => {
        if (err && data?.errorCode) {
          functions.logger.error(err, data)
        }
      })

      // Deletes the sms document from Firestore
      promises.push(smsDocument.ref.delete())

      return Promise.all(promises)
        .then(() => Promise.resolve('ok'))
        .catch((error: any) => {
          functions.logger.error(error)
          return Promise.resolve('error')
        })
    } catch (error) {
      functions.logger.error(error)
      return Promise.resolve('error')
    }
  })
