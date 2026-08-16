import { RtcRole, RtcTokenBuilder } from 'agora-token';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'Content-Type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Content-Type': 'application/json; charset=utf-8',
};
const tokenLifetimeSeconds = 60 * 60;

function json(body, status = 200) {
  return new Response(JSON.stringify(body), {status, headers: corsHeaders});
}

export default {
  async fetch(request, env) {
    if (request.method === 'OPTIONS') {
      return new Response(null, {status: 204, headers: corsHeaders});
    }
    if (request.method !== 'POST') {
      return json({error: 'POST is required.'}, 405);
    }

    try {
      const {roomId, channelName, uid} = await request.json();
      if (
        typeof roomId !== 'string' ||
        !roomId.startsWith('meet-') ||
        typeof channelName !== 'string' ||
        !channelName.startsWith('idrak_meet_') ||
        !Number.isInteger(uid) ||
        uid < 1 ||
        uid > 0xffffffff
      ) {
        return json({error: 'Invalid room connection request.'}, 400);
      }
      if (!env.AGORA_APP_CERTIFICATE) {
        return json({error: 'Voice service is not configured.'}, 503);
      }

      const token = RtcTokenBuilder.buildTokenWithUid(
        env.AGORA_APP_ID,
        env.AGORA_APP_CERTIFICATE,
        channelName,
        uid,
        RtcRole.PUBLISHER,
        tokenLifetimeSeconds,
        tokenLifetimeSeconds,
      );
      return json({token, expiresIn: tokenLifetimeSeconds});
    } catch (error) {
      console.error('Unable to create Agora token', error);
      return json({error: 'Unable to prepare the voice connection.'}, 500);
    }
  },
};
