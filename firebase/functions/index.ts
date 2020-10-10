import * as admin from 'firebase-admin'

admin.initializeApp({
  credential: admin.credential.cert(require('./keys/dispatcher-firebase-adminsdk.json'))
})

import * as glob from 'glob'
import camelcase from 'camelcase'
import path from 'path'
import i18n from 'i18n'

const paths: string[] = [
  './auth/*.f.js',         // Auth
  './callable/**/*.f.js',  // HTTP Callables
  './db/**/*.f.js',        // Database
  './endpoint/**/*.f.js',  // HTTP Endpoints
  './schedule/*.f.js'      // Cron
]

i18n.configure({
  locales: ['en'],
  directory: path.join(__dirname, 'locales')
})

for (const _path of paths) {
  const files: string[] = glob.sync(_path, { cwd: __dirname, ignore: `./node_modules/**` })
  for (const file of files) {
    processExport(file)
  }
}

function processExport(file: string) {
  const functionName: string = camelcase(file.slice(0, -5).split('/').join('_')) // Strip off '.f.ts'
  exports[functionName] = require(file)
}
