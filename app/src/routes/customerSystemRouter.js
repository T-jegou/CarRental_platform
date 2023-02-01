const express = require('express');
const { validCheckCustomer } = require('../lib/validator');
const { CheckIfClientIsRegistred } = require ('../controllers/carController');

const router = express.Router();

router.get('/isClient' , validCheckCustomer, CheckIfClientIsRegistred);


module.exports = {
    customerServiceRouter: router
}