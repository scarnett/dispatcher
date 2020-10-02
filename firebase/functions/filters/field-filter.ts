import * as admin from 'firebase-admin'
import { Change, EventContext } from 'firebase-functions'
import { isEqual } from 'lodash'

const isEquivalent = (before: any, after: any) => {
  return before && typeof (before.isEqual === 'function')
    ? before.isEqual(after)
    : isEqual(before, after)
}

const conditions = {
  CHANGED: (fieldBefore: any, fieldAfter: any) =>
    (fieldBefore !== undefined) &&
    (fieldAfter !== undefined) &&
    !isEquivalent(fieldBefore, fieldAfter),

  ADDED: (fieldBefore: any, fieldAfter: any) =>
    (fieldBefore === undefined) && fieldAfter,

  REMOVED: (fieldBefore: any, fieldAfter: any) =>
    fieldBefore && (fieldAfter === undefined),

  WRITTEN: (fieldBefore: any, fieldAfter: any) =>
    ((fieldBefore === undefined) && fieldAfter) ||
    (fieldBefore && (fieldAfter === undefined)) ||
    !isEquivalent(fieldBefore, fieldAfter)
}

const field = (
  fieldPath: string | admin.firestore.FieldPath,
  operation: ('ADDED' | 'REMOVED' | 'CHANGED' | 'WRITTEN'),
  handler: (
    change: Change<admin.firestore.DocumentSnapshot>,
    context: EventContext,
  ) => PromiseLike<any> | any,
) => {
  return(change: Change<admin.firestore.DocumentSnapshot>, context: EventContext) => {
    const fieldBefore = change.before.get(fieldPath)
    const fieldAfter = change.after.get(fieldPath)
    return conditions[operation](fieldBefore, fieldAfter)
      ? handler(change, context)
      : Promise.resolve()
  }
}

/**
 * Example:
 * 
 * exports = module.exports = functions.firestore
 *   .document('devices/{documentId}')
 *   .onUpdate(
 *     field('connections', 'CHANGED', (change: functions.Change<FirebaseFirestore.DocumentSnapshot<FirebaseFirestore.DocumentData>>, context: functions.EventContext) => {
 *       functions.logger.log('Will get here only if connections was changed')
 *     })
 *   )
 */
export default field
