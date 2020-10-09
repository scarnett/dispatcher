// TODO! This should check for a unique value
export function generateInviteCode(count: number = 6): string {
  let result: string = ''
  const chars: string = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'

  for (let i = 0; i < count; i++) {
     result += chars.charAt(Math.floor(Math.random() * chars.length))
  }

  return result
}
