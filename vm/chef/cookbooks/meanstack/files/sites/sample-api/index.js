const express = require('express')
const app = express()

const API_PORT = process.env.API_PORT || 8080;
const MONGODB_HOST = process.env.MONGODB_HOST || "localhost";
const MONGODB_USERNAME = process.env.MONGODB_USERNAME || "";
const MONGODB_PASSWORD = process.env.MONGODB_PASSWORD || "";
const MONGODB_PORT = process.env.MONGODB_PORT || 27017;
const MONGODB_NAME = process.env.MONGODB_NAME || "test";

const mongoose = require('mongoose');

// Static route
app.get('/', function (req, res) {
  res.json({
    name: 'Google Cloud Marketplace - Sample API'
  })
})

mongoose.connect(`mongodb://${MONGODB_USERNAME}:${MONGODB_PASSWORD}@${MONGODB_HOST}:${MONGODB_PORT}/${MONGODB_NAME}`, {
  useNewUrlParser: true, useUnifiedTopology: true});

const Pet = mongoose.model('Pet', { name: String });

app.get('/pet/create', function (req, res) {
  const cat = new Pet({ name: 'Cat' });
  cat.save().then(() => {
      res.json(cat);
  });
})

app.get('/pets', function (req, res) {
  Pet.find({}, (err, pets) => {
      res.json(pets)
  })
})

// Add other routes

app.listen(API_PORT, () => {
  console.log(`Starting on Port: ${API_PORT}`)
})
