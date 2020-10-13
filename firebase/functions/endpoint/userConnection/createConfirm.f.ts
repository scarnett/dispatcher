import * as functions from 'firebase-functions'
import * as admin from 'firebase-admin'
import { hasuraClient } from '../../graphql/graphql-client'
import i18n from 'i18n'

exports = module.exports = functions.https.onRequest(async (req: functions.https.Request, res: functions.Response<any>) => {
  if (req.method !== 'POST') {
    functions.logger.error(`Invalid method ${req.method}`)
    res.status(400).send(`Invalid method ${req.method}`)
    return
  }

  const config: functions.config.Config = functions.config()
  const headers: any = req.headers
  if (headers.authorization !== config.hasura.auth.key) {
    functions.logger.error('Unkonwn error')
    res.status(404).send('Unkonwn error')
    return
  }

  // GraphQL query for getting a user
  const query: string = `query($identifiers: [String!]) {
    users(where: {identifier: {_in: $identifiers}}) {
      identifier
      name
      email
      user_phone_number {
        dial_code
        iso_code
        phone_number
      }
      user_fcm {
        token
      }
    }
  }`

  try {
    const newConnectionRecord: any = req.body.event.data.new
    const endpoint: string = config.graphql.endpoint
    const adminSecret: string = config.hasura.admin.secret

    // Query the user records
    const response: any = await hasuraClient(endpoint, adminSecret).request(query, {
      identifiers: [
        newConnectionRecord.user,
        newConnectionRecord.connect_user
      ]
    })

    if (!response) {
      functions.logger.error('Bad response')
      res.status(500).send('Bad response')
      return
    }

    const users: any[] = response.users
    if (users.length !== 2) {
      //functions.logger.error(`Bad user size. Should be 2 but found ${users.length}`)
      //res.status(500).send('Bad response')
      //return
    }

    const user: any = users.find(_user => _user.identifier === newConnectionRecord.user)
    const connectUser: any = users.find(_user => _user.identifier === newConnectionRecord.connect_user)
    const payload: admin.messaging.MessagingPayload = {
      notification: {
        title: 'Connection Success',
        body: i18n.__('You were successfully connected to {{name}} on Dispatcher!', { name: connectUser.name }),
        badge: '1',
        sound: 'default'
      },
      data: {
        click_action: 'FLUTTER_NOTIFICATION_CLICK'
      }
    }

    // Send a push message
    admin
      .messaging()
      .sendToDevice(user.user_fcm.token, payload)
      .then((_res: admin.messaging.MessagingDevicesResponse) => {
        functions.logger.log(`Successfully sent push message: ${JSON.stringify(_res)}`)
      })
      .catch((error: any) => {
        functions.logger.error(`Error sending push message: ${error}`)
      })

    res.status(200).send('ok')
    return
  } catch (e) {
    functions.logger.error(e)
    res.status(500).send(JSON.stringify(e, undefined, 2))
    return
  }
})
