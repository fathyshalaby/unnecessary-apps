#!/usr/bin/env node
/**
 * Guards the public TestFlight hub against link or release-state drift.
 * Run: node tools/validate_testflight_hub.js
 */

const fs = require("node:fs");
const path = require("node:path");

const root = path.resolve(__dirname, "..");
const invites = JSON.parse(fs.readFileSync(path.join(root, "release/testflight-invite-links.json"), "utf8"));
const html = fs.readFileSync(path.join(root, "site/testflight.html"), "utf8");
const fail = (message) => {
  console.error(`TestFlight hub validation failed: ${message}`);
  process.exit(1);
};

if (!Array.isArray(invites.apps) || invites.apps.length !== 44) {
  fail("invite manifest must contain exactly 44 apps");
}

const numbers = invites.apps.map((app) => app.number).sort((a, b) => a - b);
if (numbers.some((number, index) => number !== index + 1)) {
  fail("invite manifest app numbers must be exactly 1 through 44");
}

for (const app of invites.apps) {
  const linkMatches = html.split(app.public_link).length - 1;
  if (linkMatches !== 1) fail(`${app.number} must have exactly one matching public link`);
  if (!html.includes(`>${String(app.number).padStart(2, "0")}</span>`)) {
    fail(`${app.number} is missing its numbered card`);
  }
  if (!html.includes(`<strong>${app.name}</strong>`)) fail(`${app.number} is missing its app name`);
}

for (const staleClaim of ["Available now", "Rolling out", ">AVAILABLE<", "five ready apps"]) {
  if (html.includes(staleClaim)) fail(`stale availability claim: ${staleClaim}`);
}

if (!html.includes("All 44 apps in Apple review")) {
  fail("missing the current collection-wide review state");
}

console.log("validated 44 TestFlight hub cards, invite links, and Apple-review state");
