import * as functions from 'firebase-functions'
import * as admin from 'firebase-admin'
import { hasuraClient } from '../../graphql/graphql-client'

/**
 * This observes a user record being created in the system.
 */
exports = module.exports = functions.firestore
  .document('users/{userId}').onCreate(async (userDocument: functions.firestore.QueryDocumentSnapshot) => {
    try {
      const userData: FirebaseFirestore.DocumentData = userDocument.data()
      const userIdentifier: string = userDocument.id

      try {
        const endpoint: string = functions.config().graphql.endpoint
        const adminSecret: string = functions.config().hasura.admin.secret

        // GraphQL mutation for inserting the new user
        const mutation: string = `mutation ($identifier: String!, $name: String!, $email: String!, $phone: user_phone_numbers_insert_input!, $invite_code: user_invite_codes_insert_input!, $key: user_keys_insert_input!) {
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
            object: $key
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
        await hasuraClient(endpoint, adminSecret).request(mutation, {
          identifier: userIdentifier,
          name: userData['name'],
          email: userData['email'],
          phone: userData['phone'],
          invite_code: userData['invite_code'],
          key: userData['key']
        })

        // Deletes the user document from Firestore
        await admin.firestore().collection('users').doc(userIdentifier).delete()
      } catch (e) {
        console.error(e)
        return Promise.resolve('error')
      }

      return Promise.resolve('ok')
    } catch (error) {
      console.error(error)
      return Promise.resolve('error')
    }
  })
