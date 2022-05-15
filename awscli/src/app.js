// Express App Setup
const express = require('express');
const bodyParser = require('body-parser');
const app = express();

app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json());

// for testing purposes
app.get('/test', (req, res) => {
  res.status(200).send({ text: 'Simple Node App Working!' });
});

module.exports = app;
