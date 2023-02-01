const {carSystemRouter} = require('./carSystemRouter');
const {customerServiceRouter} = require('./customerSystemRouter');

const addRoutes = (app) => {
    app.use('/api/car', carSystemRouter);
    app.use('/api/customer', customerServiceRouter);
}

module.exports = {
    addRoutes: addRoutes
}