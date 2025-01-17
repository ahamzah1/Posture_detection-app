const app = require('./app') // The Express app
const config = require('./src/services/config')
const logger = require('./src/services/logger')

app.listen(config.PORT,"0.0.0.0",()=>{
    console.log(`Listening on local Ip address at port ${config.PORT}`);
});