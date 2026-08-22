import 'dart:io';
import 'dart:isolate';

import 'package:args/args.dart';
import 'package:flutter_iconpicker/Models/icon_pack.dart';
import 'package:flutter_iconpicker/extensions/string_extensions.dart';
import 'package:path/path.dart' as path;

const packs = 'packs';
const all = 'all';
const help = 'help';
const clear = 'clear';

Future<void> main(List<String> arguments) async {
  exitCode = 0; // Presume success

  final parser = ArgParser()
    ..addFlag(help, help: 'Shows how to use generate_packs command', abbr: 'h')
    ..addFlag(clear, help: 'Clears all generated packs', abbr: 'c')
    ..addFlag(all, help: 'Generates all icon packs', abbr: 'a')
    ..addOption(
      packs,
      help:
          'Defines which packs to generate for your project (comma separated)',
      allowedHelp: {
        'material': 'Material Icons',
        'allMaterial':
            'All Material Icons (including rounded, outlined or sharp icons)',
        'sharpMaterial': 'Material Sharp Icons',
        'roundedMaterial': 'Material Rounded Icons',
        'outlinedMaterial': 'Material Outlined Icons',
        'cupertino': 'Cupertino Icons',
        'fontAwesomeIcons': 'Font Awesome Icons',
        'lineAwesomeIcons': 'Line Awesome Icons',
      },
      valueHelp: 'material,cupertino,...',
      defaultsTo: 'material',
      abbr: 'p',
    );

  if (arguments.contains('--help') || arguments.contains('-h')) {
    print(parser.usage);
    return;
  }

  ArgResults argResults = parser.parse(arguments);

  /// Get path of users FlutterIconPicker instance for code generation
  final basePackagePath = await getBasePackagePath();

  final generateAll = argResults[all] as bool;

  if (argResults[clear] as bool) {
    print('🛠️  Removing generated Packs');
  }

  /// 1. Reset Packs to initial state (no packs available)
  emptyIconPacks(packagePath: basePackagePath);

  if (argResults[clear] as bool) {
    print('⚠️  Removed all generated Packs');
    return;
  }

  print('🛠️  Start generating Packs');

  if (generateAll) {
    generateAllIconPacks(packagePath: basePackagePath);
  } else {
    /// 2. Get requiredPacks as List<IconPack> from CLI
    final requiredPacks =
        parseIconPacks((argResults[packs] as String).split(','));

    /// 3. Generate Icons which the developer needs
    for (var pack in requiredPacks) {
      generateIconPack(packagePath: basePackagePath, pack: pack);
    }
  }

  print('✅ Finished generating Packs');
}

void emptyIconPacks({
  required String packagePath,
}) {
  final sourceDir = Directory(path.join(packagePath, 'assets', 'empty_packs'));
  final targetDir =
      Directory(path.join(packagePath, 'lib', 'IconPicker', 'Packs'));

  if (!targetDir.existsSync()) {
    targetDir.createSync(recursive: true);
  }

  if (sourceDir.existsSync()) {
    for (final entity in sourceDir.listSync()) {
      if (entity is File) {
        final destinationPath =
            path.join(targetDir.path, path.basename(entity.path));
        entity.copySync(destinationPath);
      }
    }
  }
}

void generateIconPack({
  required String packagePath,
  required IconPack pack,
}) {
  assert(pack.path.isNotNullOrBlank,
      'Path must be specified if you want to generate ${pack.name} IconPack');

  final sourcePath = path.join(
    packagePath,
    'assets',
    'generated_packs',
    '${pack.path}.dart',
  );
  final destinationPath = path.join(
    packagePath,
    'lib',
    'IconPicker',
    'Packs',
    '${pack.path}.dart',
  );

  final sourceFile = File(sourcePath);
  final destinationFile = File(destinationPath);

  destinationFile.parent.createSync(recursive: true);
  sourceFile.copySync(destinationFile.path);

  print('📦 Generated ${pack.name} IconPack');
}

Future<String> getBasePackagePath() async {
  final packageUri =
      Uri.parse('package:flutter_iconpicker/flutter_iconpicker.dart');
  final packagePath = (await Isolate.resolvePackageUri(packageUri));
  String resultPath = path.dirname(packagePath!.path.replaceAll('lib', ''));
  if (Platform.isWindows) {
    resultPath = resultPath
        .replaceAll(Platform.pathSeparator, '/')
        .replaceFirst('/', '')
        .replaceAll('%20', ' ');
  }
  return resultPath;
}

List<IconPack> parseIconPacks(List<String> rawPacks) {
  List<IconPack> result = <IconPack>[];
  List<String> inputPacks =
      rawPacks.map((name) => name.toLowerCase().trim()).toList();

  for (var pack in IconPack.values) {
    if (inputPacks.contains(pack.name.toLowerCase().trim())) {
      result.add(pack);
    }
  }

  return result;
}

void generateAllIconPacks({required String packagePath}) => IconPack.values
    .where((p) => p.path.isNotNullOrBlank)
    .forEach((pack) => generateIconPack(packagePath: packagePath, pack: pack));
