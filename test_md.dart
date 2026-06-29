import 'package:markdown/markdown.dart' as md;
void main() {
  var el = md.Element('p', []);
  print(el.textContent);
}
