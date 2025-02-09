const config = require('./src/services/config')
const express = require("express")
const cors = require('cors')
const usersRouter = require('./src/routers/users')
const loginRouter = require('./src/routers/login')

const middleware = require('./src/services/middleware')
const logger = require('./src/services/logger')
const mongoose = require('mongoose')

const app = express()

mongoose.set('strictQuery', false)

mongoose.connect(config.MONGODB_URI)
  .then(() => {
    logger.info('connected to MongoDB')
  })
  .catch((error) => {
    logger.error('error connection to MongoDB:', error.message)
  })

app.use(cors())
app.use(express.json())
app.use(middleware.requestLogger)

app.use('/api/users', usersRouter)
app.use('/api/login', loginRouter)

app.use(middleware.unknownEndpoint)
app.use(middleware.errorHandler)

module.exports = app