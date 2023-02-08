const { startServer } = require('./src/app');
const { logger } = require('./src/services/loggerService')
const SLEEP_TIME = process.env.SLEEP_TIME || 1000;

// sleep till MongoDB and RabbitMQ services start
logger.info(`Sleeping for ${SLEEP_TIME}ms before connecting to MongoDB`)
setTimeout(() => {
    startServer();
    logger.info(`Car rental platform started`)
}, SLEEP_TIME)
