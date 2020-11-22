import * as functions from 'firebase-functions'
import { hasuraClient } from '../../graphql/graphql-client'

/**
 * This observes a user record being created in the system.
 */
exports = module.exports = functions.firestore
  .document('users/{identifier}').onCreate(async (userDocument: functions.firestore.QueryDocumentSnapshot) => {
    try {
      const promises: Array<Promise<any>> = []
      const userData: FirebaseFirestore.DocumentData = userDocument.data()
      const userIdentifier: string = userDocument.id

      try {
        const config: functions.config.Config = functions.config()
        const endpoint: string = config.graphql.endpoint
        const adminSecret: string = config.hasura.admin.secret

        // GraphQL mutation for inserting the new user
        const mutation: string = `mutation ($identifier: String!, $name: String!, $email: String!, $phone: user_phone_numbers_insert_input!, $invite_code: user_invite_codes_insert_input!, $fcm: user_fcms_insert_input!) {
          insert_user_phone_numbers_one(
            object: $phone
          ) {
            dial_code
            iso_code
            phone_number
          }
          
          insert_user_invite_codes_one(
            object: $invite_code
          ) {
            code
            expire_date
          }
          
          insert_user_keys_one(
            object: {
              user: $identifier
            }
          ) {
            user
          }
          
          insert_user_fcms_one(
            object: $fcm
          ) {
            user
          }
          
          insert_user_avatars_one(
            object: {
              user: $identifier
            }
          ) {
            user
          }
          
          insert_user_pins_one(
            object: {
              user: $identifier
            }
          ) {
            user
          }
          
          insert_users_one(
            object: {
              identifier: $identifier,
              name: $name,
              email: $email
            }
          ) {
            name
            email
          }
        }`

        // Post the mutation to Hasura GraphQL
        promises.push(hasuraClient(endpoint, adminSecret).request(mutation, {
          identifier: userIdentifier,
          name: userData['name'],
          email: userData['email'],
          phone: userData['phone'],
          invite_code: userData['invite_code'],
          key: userData['key'],
          fcm: userData['fcm']
        }))

        // Deletes the user document from Firestore
        promises.push(userDocument.ref.delete())
      } catch (e) {
        functions.logger.error(e)
        return Promise.resolve('error')
      }

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
