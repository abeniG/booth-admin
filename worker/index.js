/**
 * Cloudflare Worker — Cloudinary API proxy
 *
 * Routes:
 *   GET    /api/cloudinary/images
 *   GET    /api/cloudinary/videos
 *   DELETE /api/cloudinary/delete?publicId=<id>&resourceType=image|video
 */

const CLOUD_NAME = 'dxdrm5jjw';
const API_KEY    = '758911877223425';
const API_SECRET = '-TRqKvDFSRJzQbyBYiz3hIQTTbI';

const CLOUDINARY_SEARCH_URL =
  `https://api.cloudinary.com/v1_1/${CLOUD_NAME}/resources/search`;

const CORS_HEADERS = {
  'Access-Control-Allow-Origin':  '*',
  'Access-Control-Allow-Methods': 'GET, POST, DELETE, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization',
};

export default {
  async fetch(request, env, ctx) {
    const url = new URL(request.url);

    if (request.method === 'OPTIONS') {
      return new Response(null, { headers: CORS_HEADERS });
    }

    if (url.pathname === '/api/cloudinary/images') {
      return proxySearch('resource_type:image', 50);
    }

    if (url.pathname === '/api/cloudinary/videos') {
      return proxySearch('resource_type:video', 30);
    }

    // DELETE /api/cloudinary/delete?publicId=xxx&resourceType=image
    if (url.pathname === '/api/cloudinary/delete' && request.method === 'DELETE') {
      const publicId     = url.searchParams.get('publicId');
      const resourceType = url.searchParams.get('resourceType') || 'image';
      if (!publicId) {
        return new Response(JSON.stringify({ error: 'publicId is required' }), {
          status: 400,
          headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' },
        });
      }
      return deleteResource(publicId, resourceType);
    }

    return new Response('Not found', { status: 404, headers: CORS_HEADERS });
  },
};

// ── Search ────────────────────────────────────────────────────────────────────

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

  const resp = await fetch(CLOUDINARY_SEARCH_URL, {
    method: 'POST',
    headers: {
      'Authorization': `Basic ${btoa(`${API_KEY}:${API_SECRET}`)}`,
      'Content-Type': 'application/json',
    },
    body,
  });

  return new Response(await resp.text(), {
    status: resp.status,
    headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' },
  });
}

// ── Delete (signed) ───────────────────────────────────────────────────────────

async function deleteResource(publicId, resourceType) {
  const timestamp = Math.floor(Date.now() / 1000).toString();

  // Cloudinary requires a SHA-1 signature of sorted params + secret
  const toSign  = `public_id=${publicId}&timestamp=${timestamp}${API_SECRET}`;
  const signature = await sha1Hex(toSign);

  const formData = new FormData();
  formData.append('public_id', publicId);
  formData.append('timestamp', timestamp);
  formData.append('api_key',   API_KEY);
  formData.append('signature', signature);

  const destroyUrl =
    `https://api.cloudinary.com/v1_1/${CLOUD_NAME}/${resourceType}/destroy`;
  const resp = await fetch(destroyUrl, { method: 'POST', body: formData });

  return new Response(await resp.text(), {
    status: resp.status,
    headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' },
  });
}

async function sha1Hex(message) {
  const buf    = new TextEncoder().encode(message);
  const hash   = await crypto.subtle.digest('SHA-1', buf);
  return Array.from(new Uint8Array(hash))
    .map(b => b.toString(16).padStart(2, '0'))
    .join('');
}
