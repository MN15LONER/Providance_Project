import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

// Initialize admin app
admin.initializeApp();

type NotificationData = {
  userId: string;
  title: string;
  message: string;
  type: string;
  relatedId: string;
  additionalData?: Record<string, unknown>;
  isRead: boolean;
  timestamp: admin.firestore.Timestamp;
}

type BulkNotificationData = {
  userIds: string[];
  title: string;
  body: string;
  type: string;
  relatedId: string;
  additionalData?: Record<string, unknown>;
}

type MessagingDeviceResult = {
  error?: {
    code: string;
  };
}

// Function to send FCM notification
export const sendNotification = functions.firestore
  .document('notifications/{notificationId}')
  .onCreate(async (snapshot: functions.firestore.QueryDocumentSnapshot, context: functions.EventContext) => {
    try {
      const notificationData = snapshot.data() as NotificationData;
      const userId = notificationData.userId;

      // Get user's FCM tokens
      const userDoc = await admin.firestore()
        .collection('users')
        .doc(userId)
        .get();

      const userData = userDoc.data();
      if (!userData) return;

      const tokens = userData.notificationTokens as string[] || [];
      if (tokens.length === 0) return;

      // Create notification message
      const message: admin.messaging.MulticastMessage = {
        notification: {
          title: notificationData.title,
          body: notificationData.message,
        },
        data: {
          type: notificationData.type,
          relatedId: notificationData.relatedId,
          ...(notificationData.additionalData as Record<string, string> || {}),
        },
        tokens,
      };

      // Send to all user's devices
      const response = await admin.messaging().sendMulticast(message);

      // Clean up invalid tokens
      const invalidTokens = response.responses
        .map((result: admin.messaging.SendResponse, index: number): string | null => {
          return result.error?.code === 'messaging/invalid-registration-token' ||
                 result.error?.code === 'messaging/registration-token-not-registered'
            ? tokens[index]
            : null;
        })
        .filter((token: string | null): token is string => token !== null);

      if (invalidTokens.length > 0) {
        // Remove invalid tokens from user's document
        await admin.firestore()
          .collection('users')
          .doc(userId)
          .update({
            notificationTokens: admin.firestore.FieldValue.arrayRemove(...invalidTokens),
          });
      }
    } catch (error) {
      console.error('Error sending notification:', error);
    }
  });

// Function to send notification to multiple users
export const sendBulkNotification = functions.https.onCall(async (data: BulkNotificationData, context: functions.https.CallableContext) => {
  if (!context.auth?.uid) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'Must be authenticated to send notifications'
    );
  }

  try {
    const { userIds, title, body, type, relatedId, additionalData } = data;

    // Create notification message
    const message: admin.messaging.MulticastMessage = {
      notification: {
        title,
        body,
      },
      data: {
        type,
        relatedId,
        ...(additionalData as Record<string, string> || {}),
      },
      tokens: [], // Will be set after fetching tokens
    };

    // Get all users' FCM tokens
    const usersSnapshot = await admin.firestore()
      .collection('users')
      .where(admin.firestore.FieldPath.documentId(), 'in', userIds)
      .get();

    const tokens = usersSnapshot.docs
      .map((doc: admin.firestore.QueryDocumentSnapshot) => (doc.data().notificationTokens as string[]) || [])
      .flat();

    if (tokens.length === 0) return;

    // Set tokens and send
    message.tokens = tokens;
    await admin.messaging().sendMulticast(message);

  } catch (error) {
    console.error('Error sending bulk notification:', error);
    throw new functions.https.HttpsError('internal', 'Error sending notification');
  }
});