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

// // Delete all agents
// await deleteAllAgents();

// // Delete all users$
// await deleteAllUsers();

// // Init a fake agents
// await createFakeAgents();

// // Init fake Users
// await createFakeUsers();

app.listen(PORT, () => {
    logger.info(`agent service listening on port ${PORT}`);
})


module.exports = {
    app: app,
}
