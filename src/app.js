const express = require('express');
const morgan = require('morgan');
const mongoose = require('mongoose');
const { errorHandlerMiddleware } = require ('./services/errorHandlingService');
const { logger } = require('./services/loggerService');
const { mongoConnect } = require('./services/mongoService');
const { addRoutes } = require('./routes/api');


const PORT = process.env.PORT || 4000;


// Create a new express application instance
const app = express()
 
// Connect to MongoDB database
mongoConnect()

// middleware to add basic logging - Combined format is a standard Apache log output format
app.use(morgan('combined'));

// Middleware to parse incoming requests with JSON payloads
app.use(express.json())

// Handdle errors
app.use(errorHandlerMiddleware)

// Add router handler
addRoutes(app)

// Start the server
app.listen(PORT, () => {
    logger.info(`agent service listening on port ${PORT}`);
})


module.exports = {
    app: app,
}
