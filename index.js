module.exports = {
    router: require('./lib/Router').router,
    export: require('./lib/export').toExpressRouter
};