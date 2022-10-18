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

    let randomObj = [];

    if (
      isNaN(req.query.limit) ||
      req.query.limit === undefined ||
      req.query.limit === null
    ) {
      req.query.limit = 1;
    } else if (req.query.limit > 50) {
      res.status(400);
      res.json({
        code: 400,
        data: "You cannot return more than 50 Datasets at once!",
      });
      return;
    }

    if (req.query.id === undefined) {
      randomObj = await conn.query(
        "SELECT id, text FROM view_tweets WHERE category = 'trash-tv' ORDER BY RAND() LIMIT ?",
        [Number(req.query.limit)]
      );

      genAndSend(randomObj);
    } else {
      randomObj = await conn.query(
        "SELECT id, text FROM view_tweets WHERE category = 'trash-tv' AND id = ? LIMIT 1",
        [req.query.id]
      );

      if (randomObj[0] === undefined || randomObj[0] === null) {
        res.status(404);
        res.json({ code: 404, data: "Not found." });
      } else {
        genAndSend(randomObj);
      }
    }

    function genAndSend(randomObj) {
      let results = [];

      randomObj.forEach((result) => {
        result.text = result.text.replace(
          /(http)[s]{1}(:\/\/t\.co\/)[a-zA-Z0-9]*/gi,
          ""
        );

        result.permalink =
          global.config.express.baseURL + "/v1/getRandomTrash?id=" + result.id;

        result.share =
          "https://twitter.com/intent/tweet?text=" +
          encodeURI(
            "Schau dir diesen coolen zufälligen Tweet vom Deutschen Trash-TV Twitter an!\n\n"
          ) +
          result.permalink;

        result.random = global.config.express.baseURL + "/v1/getRandomTrash";

        results.push(result);

        if (results.length === Number(req.query.limit)) {
          res.status(200);
          res.json({ code: 200, data: results });
        }
      });
    }

    conn.end();
  }
}
