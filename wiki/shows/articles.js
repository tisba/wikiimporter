function (doc, req) {
  // !code vendor/wiki/wiki2html.js

  return "<h1>" + doc.title + "</h1>" + wiki2html(doc.text);
}