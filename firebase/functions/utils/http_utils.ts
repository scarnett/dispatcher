import { google } from 'googleapis'
import express from 'express'

const RC_SCOPES = [
  'https://www.googleapis.com/auth/userinfo.email',
  'https://www.googleapis.com/auth/firebase.database',
  'https://www.googleapis.com/auth/androidpublisher'
]

export const appEndpoints = express()

export function getAccessToken() {
  return new Promise((resolve, reject) => {
    const key: any = require('../keys/dispatcher-firebase-adminsdk.json')
    const jwtClient: any = new google.auth.JWT(key.client_email, undefined, key.private_key, RC_SCOPES, undefined)
    jwtClient.authorize((err: any, tokens: any) => {
      if (err) {
        reject(err)
        return
      }

      resolve(tokens.access_token)
    })
  })
}
