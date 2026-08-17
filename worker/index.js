/**
 * Cloudflare Worker — Cloudinary API proxy
 *
 * Routes:  /api/cloudinary/images
 *          /api/cloudinary/videos
 *
 * Proxies requests to the Cloudinary Search API using server-side credentials,
 * then attaches CORS headers so the Flutter Web app can call it from any origin.
 */

const CLOUD_NAME   = 'dxdrm5jjw';
const API_KEY      = '758911877223425';
const API_SECRET   = '-TRqKvDFSRJzQbyBYiz3hIQTTbI';

const CLOUDINARY_SEARCH_URL =
  `https://api.cloudinary.com/v1_1/${CLOUD_NAME}/resources/search`;

const CORS_HEADERS = {
  'Access-Control-Allow-Origin':  '*',
  'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization',
};

export default {
  async fetch(request, env, ctx) {
    const url = new URL(request.url);

    // ── Handle preflight ────────────────────────────────────────────────────
    if (request.method === 'OPTIONS') {
      return new Response(null, { headers: CORS_HEADERS });
    }

    // ── Route: /api/cloudinary/images ───────────────────────────────────────
    if (url.pathname === '/api/cloudinary/images') {
      return proxySearch('resource_type:image', 50);
    }

    // ── Route: /api/cloudinary/videos ───────────────────────────────────────
    if (url.pathname === '/api/cloudinary/videos') {
      return proxySearch('resource_type:video', 30);
    }

    return new Response('Not found', { status: 404, headers: CORS_HEADERS });
  },
};

async function proxySearch(expression, maxResults) {
  const credentials = btoa(`${API_KEY}:${API_SECRET}`);

  const body = JSON.stringify({
    expression,
    sort_by: [{ created_at: 'desc' }],
    max_results: maxResults,
    fields: [
      'public_id', 'secure_url', 'resource_type',
      'bytes', 'created_at', 'format',
      'width', 'height', 'duration',
    ],
  });

  const cloudinaryResp = await fetch(CLOUDINARY_SEARCH_URL, {
    method: 'POST',
    headers: {
      'Authorization': `Basic ${credentials}`,
      'Content-Type':  'application/json',
    },
    body,
  });

  const data = await cloudinaryResp.text();

  return new Response(data, {
    status: cloudinaryResp.status,
    headers: {
      ...CORS_HEADERS,
      'Content-Type': 'application/json',
    },
  });
}
