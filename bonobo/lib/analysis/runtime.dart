part of bonobo.src.analysis;

final Uri runtimeDir = Uri.parse('package:bonobo/runtime');

Resource runtimeResource(String path) => new Resource(runtimeDir.resolve(path));
