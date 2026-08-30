#!/usr/bin/env node
/**
 * Report the current external-beta review state for every TestFlight group.
 * Credentials come from ASC_ENV_FILE or ~/.private_keys/appstoreconnect.env.
 * Run: node tools/check_testflight_review_status.js [--json]
 */

const crypto = require("node:crypto");
const fs = require("node:fs");
const path = require("node:path");

const root = path.resolve(__dirname, "..");
const jsonOutput = process.argv.includes("--json");

function readEnv(file) {
  const values = {};
  for (const rawLine of fs.readFileSync(file, "utf8").split(/\r?\n/)) {
    const line = rawLine.trim();
    const match = line.match(/^([A-Za-z_][A-Za-z0-9_]*)=(.*)$/);
    if (match) values[match[1]] = match[2].replace(/^['"]|['"]$/g, "");
  }
  return values;
}

function base64url(input) {
  return Buffer.from(input).toString("base64").replace(/=/g, "").replace(/\+/g, "-").replace(/\//g, "_");
}

function makeJWT({ keyId, issuerId, keyPath }) {
  const now = Math.floor(Date.now() / 1000);
  const header = { alg: "ES256", kid: keyId, typ: "JWT" };
  const payload = { iss: issuerId, iat: now, exp: now + 20 * 60, aud: "appstoreconnect-v1" };
  const input = `${base64url(JSON.stringify(header))}.${base64url(JSON.stringify(payload))}`;
  const signature = crypto.sign("sha256", Buffer.from(input), {
    key: fs.readFileSync(keyPath, "utf8"),
    dsaEncoding: "ieee-p1363",
  });
  return `${input}.${base64url(signature)}`;
}

async function request(token, endpoint) {
  const response = await fetch(`https://api.appstoreconnect.apple.com${endpoint}`, {
    headers: { Authorization: `Bearer ${token}` },
  });
  const body = await response.json();
  if (!response.ok) {
    const detail = body.errors?.map((error) => error.detail || error.title).join(" | ");
    throw new Error(`${response.status} ${detail || endpoint}`);
  }
  return body;
}

async function main() {
  const envPath = process.env.ASC_ENV_FILE || path.join(process.env.HOME || "", ".private_keys/appstoreconnect.env");
  const env = readEnv(envPath);
  const keyId = process.env.ASC_KEY_ID || env.ASC_KEY_ID;
  const issuerId = process.env.ASC_ISSUER_ID || env.ASC_ISSUER_ID;
  const keyPath = process.env.ASC_KEY_PATH || env.ASC_KEY_PATH;
  if (!keyId || !issuerId || !keyPath || !fs.existsSync(keyPath)) {
    throw new Error("Missing valid ASC_KEY_ID, ASC_ISSUER_ID, or ASC_KEY_PATH.");
  }

  const token = makeJWT({ keyId, issuerId, keyPath });
  const invites = JSON.parse(fs.readFileSync(path.join(root, "release/testflight-invite-links.json"), "utf8")).apps;
  const records = JSON.parse(fs.readFileSync(path.join(root, "config/app-store-connect-apps.json"), "utf8"));
  const results = await Promise.all(invites.map(async (app) => {
    if (!records[app.scheme]) throw new Error(`Missing App Store Connect record for ${app.scheme}`);
    const builds = await request(token, `/v1/betaGroups/${app.group_id}/builds?limit=200`);
    const orderedBuilds = [...(builds.data || [])].sort((left, right) => {
      return Date.parse(right.attributes?.uploadedDate || 0) - Date.parse(left.attributes?.uploadedDate || 0);
    });
    const build = orderedBuilds.find((item) => !item.attributes?.expired) || orderedBuilds[0];
    const betaDetail = build ? await request(token, `/v1/builds/${build.id}/buildBetaDetail`) : { data: null };
    return {
      number: app.number,
      name: app.name,
      build: build?.attributes?.version || null,
      betaReviewState: betaDetail.data?.attributes?.externalBuildState || "NO_GROUP_BUILD",
      uploadedDate: build?.attributes?.uploadedDate || null,
    };
  }));

  results.sort((a, b) => a.number - b.number);
  const counts = Object.fromEntries(results.reduce((map, item) => {
    map.set(item.betaReviewState, (map.get(item.betaReviewState) || 0) + 1);
    return map;
  }, new Map()));

  if (jsonOutput) {
    process.stdout.write(`${JSON.stringify({ counts, apps: results }, null, 2)}\n`);
    return;
  }

  for (const item of results) {
    console.log(`${String(item.number).padStart(2, "0")} ${item.betaReviewState.padEnd(28)} ${item.name} (build ${item.build || "?"})`);
  }
  console.log(`summary: ${Object.entries(counts).map(([state, count]) => `${state}=${count}`).join(", ")}`);
}

main().catch((error) => {
  console.error(`TestFlight review-status check failed: ${error.message}`);
  process.exit(1);
});
