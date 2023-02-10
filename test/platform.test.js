//During the test the env variable is set to test
process.env.NODE_ENV = 'test';
let mongoose = require("mongoose");
const {reservationSchema} = require('../app/src/models/Reservation');

let Reservation = mongoose.model('Reservation', reservationSchema);
const {carSchema} = require('../app/src/models/Car');
let Car = mongoose.model('Car', carSchema);
const {userSchema} = require('../app/src/models/User');
let User = mongoose.model('User', userSchema);
const {agentSchema} = require('../app/src/models/Agent');
let Agent = mongoose.model('Agent', agentSchema);

const request = require('supertest');

const {hashPassword} = require ('../app/src/lib/tools');

const { createFakeCars, createFakeAgents, deleteAllCars, deleteAllAgents, createFakeUsers, deleteAllUsers } = require('../app/src/lib/tools');
const expect = require('chai').expect;

let chai = require('chai');
let chaiHttp = require('chai-http');


const { app } = require('../app/src/app');


var assert = require('assert');


chai.use(chaiHttp);

describe('Register Agent', () => {
    beforeEach(async () => { //Before each test we empty the database
      await deleteAllAgents();
      await deleteAllCars();
      await deleteAllUsers();
      await createFakeAgents();
      await createFakeCars();
      await createFakeUsers();
    });

    it('should regiter an Agent', async function () {
        let hash = await hashPassword("password");
        let newAgent = {
            "name": "John",
            "surname": "Doe",
            "email": "agent1@test.com" ,
            "password": hash,
        }

        newAgent = new Agent(newAgent);
        await newAgent.save();

        retrieveAgent = await Agent.findOne({email: "agent1@test.com"});
        assert.equal(retrieveAgent.name, "John");
    });

});


describe('Add car to catalog', () => {
    beforeEach(async () =>{
        await deleteAllAgents();
        await deleteAllCars();
        await deleteAllUsers();
        await createFakeAgents();
        await createFakeCars();
        await createFakeUsers();
    });
  it('should add a car to the catalog', async () => {
    
    const response = await request(app)
      .post('/api/car/catalog')
      .send({
        email: 'agent1@car.com',
        password: '123456',
        brand: 'Citroen',
        model: 'C4',
        numberOfSeat: '5',
        pricePerDay: '80',
        available: true
  }).set('Accept', 'application/json');
  

    expect(response.statusCode).to.equal(201);
    expect(response.body["brand"]).to.equal("Citroen")
    expect(response.body["model"]).to.equal("C4")
    expect(response.body["numberOfSeat"]).to.equal(5)
   
  });

  it('Create reservation from agency', async () => {
    const response_car = await request(app)
      .post('/api/car/catalog')
      .send({
        email: 'agent1@car.com',
        password: '123456',
        brand: 'Citroen',
        model: 'C4',
        numberOfSeat: '5',
        pricePerDay: '80',
        available: true
  }).set('Accept', 'application/json');

   

    const response = await request(app)
      .post('/api/car/reservation')
      .send({
        email: "agent1@car.com",
        password: "123456",
        carID : response_car.body["_id"],
        customerEmail: "john@test.com",
        startDate : "2020-04-24",
        endDate : "2020-05-4",
        paymentStatus : "Paid" ,
        paymentMethod : "Cash",
        ReservationStatus : "In progress"
    }).set('Accept', 'application/json');

    expect(response.statusCode).to.equal(201);
    expect(response.body["carID"]).to.equal(response_car.body["_id"]);
    expect(response.body["paymentStatus"]).to.equal("Paid");
    expect(response.body["ReservationStatus"]).to.equal("In progress");
   
  });

//   it('If client is registered', async () => {

//     const response = await request(app)
//       .get('/api/customer/isClient')
//       .send({
//         email: "agent1@car.com",
//         password: "123456",
//         customerEmail: "agent1@car.com"
    
//     }).set('Accept', 'application/json');
  

//     expect(response.statusCode).to.equal(201);
   
//   });

  it('if car is available', async () => {
    const response_car = await request(app)
      .post('/api/car/catalog')
      .send({
        email: 'agent1@car.com',
        password: '123456',
        brand: 'Citroen',
        model: 'C4',
        numberOfSeat: '5',
        pricePerDay: '80',
        available: true
  }).set('Accept', 'application/json');
   

    const response = await request(app)
      .get('/api/car/availability')
      .send({
        email: "agent1@car.com",
        password: "123456",
        carID : response_car.body["_id"],
     startDate : "2022-04-24",
        endDate : "2022-05-4"
    }).set('Accept', 'application/json');
  

    expect(response.statusCode).to.equal(200);
   
  });

  it('Get Catalog', async () => {

    const response = await request(app)
      .get('/api/car/catalog')
      .send({
        "email": "agent1@car.com",
        "password": "123456"
    }).set('Accept', 'application/json');
  

    expect(response.statusCode).to.equal(200);
   
  });


});



