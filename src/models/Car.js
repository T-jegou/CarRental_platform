const mongoose = require('mongoose');
const { Schema } = mongoose;

const carSchema = new Schema({
    brand: {
        type: String,
        required: true
    },
    model: {
        type: String,
        required: true
    },
    numberOfSeat: {
        type: Number,
        required: true
    },
    pricePerDay: {
        type: Number,
        required: true
    },
    available: {
        type: Boolean,
        required: true
    }
});

module.exports = {
    carSchema: carSchema    
}
