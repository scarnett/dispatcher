import * as functions from 'firebase-functions'
import { hasuraClient } from '../../graphql/graphql-client'

exports = module.exports = functions.https.onCall(async (data: any, context: functions.https.CallableContext) => {
  const identifier: string = data.identifier
  const avatarUrl: string = data.avatarUrl
  const avatarPath: string = data.avatarPath
  const avatarThumbUrl: string = data.avatarThumbUrl
  const avatarThumbPath: string = data.avatarThumbPath

  if (!identifier) {
    throw new functions.https.HttpsError('cancelled', 'user-avatar-upsert-failed', 'missing information')
  }

  // GraphQL mutation for inserting or updating (upserting) a user avatar
  const mutation: string = `mutation($identifier: String!, $url: String, $thumbUrl: String, $path: String, $thumbPath: String) {
    insert_user_avatars(
      objects: [
        {
          user: $identifier,
          url: $url,
          thumb_url: $thumbUrl,
          path: $path,
          thumb_path: $thumbPath
        }
      ],
      on_conflict: {
        constraint: user_avatars_user_key,
        update_columns: [url, thumb_url, path, thumb_path]
      }
    ) {
      affected_rows
    }
  }`

  try {
    const config: functions.config.Config = functions.config()
    const endpoint: string = config.graphql.endpoint
    const adminSecret: string = config.hasura.admin.secret
    const response: any = await hasuraClient(endpoint, adminSecret)
      .request(mutation, {
        identifier: identifier,
        url: avatarUrl,
        path: avatarPath,
        thumbUrl: avatarThumbUrl,
        thumbPath: avatarThumbPath
      })

    return response
  } catch (e) {
    throw new functions.https.HttpsError('aborted', 'user-avatar-upsert-failed', JSON.stringify(e, undefined, 2))
  }
})
