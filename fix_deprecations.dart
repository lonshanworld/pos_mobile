import 'dart:io';

void main() {
  final dir = Directory('lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  int totalFixed = 0;

  for (final file in files) {
    String content = file.readAsStringSync();
    bool modified = false;

    // Replace .withOpacity(x) with .withValues(alpha: x)
    final withOpacityRegExp = RegExp(r'\.withOpacity\(([^)]+)\)');
    if (withOpacityRegExp.hasMatch(content)) {
      content = content.replaceAllMapped(withOpacityRegExp, (match) {
        return '.withValues(alpha: ${match.group(1)})';
      });
      modified = true;
    }

    // Replace MaterialStateProperty with WidgetStateProperty
    if (content.contains('MaterialStateProperty')) {
      content = content.replaceAll('MaterialStateProperty', 'WidgetStateProperty');
      modified = true;
    }

    // Replace activeColor with activeThumbColor (mostly for Switches/Sliders)
    if (content.contains('activeColor:')) {
      content = content.replaceAll('activeColor:', 'activeThumbColor:');
      modified = true;
    }

    // Replace onPopInvoked with onPopInvokedWithResult
    if (content.contains('onPopInvoked:')) {
      content = content.replaceAll('onPopInvoked:', 'onPopInvokedWithResult:');
      // Fix the closure signature from (didPop) to (didPop, result)
      content = content.replaceAll('(didPop)', '(didPop, result)');
      // If it has type annotations like (bool didPop)
      content = content.replaceAll('(bool didPop)', '(bool didPop, dynamic result)');
      modified = true;
    }

    if (modified) {
      file.writeAsStringSync(content);
      print('Fixed ${file.path}');
      totalFixed++;
    }
  }

  print('Finished! Fixed $totalFixed files.');
}
