const { Pool } = require('pg');

const pool = new Pool({ 
    host: "db",
    port: 5432,
    user: "andrew",
    password: "ChuckIsGreat!",
    database: "NewTech"
});

module.exports = pool;