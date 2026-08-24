var __defProp = Object.defineProperty;
var __name = (target, value) => __defProp(target, "name", { value, configurable: true });

// worker/index.js
var CLOUD_NAME = "dxdrm5jjw";
var API_KEY = "758911877223425";
var API_SECRET = "-TRqKvDFSRJzQbyBYiz3hIQTTbI";
var CLOUDINARY_SEARCH_URL = `https://api.cloudinary.com/v1_1/${CLOUD_NAME}/resources/search`;
var CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, POST, DELETE, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization"
};
var worker_default = {
  async fetch(request, env, ctx) {
    const url = new URL(request.url);
    if (request.method === "OPTIONS") {
      return new Response(null, { headers: CORS_HEADERS });
    }
    if (url.pathname === "/api/cloudinary/images") {
      return proxySearch("resource_type:image", 50);
    }
    if (url.pathname === "/api/cloudinary/videos") {
      return proxySearch("resource_type:video", 30);
    }
    if (url.pathname === "/api/cloudinary/upload" && request.method === "POST") {
      return uploadResource(request);
    }
    if (url.pathname === "/api/cloudinary/delete" && request.method === "DELETE") {
      const publicId = url.searchParams.get("publicId");
      const resourceType = url.searchParams.get("resourceType") || "image";
      if (!publicId) {
        return new Response(JSON.stringify({ error: "publicId is required" }), {
          status: 400,
          headers: { ...CORS_HEADERS, "Content-Type": "application/json" }
        });
      }
      return deleteResource(publicId, resourceType);
    }
    return new Response("Not found", { status: 404, headers: CORS_HEADERS });
  }
};
async function proxySearch(expression, maxResults) {
  const credentials = btoa(`${API_KEY}:${API_SECRET}`);
  const body = JSON.stringify({
    expression,
    sort_by: [{ created_at: "desc" }],
    max_results: maxResults,
    fields: [
      "public_id",
      "secure_url",
      "resource_type",
      "bytes",
      "created_at",
      "format",
      "width",
      "height",
      "duration"
    ]
  });
  const resp = await fetch(CLOUDINARY_SEARCH_URL, {
    method: "POST",
    headers: {
      "Authorization": `Basic ${btoa(`${API_KEY}:${API_SECRET}`)}`,
      "Content-Type": "application/json"
    },
    body
  });
  return new Response(await resp.text(), {
    status: resp.status,
    headers: { ...CORS_HEADERS, "Content-Type": "application/json" }
  });
}
__name(proxySearch, "proxySearch");
async function uploadResource(request) {
  const formData = await request.formData();
  const file = formData.get("file");
  const folder = formData.get("folder");
  if (!(file instanceof File)) {
    return new Response(JSON.stringify({ error: "file is required" }), {
      status: 400,
      headers: { ...CORS_HEADERS, "Content-Type": "application/json" }
    });
  }
  const timestamp = Math.floor(Date.now() / 1e3).toString();
  const signableParams = [`timestamp=${timestamp}`];
  if (typeof folder === "string" && folder.length > 0) {
    signableParams.unshift(`folder=${folder}`);
  }
  const toSign = `${signableParams.join("&")}${API_SECRET}`;
  const signature = await sha1Hex(toSign);
  const uploadForm = new FormData();
  uploadForm.append("file", file);
  uploadForm.append("timestamp", timestamp);
  uploadForm.append("api_key", API_KEY);
  uploadForm.append("signature", signature);
  if (typeof folder === "string" && folder.length > 0) {
    uploadForm.append("folder", folder);
  }
  const uploadUrl = `https://api.cloudinary.com/v1_1/${CLOUD_NAME}/image/upload`;
  const resp = await fetch(uploadUrl, { method: "POST", body: uploadForm });
  return new Response(await resp.text(), {
    status: resp.status,
    headers: { ...CORS_HEADERS, "Content-Type": "application/json" }
  });
}
__name(uploadResource, "uploadResource");
async function deleteResource(publicId, resourceType) {
  const timestamp = Math.floor(Date.now() / 1e3).toString();
  const toSign = `public_id=${publicId}&timestamp=${timestamp}${API_SECRET}`;
  const signature = await sha1Hex(toSign);
  const formData = new FormData();
  formData.append("public_id", publicId);
  formData.append("timestamp", timestamp);
  formData.append("api_key", API_KEY);
  formData.append("signature", signature);
  const destroyUrl = `https://api.cloudinary.com/v1_1/${CLOUD_NAME}/${resourceType}/destroy`;
  const resp = await fetch(destroyUrl, { method: "POST", body: formData });
  return new Response(await resp.text(), {
    status: resp.status,
    headers: { ...CORS_HEADERS, "Content-Type": "application/json" }
  });
}
__name(deleteResource, "deleteResource");
async function sha1Hex(message) {
  const buf = new TextEncoder().encode(message);
  const hash = await crypto.subtle.digest("SHA-1", buf);
  return Array.from(new Uint8Array(hash)).map((b) => b.toString(16).padStart(2, "0")).join("");
}
__name(sha1Hex, "sha1Hex");

