var express = require('express'),
    wines = require('./routes/newsroom');
 
var app = express();

app.get('/',wines.home);
app.get('/countries/rank/1W', wines.countriesRank1W);
app.get('/countries/rank/1D', wines.countriesRank1D);
app.get('/countries/:code/news', wines.countryNews);
app.get('/news/:id/vote', wines.findVotesByNewsId);
app.post('/news/:id/vote', wines.setVoteByNewsId);


app.listen(9871);
console.log('Listening on port 9871...');