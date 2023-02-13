const mongoose = require('mongoose');
const { Schema } = mongoose;

const reservationSchema = new Schema({
    carID : {
        type: String,
        required: true
    },
    userID : {
        type: String,
        required: true
    },
    startDate : {
        type: Date,
        required: true
    },
    endDate : {
        type: Date,
        required: true
    },
    price : {
        type: Number,
        required: true
    },
    paymentStatus : {
        type: String,
        required: true
    },
    paymentMethod : {
        type: String,
        required: true
    },
    ReservationStatus : {
        type: String,
        required: true
    }
});


module.exports = {
    reservationSchema: reservationSchema
}
