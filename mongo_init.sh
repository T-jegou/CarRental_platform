#!/bin/bash

mongosh <<EOF
var rootUser = '${MONGO_INITDB_ROOT_USERNAME}';
var rootPassword = '${MONGO_INITDB_ROOT_PASSWORD}';
var admin = db.getSiblingDB('admin');
admin.auth(rootUser, rootPassword);

var newUser = '${MONGO_INITDB_USERNAME}';
var newPassword = '${MONGO_INITDB_PASSWORD}';
var newDatabase = '${MONGO_INITDB_DATABASE}';

use ${MONGO_INITDB_DATABASE};

db.testcollection.insertOne({test: "test"});
db.createUser({user: newUser, pwd: newPassword, roles: [{role: 'readWrite', db: newDatabase  }]});

EOF