// ../../AppData/Local/npm-cache/_npx/38f3295754dfa028/node_modules/wrangler/templates/middleware/middleware-ensure-req-body-drained.ts
var drainBody = /* @__PURE__ */ __name(async (request, env, _ctx, middlewareCtx) => {
  try {
    return await middlewareCtx.next(request, env);
  } finally {
    try {
      if (request.body !== null && !request.bodyUsed) {
        const reader = request.body.getReader();
        while (!(await reader.read()).done) {
        }
      }
    } catch (e) {
      console.error("Failed to drain the unused request body.", e);
    }
  }
}, "drainBody");
var middleware_ensure_req_body_drained_default = drainBody;

// ../../AppData/Local/npm-cache/_npx/38f3295754dfa028/node_modules/wrangler/templates/middleware/middleware-miniflare3-json-error.ts
function reduceError(e) {
  return {
    name: e?.name,
    message: e?.message ?? String(e),
    stack: e?.stack,
    cause: e?.cause === void 0 ? void 0 : reduceError(e.cause)
  };
}
__name(reduceError, "reduceError");
var jsonError = /* @__PURE__ */ __name(async (request, env, _ctx, middlewareCtx) => {
  try {
    return await middlewareCtx.next(request, env);
  } catch (e) {
    const error = reduceError(e);
    const body = JSON.stringify(error);
    const headers = {
      "Content-Type": "application/json",
      "MF-Experimental-Error-Stack": "true"
    };
    const encoded = encodeURIComponent(body);
    if (encoded.length <= 8192) {
      headers["MF-Experimental-Error-Stack-Payload"] = encoded;
    }
    return new Response(body, { status: 500, headers });
  }
}, "jsonError");
var middleware_miniflare3_json_error_default = jsonError;

// .wrangler/tmp/bundle-b3O4eF/middleware-insertion-facade.js
var __INTERNAL_WRANGLER_MIDDLEWARE__ = [
  middleware_ensure_req_body_drained_default,
  middleware_miniflare3_json_error_default
];
var middleware_insertion_facade_default = worker_default;

// ../../AppData/Local/npm-cache/_npx/38f3295754dfa028/node_modules/wrangler/templates/middleware/common.ts
var __facade_middleware__ = [];
function __facade_register__(...args) {
  __facade_middleware__.push(...args.flat());
}
__name(__facade_register__, "__facade_register__");
function __facade_invokeChain__(request, env, ctx, dispatch, middlewareChain) {
  const [head, ...tail] = middlewareChain;
  const middlewareCtx = {
    dispatch,
    next(newRequest, newEnv) {
      return __facade_invokeChain__(newRequest, newEnv, ctx, dispatch, tail);
    }
  };
  return head(request, env, ctx, middlewareCtx);
}
__name(__facade_invokeChain__, "__facade_invokeChain__");
function __facade_invoke__(request, env, ctx, dispatch, finalMiddleware) {
  return __facade_invokeChain__(request, env, ctx, dispatch, [
    ...__facade_middleware__,
    finalMiddleware
  ]);
}
__name(__facade_invoke__, "__facade_invoke__");

