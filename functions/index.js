// index.js
const {onSchedule} = require("firebase-functions/v2/scheduler");
const admin = require("firebase-admin");
const {logger} = require("firebase-functions");
const {setGlobalOptions} = require("firebase-functions/v2");
const {DateTime} = require("luxon");

setGlobalOptions({region: "us-central1"});

logger.info(
    "Cloud Function: Iniciando el proceso de inicialización.",
    {structuredData: true},
);

try {
  if (!admin.apps.length) {
    admin.initializeApp();
    logger.info(
        "Cloud Function: Firebase Admin SDK inicializado.",
        {structuredData: true},
    );
  } else {
    logger.info(
        "Cloud Function: Firebase Admin SDK ya inicializado.",
        {structuredData: true},
    );
  }
} catch (e) {
  logger.error(
      "Cloud Function: Error durante la inicialización:",
      e,
      {structuredData: true},
  );
  throw e;
}

const db = admin.firestore();
logger.info(
    "Cloud Function: Referencia a Firestore obtenida.",
    {structuredData: true},
);

/**
 * Envía notificaciones diarias a usuarios según su zona horaria
 */
exports.sendDailyDevotionalNotification = onSchedule({
  schedule: "0 * * * *",
  timeZone: "UTC",
}, async (context) => {
  logger.info(
      "Cloud Function: sendDailyDevotionalNotification iniciada.",
      {structuredData: true},
  );

  const devotionalTitle = "Pruebas Cerradas Google Play Store";
  const devotionalBody = "¡Recuerda conectarte hoy con la palabra de Dios!";

  logger.info(
      "Cloud Function: Consultando usuarios en Firestore.",
      {structuredData: true},
  );
  const usersRef = db.collection("users");
  const usersSnapshot = await usersRef.get();

  if (usersSnapshot.empty) {
    logger.info(
        "Cloud Function: No se encontraron usuarios.",
        {structuredData: true},
    );
    return null;
  }
  logger.info(
      `Cloud Function: ${usersSnapshot.size} usuarios encontrados.`,
      {structuredData: true},
  );

  const nowUtc = DateTime.now().setZone("UTC");
  logger.info(
      `Cloud Function: Hora UTC: ${nowUtc.toFormat("HH:mm")}.`,
      {structuredData: true},
  );

  for (const userDoc of usersSnapshot.docs) {
    const userId = userDoc.id;
    logger.info(
        `Cloud Function: Procesando usuario: ${userId}.`,
        {structuredData: true},
    );

    const settingsRef = db.collection("users")
        .doc(userId).collection("settings").doc("notifications");
    let settingsDoc;
    try {
      settingsDoc = await settingsRef.get();
    } catch (e) {
      logger.error(
          `Cloud Function: Error obteniendo config de ${userId}:`,
          e,
          {structuredData: true},
      );
      continue;
    }

    if (settingsDoc.exists) {
      const settingsData = settingsDoc.data();
      const notificationsEnabled = settingsData.notificationsEnabled;
      const notificationTimeStr = settingsData.notificationTime;
      const userTimezoneStr = settingsData.userTimezone;
      const lastNotificationSentTimestamp =
        settingsData.lastNotificationSentDate;

      logger.info(
          `Cloud Function: ${userId} - Habilitado: ` +
        `${notificationsEnabled}, Hora: ${notificationTimeStr}, ` +
        `TZ: ${userTimezoneStr}.`,
          {structuredData: true},
      );

      if (!notificationsEnabled || !userTimezoneStr) {
        logger.info(
            `Cloud Function: ${userId} no elegible ` +
          `(deshabilitado o sin TZ).`,
            {structuredData: true},
        );
        continue;
      }

      let userLocalTime;
      try {
        if (!DateTime.local().setZone(userTimezoneStr).isValid) {
          logger.warn(
              `Cloud Function: TZ inválida ${userId}: ` +
            `${userTimezoneStr}.`,
              {structuredData: true},
          );
          continue;
        }
        userLocalTime = nowUtc.setZone(userTimezoneStr);
      } catch (e) {
        logger.error(
            `Cloud Function: Error TZ ${userId} ` +
          `(${userTimezoneStr}): ${e.message}.`,
            {structuredData: true},
        );
        continue;
      }

      const [preferredHour, preferredMinute] =
        notificationTimeStr.split(":").map(Number);
      if (isNaN(preferredHour) || isNaN(preferredMinute)) {
        logger.warn(
            `Cloud Function: Hora inválida ${userId}: ` +
          `${notificationTimeStr}.`,
            {structuredData: true},
        );
        continue;
      }

      const todayInUserTimezone = userLocalTime.toISODate();

      let lastSentDate = null;
      if (lastNotificationSentTimestamp instanceof
          admin.firestore.Timestamp) {
        lastSentDate = DateTime.fromJSDate(
            lastNotificationSentTimestamp.toDate(),
            {zone: userTimezoneStr},
        ).toISODate();
      } else if (typeof lastNotificationSentTimestamp === "string") {
        lastSentDate = lastNotificationSentTimestamp;
      }

      const isTimeToSend = (userLocalTime.hour === preferredHour);
      const alreadySentToday = (lastSentDate === todayInUserTimezone);

      logger.info(
          `Cloud Function: ${userId} - ` +
        `Hora local: ${userLocalTime.toFormat("HH:mm")}, ` +
        `Preferida: ${notificationTimeStr}, ` +
        `Último: ${lastSentDate || "Nunca"}, ` +
        `Hoy: ${todayInUserTimezone}, ` +
        `Enviado hoy: ${alreadySentToday}, ` +
        `Es hora: ${isTimeToSend}.`,
          {structuredData: true},
      );

      if (isTimeToSend && !alreadySentToday) {
        logger.info(
            `Cloud Function: ${userId} elegible. Recopilando tokens.`,
            {structuredData: true},
        );
        const fcmTokensRef = db.collection("users")
            .doc(userId).collection("fcmTokens");
        const fcmTokensSnapshot = await fcmTokensRef.get();

        if (!fcmTokensSnapshot.empty) {
          const tokens = fcmTokensSnapshot.docs.map((doc) => doc.id);

          if (tokens.length === 0) {
            logger.warn(
                `Cloud Function: Sin tokens FCM para ${userId}.`,
                {structuredData: true},
            );
            continue;
          }

          const message = {
            notification: {
              title: devotionalTitle,
              body: devotionalBody,
            },
            data: {
              userId: userId,
              notificationType: "daily_devotional",
            },
            tokens: tokens,
          };

          const response =
            await admin.messaging().sendEachForMulticast(message);
          logger.info(
              `Cloud Function: Enviadas a ${response.successCount} ` +
            `dispositivos. Fallaron ${response.failureCount}.`,
              {structuredData: true},
          );

          await settingsRef.update({
            lastNotificationSentDate:
              admin.firestore.Timestamp.fromDate(userLocalTime.toJSDate()),
          });
          logger.info(
              `Cloud Function: lastNotificationSentDate ` +
            `actualizado para ${userId}.`,
              {structuredData: true},
          );

          if (response.failureCount > 0) {
            response.responses.forEach(async (resp, idx) => {
              if (!resp.success &&
                  (resp.error?.code === "messaging/invalid-argument" ||
                   resp.error?.code ===
                     "messaging/registration-token-not-registered")) {
                const invalidToken = tokens[idx];
                logger.warn(
                    `Cloud Function: Token inválido ${userId}: ` +
                  `${invalidToken}.`,
                    {structuredData: true},
                );
                await db.collection("users").doc(userId)
                    .collection("fcmTokens").doc(invalidToken).delete();
              }
            });
          }
        } else {
          logger.warn(
              `Cloud Function: ${userId} sin tokens FCM.`,
              {structuredData: true},
          );
        }
      } else {
        logger.info(
            `Cloud Function: ${userId} no elegible en esta ejecución.`,
            {structuredData: true},
        );
      }
    } else {
      logger.info(
          `Cloud Function: ${userId} sin config de notificaciones.`,
          {structuredData: true},
      );
    }
  }

  logger.info(
      "Cloud Function: sendDailyDevotionalNotification finalizada.",
      {structuredData: true},
  );
  return null;
});

