import axios from "axios";

export default class {
  constructor(
    id,
    name,
    position,
    interval,
    upgrade_after,
    downgrade_after,
    refresh_hashtags
  ) {
    this.id = id;
    this.name = name;
    this.position = position;
    this.interval = interval;
    this.refresh_hashtags = refresh_hashtags;

    this.axios = {
      url:
        global.config.twitter.baseURL +
        "tweets/search/recent?query=%23$HASHTAG$ -is:retweet lang:$LANG$&max_results=100&expansions=author_id&user.fields=created_at,description,entities,id,location,name,pinned_tweet_id,profile_image_url,protected,public_metrics,url,username,verified,withheld&sort_order=recency&tweet.fields=created_at&since_id=$SINCEID$",
      method: "get",
      headers: {
        Authorization: "Bearer " + global.config.twitter.bearer,
      },
    };

    setInterval(() => {
      this.fetchHashtags();
    }, 1000 * this.refresh_hashtags);

    this.fetchHashtags();
    this.createLoop();

    console.log(
      "Ring Initialized! Ring: [" + String(this.name).toUpperCase() + "]"
    );

    delete this.output;
  }

  async fetchHashtags() {
    const conn = await global.pool.getConnection();

    let dbRes = await conn.query("SELECT * FROM hashtags WHERE ring = ?", [
      this.id,
    ]);

    delete dbRes.meta;

    this.hashtags = dbRes;

    conn.end();

    console.log(
      "Refreshed Hashtags for Ring: [" +
        String(this.name).toUpperCase() +
        "]" +
        "\nNext refresh due in " +
        this.refresh_hashtags +
        " Seconds!"
    );
  }

  async getLatestTweet() {
    return new Promise(async (resolve) => {
      let req = Object.assign({}, this.axios);

      req.url =
        global.config.twitter.baseURL +
        "tweets/search/recent?query=airplane&max_results=10&sort_order=recency";

      await axios(req)
        .then((res) => {
          resolve(res.data.meta.oldest_id);
        })
        .catch((err) => {
          console.log(err.response.data);

          resolve(null);
        });
    });
  }

  createLoop() {
    setTimeout(async () => {
      if (this.hashtags.length < 1) {
      } else {
        const conn = await global.pool.getConnection();

        this.currHashtag = this.hashtags.shift();

        let req = Object.assign({}, this.axios);

        let maxHashtagId = await conn.query(
          "SELECT MAX(twit_id) AS twit_id FROM tweets WHERE hashtag = ? LIMIT 1",
          [this.currHashtag.id]
        );

        if (maxHashtagId[0].twit_id === null) {
          this.fetchResult(req, await this.getLatestTweet());

          conn.end();
        } else {
          this.fetchResult(req, maxHashtagId[0].twit_id);

          conn.end();
        }
      }
    }, 1000 * this.interval);
  }

  async fetchResult(req, maxHashtagId) {
    const conn = await global.pool.getConnection();

    req.url = req.url.replace("$HASHTAG$", this.currHashtag.hashtag);
    req.url = req.url.replace("$SINCEID$", maxHashtagId);
    req.url = req.url.replace("$LANG$", this.currHashtag.lang)

    axios(req)
      .then((res) => {
        this.hashtags.push(this.currHashtag);

        this.createLoop();
        this.processResult(res);

        conn.end();
      })
      .catch((err) => {
        if (err.response !== undefined) {
          console.log(err.response.data);
        } else {
          console.log(err);
        }

        this.hashtags.push(this.currHashtag);

        this.createLoop();

        conn.end();
      });
  }

  async processResult(res) {
    console.log(
      "RING [" +
        String(this.name).toUpperCase() +
        "] " +
        "\nHASHTAG: " +
        this.currHashtag.hashtag +
        "\nDATA : " +
        JSON.stringify(res.data)
    );

    if (res.data.meta.result_count === 0) {
      return;
    } else {
      res.data.includes.users.forEach(async (user) => {
        const conn = await global.pool.getConnection();

        await conn.query(
          `INSERT IGNORE INTO users SET twit_id = ?, username = ?, name = ?, follower_count = ?, following_count = ?, tweet_count = ?, created_at = ?, location = ?`,
          [
            user.id,
            user.username,
            user.name,
            user.public_metrics.followers_count,
            user.public_metrics.following_count,
            user.public_metrics.tweet_count,
            user.created_at,
            user.location === undefined ? "-" : user.location,
          ]
        );

        conn.end();
      });

      res.data.data.forEach(async (tweet) => {
        const conn = await global.pool.getConnection();

        await conn.query(
          `INSERT IGNORE INTO tweets SET twit_id = ?, author_id = ?, text = ?, hashtag = ?, created_at = ?`,
          [tweet.id, tweet.author_id, tweet.text, this.currHashtag.id, tweet.created_at]
        );

        conn.end();
      });
    }
  }
}