// .wrangler/tmp/bundle-b3O4eF/middleware-loader.entry.ts
var __Facade_ScheduledController__ = class ___Facade_ScheduledController__ {
  constructor(scheduledTime, cron, noRetry) {
    this.scheduledTime = scheduledTime;
    this.cron = cron;
    this.#noRetry = noRetry;
  }
  scheduledTime;
  cron;
  static {
    __name(this, "__Facade_ScheduledController__");
  }
  #noRetry;
  noRetry() {
    if (!(this instanceof ___Facade_ScheduledController__)) {
      throw new TypeError("Illegal invocation");
    }
    this.#noRetry();
  }
};
function wrapExportedHandler(worker) {
  if (__INTERNAL_WRANGLER_MIDDLEWARE__ === void 0 || __INTERNAL_WRANGLER_MIDDLEWARE__.length === 0) {
    return worker;
  }
  for (const middleware of __INTERNAL_WRANGLER_MIDDLEWARE__) {
    __facade_register__(middleware);
  }
  const fetchDispatcher = /* @__PURE__ */ __name(function(request, env, ctx) {
    if (worker.fetch === void 0) {
      throw new Error("Handler does not export a fetch() function.");
    }
    return worker.fetch(request, env, ctx);
  }, "fetchDispatcher");
  return {
    ...worker,
    fetch(request, env, ctx) {
      const dispatcher = /* @__PURE__ */ __name(function(type, init) {
        if (type === "scheduled" && worker.scheduled !== void 0) {
          const controller = new __Facade_ScheduledController__(
            Date.now(),
            init.cron ?? "",
            () => {
            }
          );
          return worker.scheduled(controller, env, ctx);
        }
      }, "dispatcher");
      return __facade_invoke__(request, env, ctx, dispatcher, fetchDispatcher);
    }
  };
}
__name(wrapExportedHandler, "wrapExportedHandler");
function wrapWorkerEntrypoint(klass) {
  if (__INTERNAL_WRANGLER_MIDDLEWARE__ === void 0 || __INTERNAL_WRANGLER_MIDDLEWARE__.length === 0) {
    return klass;
  }
  for (const middleware of __INTERNAL_WRANGLER_MIDDLEWARE__) {
    __facade_register__(middleware);
  }
  return class extends klass {
    #fetchDispatcher = /* @__PURE__ */ __name((request, env, ctx) => {
      this.env = env;
      this.ctx = ctx;
      if (super.fetch === void 0) {
        throw new Error("Entrypoint class does not define a fetch() function.");
      }
      return super.fetch(request);
    }, "#fetchDispatcher");
    #dispatcher = /* @__PURE__ */ __name((type, init) => {
      if (type === "scheduled" && super.scheduled !== void 0) {
        const controller = new __Facade_ScheduledController__(
          Date.now(),
          init.cron ?? "",
          () => {
          }
        );
        return super.scheduled(controller);
      }
    }, "#dispatcher");
    fetch(request) {
      return __facade_invoke__(
        request,
        this.env,
        this.ctx,
        this.#dispatcher,
        this.#fetchDispatcher
      );
    }
  };
}
__name(wrapWorkerEntrypoint, "wrapWorkerEntrypoint");
var WRAPPED_ENTRY;
if (typeof middleware_insertion_facade_default === "object") {
  WRAPPED_ENTRY = wrapExportedHandler(middleware_insertion_facade_default);
} else if (typeof middleware_insertion_facade_default === "function") {
  WRAPPED_ENTRY = wrapWorkerEntrypoint(middleware_insertion_facade_default);
}
var middleware_loader_entry_default = WRAPPED_ENTRY;
export {
  __INTERNAL_WRANGLER_MIDDLEWARE__,
  middleware_loader_entry_default as default
};
//# sourceMappingURL=index.js.map
