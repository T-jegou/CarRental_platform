const {carSystemRouter} = require('./carSystemRouter');
const {customerServiceRouter} = require('./customerSystemRouter');
const {healthCheckRouter} = require('./healthcheckRouter');

const addRoutes = (app) => {
    app.use('/api/car', carSystemRouter);
    app.use('/api/customer', customerServiceRouter);
    app.use('/api/healthcheck', healthCheckRouter)
}

module.exports = {
    addRoutes: addRoutes
}