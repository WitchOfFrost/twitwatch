import express from "express";
import morgan from "morgan";

export default class {
  constructor() {
    this.api = express();
    this.api.use(morgan("tiny"));

    this.api.get("/v1/getRandomTrash", (req, res) => {
      this.getRandomTrash(req, res);
    });

    this.api.listen(global.config.express.port, () => {
      console.log("[EXPRESS] Listening on port " + global.config.express.port);
    });
  }

  async getRandomTrash(req, res) {
    const conn = await global.pool.getConnection();

    let randomObj = {};

    if (req.query.id === undefined) {
      randomObj = await conn.query(
        "SELECT id, text FROM tweets ORDER BY RAND() LIMIT 1"
      );

      randomObj[0].text = randomObj[0].text.replace(
        /(http)[s]{1}(:\/\/t\.co\/)[a-zA-Z0-9]*/gi,
        ""
      );

      randomObj[0].permalink =
        global.config.express.baseURL +
        "/v1/getRandomTrash?id=" +
        randomObj[0].id;

      randomObj[0].share =
        "https://twitter.com/intent/tweet?text=" +
        encodeURI(
          "Schau dir diesen coolen zufälligen Tweet vom Deutschen Trash-TV Twitter an!\n\n"
        ) +
        randomObj[0].permalink;

      res.status(200);
      res.json({ code: 200, data: randomObj[0] });
    } else {
      randomObj = await conn.query(
        "SELECT id, text FROM tweets WHERE id = ? LIMIT 1",
        [req.query.id]
      );

      if (randomObj[0] === undefined || randomObj[0] === null) {
        res.status(404);
        res.json({ code: 404, data: "Not found." });
      } else {
        randomObj[0].text = randomObj[0].text.replace(
          /(http)[s]{1}(:\/\/t\.co\/)[a-zA-Z0-9]*/gi,
          ""
        );

        randomObj[0].permalink =
          global.config.express.baseURL +
          "/v1/getRandomTrash?id=" +
          req.query.id;

        randomObj[0].share =
          "https://twitter.com/intent/tweet?text=" +
          encodeURI(
            "Schau dir diesen coolen zufälligen Tweet vom Deutschen Trash-TV Twitter an!\n\n"
          ) +
          randomObj[0].permalink;

        res.status(200);
        res.json({ code: 200, data: randomObj[0] });
      }
    }

    conn.end();
  }
}
