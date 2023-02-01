const express = require('express');
const {AddCarToCalatog, CreateReservationFromAgency, isThisCarAvaible, getCatalog} = require ('../controllers/carController');
const { validAddCarToCatalog, validCreateReservation, validIsAvailable, validGetCatalog} = require('../lib/validator');

const router = express.Router();

router.post('/catalog' , validAddCarToCatalog, AddCarToCalatog);
router.post('/reservation', validCreateReservation, CreateReservationFromAgency )
router.get('/availability', validIsAvailable, isThisCarAvaible)
router.get('/catalog', validGetCatalog, getCatalog)

module.exports = {
    carSystemRouter: router
}