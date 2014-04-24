import 'dart:html';

import 'package:mustache/mustache.dart' as mustache;

DivElement parameters = new DivElement();
TextAreaElement template = new TextAreaElement();
TextAreaElement result = new TextAreaElement();
DivElement logbox = new DivElement();
Map paramTable = {};

void log(String msg) {
  DivElement entry = new DivElement();
  entry.text = "${new DateTime.now()} $msg";
  print(entry.text);
  logbox.append(entry);
  if (logbox.children.length > 100) {
    logbox.children.removeAt(0);
  }
}

void newParam(String param) {
  String value = paramTable[param];
  if (value != null) return; // already exists
  paramTable[param] = "";
}

void parseParameters(String str) {
  
  List<String> lines = str.split('\n');
  
  int lineNum = 0;
  
  final String PREFIX = " -- ";
  
  void scanParameters(String rawLine) {
    ++lineNum;
    String line = rawLine.trim();
    if (line.isEmpty) return;
    
    /*
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
    */
    
    if (line[0] == '#') return;
    
    RegExp exp = new RegExp(r"{{([^{}]+)}}");
    Iterable<Match> matches = exp.allMatches(line);
    for (Match m in matches) {
      String param = m.group(1);
      log("line=$lineNum found param=[$param]");
      newParam(param);
    }
    
  }
  
  // clear paramTable
  paramTable.clear();
  
  // build paramTable from input
  lines.forEach(scanParameters);
  
  // save existing form values
  parameters.children.where((e) => paramTable[(e.children[1] as InputElement).name] != null).forEach((e) {
    InputElement i = e.children[1] as InputElement;
    paramTable[i.name] = i.value;
  });
  
  // clear form
  parameters.children.clear();
   
  // rebuild form
  int n = 0;
  paramTable.forEach((param, value) {
    ++n;
    
    DivElement d = new DivElement();
    
    SpanElement label = new SpanElement();
    label.text = "$n. $param";
    d.append(label);

    InputElement i = new InputElement();

    void paramChanged(Event e) {
      log("parameter [$param] changed from=[${paramTable[param]}] to=[${i.value}]");
      paramTable[param] = i.value;
      updateResult();
    }

    i.onInput.listen(paramChanged);
    i.name = param;
    i.value = value;
    d.append(i);
      
    parameters.append(d);    
  });
  
}

void updateResult() {
  //log("updateResult: ${paramTable}");
  
  mustache.Template t = mustache.parse(template.value);
  result.text = t.renderString(paramTable);
  
  log("result updated");
}

String saved_input;

void templateChanged(Event e) {
  if (saved_input == template.value) {
    return;
  }
  
  log("template changed");

  saved_input = template.value.toString(); // save template

  parseParameters(template.value);
  
  updateResult();
}

void main() {
  DivElement root = querySelector("#root_id");
   
  template.onInput.listen(templateChanged);
  template.id = 'template_id';
  result.id = 'result_id';
  logbox.id = 'logbox_id';
  result.disabled = true;
  
  root.append(parameters);
  root.appendHtml("INPUT:<br>");
  root.append(template);
  root.appendHtml("<br>CONFIGURATION:<br>");  
  root.append(result);
  root.appendHtml("<br>LOG:<br>");  
  root.append(logbox);
}

