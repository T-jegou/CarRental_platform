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

const {hashPassword} = require ('../app/src/lib/tools');

//Require the dev-dependencies
let chai = require('chai');
let chaiHttp = require('chai-http');


const { app } = require('../app/src/app');
let server = app
let should = chai.should();

var assert = require('assert');


chai.use(chaiHttp);
//Our parent block
describe('Books', () => {
    beforeEach((done) => { //Before each test we empty the database
        Car.deleteMany({}, (err) => {
            if (err) {
                console.log(err)
            }
        });

        User.deleteMany({}, (err) => {
            if (err) {
                console.log(err)
            }
        });
        
        Agent.deleteMany({}, (err) => {
            if (err) {
                console.log(err)
            }
        });
        
        Reservation.deleteMany({}, (err) => {
            if (err) {
                console.log(err)
            }
            done();
        });
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

// /*
//   * Test the /GET route
//   */
//   describe('/GET Cars', () => {
//       it('it should GET all the books', (done) => {
//         chai.request(server)
//             .get('/api/car/catalog')
//             .end((err, res) => {
//                   res.should.have.status(200);
//                   res.body.should.be.a('array');
//                   res.body.length.should.be.eql(0);
//               done();
//             });
//       });
//   });

// });



// Must test this :
// AddCarToCalatog: AddCarToCalatog,
// CheckIfClientIsRegistred: CheckIfClientIsRegistred,
// CreateReservationFromAgency: CreateReservationFromAgency,
// isThisCarAvaible: isThisCarAvaible,
// getCatalog: getCatalog
