import * as functions from 'firebase-functions'
import * as admin from 'firebase-admin'
import { hasuraClient } from '../../graphql/graphql-client'
import i18n from 'i18n'

exports = module.exports = functions.https.onRequest(async (req: functions.https.Request, res: functions.Response<any>) => {
  if (req.method !== 'POST') {
    res.status(400).send(`Invalid method ${req.method}`)
    return
  }

  const config: functions.config.Config = functions.config()
  const headers: any = req.headers
  if (headers.authorization !== config.hasura.auth.key) {
    res.status(404).send('Unkonwn error')
    return
  }

  // GraphQL query for getting a user
  const userQuery: string = `query($identifiers: [String!]) {
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
    const response: any = await hasuraClient(endpoint, adminSecret)
      .request(userQuery, {
        identifiers: [
          newConnectionRecord.user,
          newConnectionRecord.connect_user
        ]
      })

    if (!response) {
      res.status(500).send('Bad response')
      return
    }

    const users: any[] = response.users
    if (users.length !== 2) {
      res.status(500).send('Bad response')
      return
    }

    const promises: Array<Promise<any>> = []
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
    promises.push(admin
      .messaging()
      .sendToDevice(user.user_fcm.token, payload))

    return Promise.all(promises)
      .then(() => {
        res.status(200).send('ok')
        return
      })
      .catch((error: any) => {
        functions.logger.error(error)
        res.status(500).send(JSON.stringify(error, undefined, 2))
        return
      })
  } catch (e) {
    functions.logger.error(e)
    res.status(500).send(JSON.stringify(e, undefined, 2))
    return
  }
})
