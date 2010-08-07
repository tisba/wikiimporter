function(doc, req) {
  var wiki2html = require('vendor/wiki2html').wiki2html;
  
  if (doc.text) {
    return "<h1>" + doc.title + "</h1>" + wiki2html(doc.text);
  }
}