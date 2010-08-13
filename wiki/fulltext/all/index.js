function(doc) {
  var ret = new Document();

  if (doc.title) ret.add(doc.title, {"field":"title"})
  if (doc.text) ret.add(doc.title, {"field":"text"})

  return ret;
}