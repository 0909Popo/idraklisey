const {onRequest} = require("firebase-functions/v2/https");
const {defineSecret} = require("firebase-functions/params");
const admin = require("firebase-admin");
const {RtcTokenBuilder, RtcRole} = require("agora-token");

admin.initializeApp();

const agoraCertificate = defineSecret("AGORA_APP_CERTIFICATE");
const agoraAppId = "f113f5bf3611409c99284b03e00d5a26";
const tokenLifetimeSeconds = 60 * 60;

/**
 * Creates a short-lived Agora RTC token for an existing live Meet Idrak room.
 * The certificate remains in Firebase Secret Manager and is never sent to the
 * Flutter app.
 */
exports.meetToken = onRequest(
  {
    region: "europe-west1",
    cors: true,
    secrets: [agoraCertificate],
  },
  async (request, response) => {
    if (request.method !== "POST") {
      response.status(405).json({error: "POST is required."});
      return;
    }

    const {roomId, channelName, uid} = request.body || {};
    if (
      typeof roomId !== "string" ||
      typeof channelName !== "string" ||
      !Number.isInteger(uid) ||
      uid < 1 ||
      uid > 0xffffffff
    ) {
      response.status(400).json({error: "Invalid room connection request."});
      return;
    }

    try {
      const room = await admin.firestore().collection("meet_rooms").doc(roomId).get();
      if (!room.exists) {
        response.status(404).json({error: "Room not found."});
        return;
      }

      const data = room.data();
      if (data.status !== "live" || data.channelName !== channelName) {
        response.status(403).json({error: "This room is not available."});
        return;
      }

      const token = RtcTokenBuilder.buildTokenWithUid(
        agoraAppId,
        agoraCertificate.value(),
        channelName,
        uid,
        RtcRole.PUBLISHER,
        tokenLifetimeSeconds,
        tokenLifetimeSeconds,
      );
      response.status(200).json({token, expiresIn: tokenLifetimeSeconds});
    } catch (error) {
      console.error("Unable to create Meet Idrak token", error);
      response.status(500).json({error: "Unable to prepare the voice connection."});
    }
  },
);
