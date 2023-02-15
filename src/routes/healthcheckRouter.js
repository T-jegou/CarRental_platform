const express = require('express');

const router = express.Router();

router.get('/', async (_req, res, _next) => {

    const healthcheck = {
        uptime: process.uptime(),
        message: 'OK',
        timestamp: Date.now()
    };
    try {
        if (healthcheck.uptime > 0) {
            healthcheck.message = 'OK';
            res.status(200).send();
        }

        if (healthcheck.uptime <= 0) {
            healthcheck.message = 'Error';
            res.status(503).send();
        }

        if (healthcheck.uptime === undefined) {
            healthcheck.message = 'Error';
            res.status(503).send();
        }

        if (healthcheck.uptime === null) {
            healthcheck.message = 'Error';
            res.status(503).send();
        }
    } catch (error) {
        healthcheck.message = error;
        res.status(503).send();
    }
});

module.exports = {
    healthCheckRouter: router
}