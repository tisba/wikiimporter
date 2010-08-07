function (doc) {
  if (doc.text) {
    doc.text.replace(/\[\[(Kategorie|Category)\: ?([^\]\|]*)/g, function(foo,bar,cat) {
      emit(cat, 1);
      return "";
    });
  }
}