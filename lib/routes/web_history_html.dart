import 'dart:html' as html;

void updateWebHistory(String location, {bool replace = false}) {
  final normalized = location.startsWith('/') ? location : '/$location';
  final browserLocation = '#$normalized';

  // Mirror the current Flutter Navigator stack without creating a second
  // browser history stack that could diverge from Navigator.pop().
  html.window.history.replaceState(null, '', browserLocation);
}
