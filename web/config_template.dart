import 'dart:html';

DivElement parameters = new DivElement();
TextAreaElement template = new TextAreaElement();
TextAreaElement result = new TextAreaElement();
DivElement logbox = new DivElement();

Set<String> paramTable = new Set<String>();

void log(String msg) {
  DivElement entry = new DivElement();
  entry.text = "${new DateTime.now()} $msg";
  logbox.append(entry);
  if (logbox.children.length > 10) {
    logbox.children.removeAt(0);
  }
}

DivElement findParam(String param) {
  
  bool matchParam(Element e) {
    if (e is! DivElement) return false;
    if (e.children.length != 2) return false;
    if (e.children[1] is! InputElement) return false;
    return (e.children[1] as InputElement).name == param;
  }
  
  DivElement d;
  
  try {
    d = parameters.children.firstWhere(matchParam);
  }
  on StateError {
  }
  
  return d;
}

void addParam(String param) {
  
  DivElement d = findParam(param);
  if (d != null) return; // already exists
  
  d = new DivElement();
  
  SpanElement label = new SpanElement();
  label.text = param;
  d.append(label);

  InputElement i = new InputElement();
  void paramChanged(Event e) {
    log("param=$param changed to: [${i.value}]");
  }
  i.name = param;
  i.onInput.listen(paramChanged);
  d.append(i);
    
  parameters.append(d);
  paramTable.add(param);
}

String parse(String str) {
  
  List<String> lines = str.split('\n');
  
  int lineNum = 0;
  
  final String PREFIX = " -- ";
  
  void scanParameters(String rawLine) {
    ++lineNum;
    String line = rawLine.trim();
    if (line.isEmpty) return;
    if (line[0] != '#') return;
    int paramIndex = line.indexOf(PREFIX);
    if (paramIndex < 1) return;
    String paramLine = line.substring(paramIndex + PREFIX.length);
    int blankIndex = paramLine.indexOf(' ');
    String param;
    if (blankIndex < 1) 
      param = paramLine;
    else {
      param = paramLine.substring(0, blankIndex);
    }
    //log("line=$lineNum found param=[$param]");
    addParam(param);
  }
  
  paramTable.clear();
  
  lines.forEach(scanParameters); // build paramTable from input
  
  bool notOnParamTable(Element e) {
    return paramTable.lookup((e.children[1] as InputElement).name) == null;
  }
  
  parameters.children.where(notOnParamTable).toList().forEach((e) => e.remove());
  
  return str;
}

String input;

void templateChanged(Event e) {
  if (input == template.value) {
    return;
  }
  
  log("template changed");
  
  input = template.value.toString(); // save
  result.text = parse(input); // process
}

void main() {
  DivElement root = querySelector("#root_id");
   
  //template.onChange.listen(templateChanged);
  //template.onKeyPress.listen(templateChanged);
  template.onInput.listen(templateChanged);
  template.id = 'template_id';
  result.id = 'result_id';
  result.disabled = true;
  
  root.appendHtml("Parameters:<br>");
  root.append(parameters);
  root.appendHtml("Input template:<br>");
  root.append(template);
  root.appendHtml("<br>Configuration:<br>");  
  root.append(result);
  root.appendHtml("Log:<br>");  
  root.append(logbox);
}

