import * as functions from 'firebase-functions'
import * as admin from 'firebase-admin'

admin.initializeApp({
  credential: admin.credential.cert(require('./keys/dispatcher-firebase-adminsdk.json'))
})

import * as glob from 'glob'
import camelcase from 'camelcase'
import * as httpUtils from './utils/http_utils'

const paths: string[] = [
  './auth/*.f.js',         // Auth
  './callable/**/*.f.js',  // HTTP Callables
  './db/**/*.f.js',        // Database
  './schedule/*.f.js'      // Cron
]

for (const path of paths) {
  const files: string[] = glob.sync(path, { cwd: __dirname, ignore: `./node_modules/**` })
  for (const file of files) {
    processExport(file)
  }
}

// Set up the http endpoints
exports.endpoints = functions.https.onRequest(httpUtils.appEndpoints)

function processExport(file: string) {
  const functionName: string = camelcase(file.slice(0, -5).split('/').join('_')) // Strip off '.f.ts'
  exports[functionName] = require(file)
}
