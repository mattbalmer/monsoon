var m = module.exports = {};

m.overwriteModel = function(document, newDocument) {
    for( var k in newDocument ) {
        if( newDocument.hasOwnProperty(k) && document.schema.paths.hasOwnProperty(k) ) {
            document[k] = newDocument[k];
        }
    }
    for( var k in document.schema.paths ) {
        if( !newDocument.hasOwnProperty(k) && k != '__v' && k != '_id' ) {
            document[k] = undefined;
        }
    }

    return document;
};

m.extendModel = function (document, newDoc) {
    if(Object.keys(newDoc).length == 0)
        return {};

    for(var k in newDoc) {
        if(!newDoc.hasOwnProperty(k)) continue;
        if(typeof newDoc[k] === 'object' && !Array.isArray(newDoc[k]))
            document[k] = extendModel(document[k], newDoc[k]);
        else
            document[k] = newDoc[k];
    }

    return document;
};