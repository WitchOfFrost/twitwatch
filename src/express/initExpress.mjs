import express from "express";

export default class {
  constructor() {
    this.api = express();

    this.api.get("/v1/getRandomTrash", (req, res) => {
      this.getRandomTrash(req, res);
    });

    this.api.listen(global.config.express.port, () => {
      console.log("[EXPRESS] Listening on port " + global.config.express.port);
    });
  }

  async getRandomTrash(req, res) {
    const conn = await global.pool.getConnection();

    let randomObj = await conn.query(
      "SELECT id, text FROM tweets ORDER BY RAND() LIMIT 1"
    );

    res.status(200);
    res.json(randomObj[0]);
  }
}
