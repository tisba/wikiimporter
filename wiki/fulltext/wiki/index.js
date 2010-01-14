function(doc) {
	var ret=new Document();
                  
  if (doc.text && doc.title) {
    ret.add(doc.text)
    ret.add(doc.title, {"field": "title"})
   
    return ret;
  }
  
  return null;
}