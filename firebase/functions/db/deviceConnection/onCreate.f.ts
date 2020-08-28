import * as admin from 'firebase-admin'
import * as functions from 'firebase-functions'

/**
 * This observes a device connection being created in the system.
 */
exports = module.exports = functions.firestore
  .document('devices/{documentId}/connections/{connectionId}').onCreate(async (connectionDocument: functions.firestore.QueryDocumentSnapshot) => {
    const promises: Array<Promise<any>> = []

    // Update the connection document
    promises.push(connectionDocument.ref.update({
      'id': connectionDocument.id,
      'connected_date': admin.firestore.Timestamp.now()
    }))

    try {
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
