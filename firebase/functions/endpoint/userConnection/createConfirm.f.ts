import * as functions from 'firebase-functions'
import * as admin from 'firebase-admin'
import { hasuraClient } from '../../graphql/graphql-client'

exports = module.exports = functions.https.onRequest(async (req: functions.https.Request, res: functions.Response<any>) => {
  if (req.method !== 'POST') {
    res.status(400).send(`invalid method ${req.method}`)
    return
  }

  const config: functions.config.Config = functions.config()
  const headers: any = req.headers
  if (headers.authorization !== config.hasura.auth.key) {
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
      res.status(500).send('Bad response')
      return
    }

    const dateNow: FirebaseFirestore.Timestamp = admin.firestore.Timestamp.now()
    const users: any[] = response.users
    if (users.length !== 2) {
      res.status(500).send('Bad response')
      return
    }

    const user: any = users[0]
    const connectUser: any = users[1]

    // Creates the sms record
    await admin.firestore().collection('sms').add({
      'user': user.identifier,
      'inbound_phone': user.user_phone_number.phone_number,
      'body': `You successfully connected with ${connectUser.name}!`, // TODO! i18n
      'sent_date': dateNow
    })

    res.status(200).send('ok')
    return
  } catch (e) {
    res.status(500).send(JSON.stringify(e, undefined, 2))
    return
  }
})
