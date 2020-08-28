import * as admin from 'firebase-admin'
import * as functions from 'firebase-functions'
import { generateInviteCode } from '../../utils/device_utils'
import moment = require('moment')

/**
 * This observes a device being created in the system.
 */
exports = module.exports = functions.firestore
  .document('devices/{documentId}').onCreate(async (deviceDocument: functions.firestore.QueryDocumentSnapshot) => {
    const promises: Array<Promise<any>> = []
    const dateNow: FirebaseFirestore.Timestamp = admin.firestore.Timestamp.now()
    const dateExpire: Date = moment(dateNow.toDate()).add(5, 'days').startOf('day').toDate()

    // Update the device document
    promises.push(deviceDocument.ref.update({
      'id': deviceDocument.id,
      'invite_code': {
        'code': generateInviteCode(),
        'expire_date': admin.firestore.Timestamp.fromDate(dateExpire)
      },
      'registered_date': dateNow
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
