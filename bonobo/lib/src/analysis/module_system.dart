part of bonobo.src.analysis;

class BonoboModuleSystem {
  final Directory rootDirectory;
  BonoboModule _rootModule;

  BonoboModuleSystem(this.rootDirectory) {
    _rootModule = new BonoboModule._root(rootDirectory, this);
  }

  FileSystem get fileSystem => rootDirectory.fileSystem;

  BonoboModule get rootModule => _rootModule;

  
}
