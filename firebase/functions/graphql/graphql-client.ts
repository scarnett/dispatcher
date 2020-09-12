import { GraphQLClient } from 'graphql-request'

export const hasuraClient = (endpoint: string, adminSecret: string) => new GraphQLClient(endpoint, {
  headers: {
    'content-type': 'application/json',
    'x-hasura-admin-secret': adminSecret
  }
})
