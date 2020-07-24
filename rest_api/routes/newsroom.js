var pg = require('pg');
var conString = "postgres://anchorman:newsdesk@localhost/thenewsroom";
var postgre_cli;


exports.home = function(req, res){
    console.log(req.params);

    var methods = {
        "GET /countries/1W" : { "description":"ranking of countries in the last week"},
        "GET /countries/1D" : { "description":"ranking of countries in the last 24h"},
        "GET /country/:id/news" : { 
            "description":"get the news for a country", 
            "params":{
                "id":"id of the country", 
                "offset":"(optional int, default 0) offset",
                "length":"(optional int, default 20) number of news",
            }
        },

    }
    res.jsonp(methods);
}

exports.countriesRank1W = function(req, res) {
    console.log(req.params);
    var id = parseInt(req.params.id);
    console.log('find all countries');

    pg.connect(conString, function(err, client, done) {
          if(err) {
            return console.error('error fetching client from pool', err);
          }
          client.query({name:'rank_2w',text:'SELECT country as name,total_score as score,country_iso3 as id,ROW_NUMBER() OVER() as rank FROM top_country_last_week WHERE total_score > 0'}, function(err, result) {
                //call `done()` to release the client back to the pool
                done();
                if(err) {
                  return console.error('error running query', err);
                }
                //console.log(result.rows);
                res.jsonp(result.rows);
                //output: 1
            });
    });
};

exports.countriesRank1D = function(req, res) {
    console.log(req.params);
    var id = parseInt(req.params.id);
    console.log('find all countries');

    pg.connect(conString, function(err, client, done) {
          if(err) {
            return console.error('error fetching client from pool', err);
          }
          client.query({name:'rank_1w',text:'SELECT country as name,total_score as score,country_iso3 as id,ROW_NUMBER() OVER() as rank FROM top_country_last_day WHERE total_score > 0'}, function(err, result) {
                //call `done()` to release the client back to the pool
                done();
                if(err) {
                  return console.error('error running query', err);
                }
                //console.log(result.rows);
                res.jsonp(result.rows);
                //output: 1
            });
    });
};


exports.countryNews = function(req,res) {
    // console.log('find country news');
    // console.log(req.params);

    var code = req.params.code;
    var offset = req.query.hasOwnProperty("offset") ? parseInt(req.query.offset) : 0;
    var limit = req.query.hasOwnProperty("limit")? parseInt(req.query.limit) : 20;


    // console.log(code);
    // console.log(offset);
    // console.log(limit);

    // check limit and offset values
    if(isNaN(offset) || isNaN(limit) || offset < 0 || limit < 1){
        res.send(400, { error: 'invalid values for offset/limit parameters' });
        return console.error('invalid parameter');
    }

    pg.connect(conString, function(err, client, done) {
          if(err) {
            res.send(500, { error: 'Something blew up!' });
            return console.error('error fetching client from pool', err);
          }
          //client.query({name:"news_st", text:"SELECT title,url,article_day, published FROM articles_headlines_feed WHERE country_iso3 = $1 LIMIT $2::int OFFSET $3::int", values:[code,limit,offset]}, function(err, result) {
            client.query("SELECT article_hash as news_id,title,url,published, related_countries FROM articles_headlines_by_country WHERE country_iso3 = $1 LIMIT $2::int OFFSET $3::int", [code,limit,offset], function(err, result) {
                //call `done()` to release the client back to the pool
                done();
                if(err) {
                    res.send(500, { error: 'Something blew up!' });
                    return console.error('error running query', err);
                }
                //console.log(result.rows);
                res.jsonp(result.rows);
                //output: 1
        });
    });
}
exports.findNewsByCountryId = function(req,res) {
    console.log(req.params);
    res.jsonp({"res":"1"});
}
exports.findNewsById = function(req,res) {
    console.log(req.params);
    res.jsonp({"res":"1"});
}
exports.findVotesByNewsId = function(req,res) {
    console.log(req.params);
    res.jsonp({"res":"1"});
}
exports.setVoteByNewsId = function(req,res) {
    console.log(req.params);
    res.jsonp({"res":"1"});
}