/**
 * Limpia tokens FCM inválidos cada 24 horas
 */
exports.cleanupInvalidFCMTokens = onSchedule({
  schedule: "every 24 hours",
  timeZone: "UTC",
}, async (context) => {
  logger.info(
      "Cloud Function: Iniciando limpieza de tokens FCM.",
      {structuredData: true},
  );

  const tokensToDelete = [];

  try {
    const usersSnapshot = await db.collection("users").get();

    const allTokens = [];
    for (const userDoc of usersSnapshot.docs) {
      const userId = userDoc.id;
      const fcmTokensSnapshot = await db.collection("users")
          .doc(userId).collection("fcmTokens").get();
      fcmTokensSnapshot.docs.forEach((tokenDoc) => {
        const tokenData = tokenDoc.data();
        if (tokenData.token) {
          allTokens.push({
            token: tokenData.token,
            ref: tokenDoc.ref,
          });
        }
      });
    }

    if (allTokens.length === 0) {
      logger.info(
          "Cloud Function: No hay tokens FCM para limpiar.",
          {structuredData: true},
      );
      return null;
    }

    logger.info(
        `Cloud Function: ${allTokens.length} tokens a verificar.`,
        {structuredData: true},
    );

    const tokensChunks = [];
    for (let i = 0; i < allTokens.length; i += 500) {
      tokensChunks.push(allTokens.slice(i, i + 500).map((t) => t.token));
    }

    for (const chunk of tokensChunks) {
      const message = {
        data: {
          type: "cleanup_check",
          timestamp: new Date().toISOString(),
        },
        tokens: chunk,
      };

      try {
        const response =
          await admin.messaging().sendEachForMulticast(message);
        logger.info(
            `Cloud Function: Respuesta FCM: ` +
          `${response.successCount} OK, ` +
          `${response.failureCount} fallidos.`,
            {structuredData: true},
        );

        response.responses.forEach((resp, index) => {
          if (!resp.success) {
            const failedToken = chunk[index];
            const tokenRef =
              allTokens.find((t) => t.token === failedToken)?.ref;
            if (tokenRef) {
              tokensToDelete.push(tokenRef);
            }
            logger.warn(
                `Cloud Function: Token inválido: ${failedToken} - ` +
              `Error: ${resp.error?.message}.`,
                {structuredData: true},
            );
          }
        });
      } catch (error) {
        logger.error(
            "Cloud Function: Error enviando a chunk:",
            error,
            {structuredData: true},
        );
      }
    }

    if (tokensToDelete.length > 0) {
      const batch = db.batch();
      tokensToDelete.forEach((tokenRef) => {
        batch.delete(tokenRef);
      });
      await batch.commit();
      logger.info(
          `Cloud Function: ${tokensToDelete.length} tokens eliminados.`,
          {structuredData: true},
      );
    } else {
      logger.info(
          "Cloud Function: No hay tokens inválidos que eliminar.",
          {structuredData: true},
      );
    }

    logger.info(
        "Cloud Function: Limpieza de tokens completada.",
        {structuredData: true},
    );
  } catch (error) {
    logger.error(
        "Cloud Function: Error en limpieza de tokens:",
        error,
        {structuredData: true},
    );
  }

  return null;
});
