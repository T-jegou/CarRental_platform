const mongoose = require('mongoose');
const { logger } = require('./loggerService')
require('dotenv').config()

if (!process.env.MONGO_HOST) throw new Error("HOST is not defined")
if (!process.env.MONGO_PORT) throw new Error("PORT is not defined")
if (!process.env.MONGO_INITDB_USERNAME) throw new Error("USERNAME is not defined")
if (!process.env.MONGO_INITDB_PASSWORD) throw new Error("PASSWORD is not defined")
if (!process.env.MONGO_INITDB_DATABASE) throw new Error("DATABASE is not defined")


const MONGO_URI = `mongodb://${process.env.MONGO_INITDB_USERNAME}:${process.env.MONGO_INITDB_PASSWORD}@${process.env.MONGO_HOST}:${process.env.MONGO_PORT}/${process.env.MONGO_INITDB_DATABASE}`;


/**
 * Connect to MongoDB wit Mongoose
 */
const mongoConnect = () => {
    mongoose.Promise = global.Promise;
    mongoose.connect(MONGO_URI, {
    }, (err) => {  
        if(err) {
            logger.log('fatal', err);
            logger.log('trace', err.stack);
        }
    });
    mongoose.set('strictQuery', false);
    mongoose.connection.on('connected', function () {  
        logger.log('info',`Mongoose - connection established at ${MONGO_URI}`);
    }); 
    
    // If the connection throws an error
    mongoose.connection.on('error',function (err) {  
        logger.log('fatal',`Mongoose - connection error: ${MONGO_URI}`);
    }); 
    
    // When the connection is disconnected
    mongoose.connection.on('disconnected', function () {  
        logger.log('fatal',`Mongoose - disconnected: ${MONGO_URI}`);
    });
}
  

module.exports = {
    mongoConnect: mongoConnect
}