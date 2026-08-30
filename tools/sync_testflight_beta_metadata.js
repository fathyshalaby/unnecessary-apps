#!/usr/bin/env node

// Upsert the short description TestFlight requires before external beta review.
// Credentials are read from ASC_ENV_FILE or ~/.private_keys/appstoreconnect.env.

const crypto = require("crypto");
const fs = require("fs");
const path = require("path");

const ROOT = path.resolve(__dirname, "..");
const envPath = process.env.ASC_ENV_FILE || path.join(process.env.HOME || "", ".private_keys/appstoreconnect.env");
const args = process.argv.slice(2);
const dryRun = args.includes("--dry-run");
const selection = args.find((value) => value.startsWith("--app-numbers="))?.split("=", 2)[1] || "";

function readEnv(file) {
  const values = {};
  for (const line of fs.readFileSync(file, "utf8").split(/\r?\n/)) {
    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith("#")) continue;
    const match = trimmed.match(/^([A-Za-z_][A-Za-z0-9_]*)=(.*)$/);
    if (match) values[match[1]] = match[2].replace(/^['"]|['"]$/g, "");
  }
  return values;
}

function loadJSON(relativePath) {
  return JSON.parse(fs.readFileSync(path.join(ROOT, relativePath), "utf8"));
}

function selectedNumbers(spec) {
  if (!spec) return null;
  const values = new Set();
  for (const token of spec.split(",").map((value) => value.trim()).filter(Boolean)) {
    const match = token.match(/^(\d+)-(\d+)$/);
    if (match) {
      for (let number = Number(match[1]); number <= Number(match[2]); number += 1) values.add(number);
    } else if (/^\d+$/.test(token)) {
      values.add(Number(token));
    } else {
      throw new Error(`Invalid app selection: ${token}`);
    }
  }
  return values;
}

function base64url(input) {
  return Buffer.from(input).toString("base64").replace(/=/g, "").replace(/\+/g, "-").replace(/\//g, "_");
}

function makeJWT({ keyId, issuerId, keyPath }) {
  const header = { alg: "ES256", kid: keyId, typ: "JWT" };
  const now = Math.floor(Date.now() / 1000);
  const payload = { iss: issuerId, iat: now, exp: now + 20 * 60, aud: "appstoreconnect-v1" };
  const input = `${base64url(JSON.stringify(header))}.${base64url(JSON.stringify(payload))}`;
  const signature = crypto.sign("sha256", Buffer.from(input), {
    key: fs.readFileSync(keyPath, "utf8"),
    dsaEncoding: "ieee-p1363",
  });
  return `${input}.${base64url(signature)}`;
}

async function request(token, method, endpoint, body) {
  const response = await fetch(`https://api.appstoreconnect.apple.com${endpoint}`, {
    method,
    headers: { Authorization: `Bearer ${token}`, "Content-Type": "application/json" },
    body: body ? JSON.stringify(body) : undefined,
  });
  const raw = await response.text();
  const json = raw ? JSON.parse(raw) : {};
  if (!response.ok) {
    const detail = json?.errors?.map((error) => `${error.status || response.status} ${error.code || ""} ${error.title || ""} ${error.detail || ""}`.trim()).join(" | ");
    throw new Error(detail || `${method} ${endpoint} failed with ${response.status}`);
  }
  return json;
}

async function main() {
  const env = readEnv(envPath);
  const keyId = process.env.ASC_KEY_ID || env.ASC_KEY_ID;
  const issuerId = process.env.ASC_ISSUER_ID || env.ASC_ISSUER_ID;
  const keyPath = process.env.ASC_KEY_PATH || env.ASC_KEY_PATH;
  const feedbackEmail = process.env.ASC_FEEDBACK_EMAIL || env.ASC_FEEDBACK_EMAIL || "";
  const reviewContact = {
    contactFirstName: process.env.ASC_REVIEW_CONTACT_FIRST_NAME || env.ASC_REVIEW_CONTACT_FIRST_NAME || "",
    contactLastName: process.env.ASC_REVIEW_CONTACT_LAST_NAME || env.ASC_REVIEW_CONTACT_LAST_NAME || "",
    contactPhone: process.env.ASC_REVIEW_CONTACT_PHONE || env.ASC_REVIEW_CONTACT_PHONE || "",
    contactEmail: process.env.ASC_REVIEW_CONTACT_EMAIL || env.ASC_REVIEW_CONTACT_EMAIL || feedbackEmail,
  };
  const suppliedReviewContactFields = Object.entries(reviewContact).filter(([, value]) => value);
  const reviewContactReady = suppliedReviewContactFields.length === Object.keys(reviewContact).length;
  if (suppliedReviewContactFields.length > 0 && !reviewContactReady) {
    const missing = Object.keys(reviewContact).filter((field) => !reviewContact[field]);
    throw new Error(`Reviewer contact is incomplete; also provide ${missing.join(", ")}.`);
  }
  if (reviewContact.contactPhone && !reviewContact.contactPhone.trim().startsWith("+")) {
    throw new Error("ASC_REVIEW_CONTACT_PHONE must use international format, for example +43 1 234567.");
  }
  if (!keyId || !issuerId || !keyPath) throw new Error("Missing ASC_KEY_ID, ASC_ISSUER_ID, or ASC_KEY_PATH.");
  if (!fs.existsSync(keyPath)) throw new Error("ASC_KEY_PATH does not exist.");

  const metadata = loadJSON("release/app-store-metadata.json").apps;
  const records = loadJSON("config/app-store-connect-apps.json");
  const inviteLinks = loadJSON("release/testflight-invite-links.json").apps;
  const schemeByNumber = new Map(inviteLinks.map((app) => [app.number, app.scheme]));
  const wantedNumbers = selectedNumbers(selection);
  const apps = metadata.filter((app) => !wantedNumbers || wantedNumbers.has(app.number));
  const token = makeJWT({ keyId, issuerId, keyPath });
  let created = 0;
  let updated = 0;
  let unchanged = 0;
  let reviewContactsUpdated = 0;
  let reviewContactsUnchanged = 0;

  for (const app of apps) {
    const scheme = schemeByNumber.get(app.number);
    if (!scheme) throw new Error(`No scheme mapping for app ${app.number}.`);
    const appId = records[scheme];
    if (!appId) throw new Error(`No App Store Connect record for ${scheme}.`);
    const description = app.description.trim();
    const endpoint = `/v1/betaAppLocalizations?filter%5Bapp%5D=${encodeURIComponent(appId)}&filter%5Blocale%5D=en-US&limit=10`;
    const response = await request(token, "GET", endpoint);
    const existing = response.data?.find((item) => item.attributes?.locale === "en-US") || response.data?.[0];
    const attributes = { description };
    if (feedbackEmail) attributes.feedbackEmail = feedbackEmail;

    if (existing?.attributes?.description === description && (!feedbackEmail || existing?.attributes?.feedbackEmail === feedbackEmail)) {
      unchanged += 1;
      console.log(`[${String(app.number).padStart(2, "0")}] unchanged`);
    } else if (dryRun) {
      console.log(`[${String(app.number).padStart(2, "0")}] ${existing ? "would update" : "would create"}`);
    } else if (existing) {
      await request(token, "PATCH", `/v1/betaAppLocalizations/${existing.id}`, {
        data: { type: "betaAppLocalizations", id: existing.id, attributes },
      });
      updated += 1;
      console.log(`[${String(app.number).padStart(2, "0")}] updated`);
    } else {
      await request(token, "POST", "/v1/betaAppLocalizations", {
        data: {
          type: "betaAppLocalizations",
          attributes: { locale: "en-US", ...attributes },
          relationships: { app: { data: { type: "apps", id: appId } } },
        },
      });
      created += 1;
      console.log(`[${String(app.number).padStart(2, "0")}] created`);
    }

    if (reviewContactReady) {
      const detail = await request(token, "GET", `/v1/apps/${appId}/betaAppReviewDetail`);
      if (!detail.data?.id) throw new Error(`App ${app.number} has no Beta App Review Detail record.`);
      const current = detail.data.attributes || {};
      const contactUnchanged = Object.entries(reviewContact).every(([field, value]) => current[field] === value);
      if (contactUnchanged) {
        reviewContactsUnchanged += 1;
      } else if (dryRun) {
        console.log(`[${String(app.number).padStart(2, "0")}] reviewer contact would update`);
      } else {
        await request(token, "PATCH", `/v1/betaAppReviewDetails/${detail.data.id}`, {
          data: { type: "betaAppReviewDetails", id: detail.data.id, attributes: reviewContact },
        });
        reviewContactsUpdated += 1;
        console.log(`[${String(app.number).padStart(2, "0")}] reviewer contact updated`);
      }
    }
  }

  console.log(`${dryRun ? "dry run: " : ""}${apps.length} beta descriptions checked; ${created} created, ${updated} updated, ${unchanged} unchanged.`);
  console.log(reviewContactReady
    ? `${apps.length} beta reviewer contacts checked; ${reviewContactsUpdated} updated, ${reviewContactsUnchanged} unchanged.`
    : "Beta reviewer contacts skipped; provide all ASC_REVIEW_CONTACT_* fields before submitting external review.");
}

main().catch((error) => {
  console.error(error.message);
  process.exit(1);
});
