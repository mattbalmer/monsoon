var controllers = module.exports = require('monsoon').controllers('Product');

controllers.get('/status', function(req, res) {
    res.json({
        status: 'online'
    })
}).configure({ wrap: false });