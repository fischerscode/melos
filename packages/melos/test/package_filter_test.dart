import 'package:melos/melos.dart';
import 'package:melos/src/common/io.dart';
import 'package:path/path.dart' as p;
import 'package:pubspec/pubspec.dart';
import 'package:test/test.dart';

import 'utils.dart';

void main() {
  group('PackageFilter', () {
    test('dirExists', () async {
      final workspaceDir = createTemporaryWorkspaceDirectory();

      final aDir = await createProject(
        workspaceDir,
        const PubSpec(name: 'a'),
      );
      ensureDir(p.join(aDir.path, 'test'));

      await createProject(
        workspaceDir,
        const PubSpec(name: 'b'),
      );

      final config = await MelosWorkspaceConfig.fromDirectory(workspaceDir);
      final workspace = await MelosWorkspace.fromConfig(
        config,
        logger: TestLogger().toMelosLogger(),
        filter: PackageFilter(
          dirExists: const ['test'],
        ),
      );

      expect(
        workspace.allPackages.values,
        [
          isA<Package>().having((p) => p.name, 'name', 'a'),
          isA<Package>().having((p) => p.name, 'name', 'b'),
        ],
      );
      expect(
        workspace.filteredPackages.values,
        [isA<Package>().having((p) => p.name, 'name', 'a')],
      );
    });

    test('fileExists', () async {
      final workspaceDir = createTemporaryWorkspaceDirectory();

      final aDir = await createProject(
        workspaceDir,
        const PubSpec(name: 'a'),
      );
      writeTextFile(p.join(aDir.path, 'log.txt'), '');

      await createProject(
        workspaceDir,
        const PubSpec(name: 'b'),
      );

      final config = await MelosWorkspaceConfig.fromDirectory(workspaceDir);
      final workspace = await MelosWorkspace.fromConfig(
        config,
        logger: TestLogger().toMelosLogger(),
        filter: PackageFilter(
          fileExists: const ['log.txt'],
        ),
      );

      expect(
        workspace.allPackages.values,
        [
          isA<Package>().having((p) => p.name, 'name', 'a'),
          isA<Package>().having((p) => p.name, 'name', 'b'),
        ],
      );
      expect(
        workspace.filteredPackages.values,
        [isA<Package>().having((p) => p.name, 'name', 'a')],
      );
    });
  });
}
