const express = require('express');
const {AddCarToCalatog, CreateReservationFromAgency, isThisCarAvaible, getCatalog, AddNewAgent} = require ('../controllers/carController');
const { validAddCarToCatalog, validCreateReservation, validIsAvailable, validGetCatalog, validAddAgent} = require('../lib/validator');

const router = express.Router();

router.post('/catalog' , validAddCarToCatalog, AddCarToCalatog);
router.post('/reservation', validCreateReservation, CreateReservationFromAgency )
router.get('/availability', validIsAvailable, isThisCarAvaible)
router.get('/catalog', validGetCatalog, getCatalog)
router.post('/register', validAddAgent,AddNewAgent)

module.exports = {
    carSystemRouter: router
}