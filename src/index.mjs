// Init Dirname and change CWD

import path from "path";
import { fileURLToPath } from "url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
global.__dirname = __dirname;

process.chdir(__dirname);

// Init Process

import * as fs from "node:fs/promises";
import * as mariadb from "mariadb";
import initRing from "./ring/initRing.mjs";
import initExpress from "./express/initExpress.mjs";

// Load Config

const config = JSON.parse(await fs.readFile("./config.json", "utf-8"));
global.config = config;

// Init DB Pool

const pool = await mariadb.createPool(config.mariadb);
global.pool = pool;

// Get highest ID

let conn = await pool.getConnection();

let lastId = await conn.query(
  "SELECT MAX(twit_id) AS lastId FROM tweets LIMIT 1"
);

lastId = lastId[0].lastId;

// Initiate Rings

let ringsToCreate = await conn.query("SELECT * FROM rings WHERE active = 1");
let rings = {};

ringsToCreate.forEach((ring) => {
  new initRing(
    ring.id,
    ring.name,
    ring.position,
    ring.interval,
    ring.upgrade_after,
    ring.downgrade_after,
    ring.refresh_hashtags
  );
});

conn.close();

// Init Express

if (config.express.enabled === true) {
  new initExpress();
}

// Init DB Logging

setInterval(async () => {
  const conn = await pool.getConnection();

  console.log({
    "MariaDB Version": conn.serverVersion(),
    "Total Connections": pool.totalConnections(),
    "Active Connections": pool.activeConnections(),
    "Idle Connections": pool.idleConnections(),
    "Task Query Size": pool.taskQueueSize(),
  });

  conn.end();
}, 30 * 1000);
