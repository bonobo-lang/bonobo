part of bonobo.src.commands;

class DocumentCommand extends Command {
  final String name = 'document';
  final String description =
      'Generates (very basic) documentation for a Bonobo project.';
  BonoboAnalyzer analyzer;

  DocumentCommand() : super() {
    argParser
      ..addFlag('build',
          help: 'Build the documentation into static HTML.',
          negatable: false,
          defaultsTo: false)
      ..addOption('hostname',
          abbr: 'n',
          help: 'The hostname to serve documentation from.',
          defaultsTo: 'localhost')
      ..addOption('port',
          abbr: 'p',
          help: 'The port to serve documentation from.',
          defaultsTo: '0')
      ..addOption('output-dir',
          abbr: 'o',
          help:
              'The local directory to generate documentation into. Only applies in `build` is on.',
          defaultsTo: 'doc');
  }

  @override
  run() async {
    analyzer = await analyze(this);

    var errors =
        analyzer.errors.where((e) => e.severity == BonoboErrorSeverity.error);
    var warnings =
        analyzer.errors.where((e) => e.severity == BonoboErrorSeverity.warning);

    printErrors(errors);
    printErrors(warnings);

    if (errors.isNotEmpty) if (argResults['build'])
      return exitCode = 1;
    else
      stderr.writeln('Still serving documentation, despite errors.');

    var app = await createServer(analyzer);
    var http = new AngelHttp(app);
    var server = await http.startServer(argResults['hostname'],
        int.parse(argResults['port'], onError: (_) => 0));
    var address =
        server.address.isLoopback ? 'localhost' : server.address.address;
    print('Bonobo documentation server listening at http://$address:${server
        .port}');
  }

  String normalizeName(String s) {
    return s; //.replaceAll('.', '.');
  }

  void writeSource(StringBuffer b, FileSpan span) {
    b.writeln('<h4>Source:</h4><pre><code class="dart">${span?.text ?? ""}</code></pre>');
  }

  Future<Angel> createServer(BonoboAnalyzer analyzer) async {
    var app = new Angel();
    app.inject(BonoboModule, analyzer.module);

    bool resolveModule(RequestContext req) {
      var name = req.params['name'] as String;
      var split = name.split('::');

      BonoboModule module = analyzer.module;
      var ceil =
          req.path.startsWith('module') ? split.length : split.length - 1;

      for (int i = 1; i < ceil; i++) {
        var child = module.children
            .firstWhere((m) => m.name == split[i], orElse: () => null);

        if (child == null)
          throw new AngelHttpException.notFound(
              message: "Unknown module '${split[i]}'.");

        module = child;
      }

      req..inject(BonoboModule, module)..inject('symbol', split.last);
      return true;
    }

    app.get('/', renderModule);
    app.chain(resolveModule).get('/module/:name', renderModule);
    app.chain(resolveModule).get('/symbol/:name', renderSymbol);
    app.chain(resolveModule).get('/type/:name', renderType);

    return app;
  }

  String writeHtml(ResponseContext res,
      {String title,
      void Function(StringBuffer) head,
      void Function(StringBuffer) header,
      void Function(StringBuffer) body,
      void Function(StringBuffer) scripts}) {
    var primary = 'teal' ?? '#3f51b5', bg = '#f1f1f1', white = 'white';

    var b = new StringBuffer();
    b.writeln('''
<doctype html>
<html>
  <head>
    <base href="/">
    <title>${title ?? 'Bonobo Documentation'}</title>
    <link href="https://fonts.googleapis.com/css?family=Roboto" rel="stylesheet">
    <link rel="stylesheet"
      href="//cdnjs.cloudflare.com/ajax/libs/highlight.js/9.12.0/styles/default.min.css">
    <style>
      html, body {
        font-family: 'Roboto', sans-serif;
        margin: 0;
        padding: 0;
        -webkit-font-smoothing: antialiased;
      }
      
      header {
        background-color: $primary;
        box-shadow: 0 3px 5px rgba(0,0,0,0.1);
        color: $white;
        padding: 0.3em 1em;
      }
      
      header h1 {
        font-weight: normal;
        margin-top: 0;
      }
      
      header ul {
        list-style-type: none; padding: 0;
        margin-bottom: 2em;
      }
      
      header ul li {
        display: inline;
      }
      
      header ul li a {
        color: $white;
        text-decoration: none;
      }
      
      header ul li a:hover {
        text-decoration: underline;
      }
      
      label {
        color: #ddd;
        margin-bottom: 0;
        text-transform: uppercase;
      }
      
      main {
        padding: 1em;
      }
      
      main a {
        color: $primary;
        text-decoration: none;
      }
      
      main ul {
        list-style-type: none;
        padding: 0;
      }
      
      main li {
        margin-bottom: 1em;
      }
      
      pre {
        background-color: $bg;
        padding: 1em;
      }
    </style>
    ''');

    if (head != null) head(b);

    b.writeln('''
  </head>
  <body>
    <header>
      <ul>''');

    var module =
        res.correspondingRequest.injections[BonoboModule] as BonoboModule;

    var links = <String>[];

    var p = module.parent;

    while (p != null && !p.isRoot) {
      links.insert(0, '''
        <li>
          <a href="/module/${normalizeName(p.fullName)}">
            ${p.name}
          </a>
          &raquo;
        </li>
        ''');
      p = p.parent;
    }

    links.forEach(b.writeln);

    b.writeln('''
        <li style="color: #ddd;">${module.name}</li>
      </ul>''');

    if (header != null) header(b);

    b.writeln('''
    </header>
    <main>
    ''');

    if (body != null) body(b);

    // TODO: Custom scripts?

    b.writeln('</main>');

    if (scripts != null) scripts(b);

    b..writeln('''
      <script src="//cdnjs.cloudflare.com/ajax/libs/highlight.js/9.12.0/highlight.min.js"></script>
      <script src="//cdnjs.cloudflare.com/ajax/libs/highlight.js/9.12.0/languages/bash.min.js"></script>
      <script src="//cdnjs.cloudflare.com/ajax/libs/highlight.js/9.12.0/languages/dart.min.js"></script>
      <script>hljs.initHighlightingOnLoad();</script>
  </body>
</html>
    ''');

    return b.toString().trim();
  }

  void renderHtml(ResponseContext res, String html) {
    res
      ..contentType = ContentType.HTML
      ..write(html)
      ..end();
  }

  void renderModule(BonoboModule module, ResponseContext res) {
    renderHtml(
      res,
      writeHtml(
        res,
        title: module.name,
        header: (b) {
          b.writeln('<label>module</label><h1>${module.name}</h1>');
        },
        body: (b) {
          File readmeFile = module.directory.listSync().firstWhere(
              (e) =>
                  e is File && p.basename(e.path).toLowerCase() == 'readme.md',
              orElse: () => null);

          if (readmeFile?.existsSync() == true) {
            b.writeln(markdownToHtml(readmeFile.readAsStringSync()));
          }

          if (module.children.isNotEmpty) {
            b.writeln('<h3 id="children">Children (${module.children
                .length}):</h3><ul>');
            for (var child in module.children) b.writeln('''
              <li>
                <a
                  href="/module/${normalizeName(child.fullName)}"
                  title="Module ${child.name}">
                    <b>${child.name}</b>
                </a>
              </li>''');
            b.writeln('</ul>');
          }

          if (module.types.isNotEmpty) {
            b.writeln(
                '<h3 id="types">Types (${module.types.length}):</h3><ul>');
            for (var name in module.types.keys) {
              b.writeln('''
              <li>
                <a
                  href="/type/${normalizeName(module.fullName)}::$name"
                  title="Type $name">
                    <b>$name</b>
                </a>
              </li>''');
            }
            b.writeln('</ul>');
          }

          var public = module.scope.allPublicVariables;

          if (public.isNotEmpty) {
            b.writeln(
                '<h3 id="symbols">Public Symbols (${public.length}):</h3><ul>');
            for (var symbol in public) {
              b.writeln('''
              <li>
                <a
                  href="/symbol/${normalizeName(module.fullName)}::${symbol
                  .name}"
                  title="${symbol.name}">
                    <b>${symbol.name}</b>
                </a>
              </li>''');
            }
            b.writeln('</ul>');
          }
        },
      ),
    );
  }

  void renderType(BonoboModule module, String symbol, ResponseContext res) {
    var type = module.types[symbol],
        docs = type?.documentation,
        span = type?.span;
    if (type == null)
      throw new AngelHttpException.notFound(
          message: "Unknown type '${module.fullName}::$symbol'.");
    else if (type is BonoboTypedef) type = (type as BonoboTypedef).type;

    renderHtml(
        res,
        writeHtml(
          res,
          title: 'Type $symbol',
          header: (b) {
            b.writeln('<label>typedef</label><h1>$symbol</h1>');
          },
          body: (b) {
            b.writeln(markdownToHtml(docs));

            if (type is BonoboEnumType)
              renderEnum(b, type);
            else if (type is BonoboTupleType)
              renderTupleType(b, type);
            else if (type is BonoboStructType)
              renderStructType(b, type);
            else if (type is BonoboFunctionType)
              renderFunctionType(b, type);
            else
              b.writeln(type.runtimeType);

            writeSource(b, span);
          },
        ));
  }

  void renderSymbol(BonoboModule module, String symbol, ResponseContext res) {
    var obj = module.scope.allPublicVariables
            .firstWhere((s) => s.name == symbol, orElse: () => null)
            ?.value,
        docs = '',
        span = obj?.span;

    if (obj == null)
      throw new AngelHttpException.notFound(
          message: "Unknown symbol '${module.fullName}::$symbol'.");
    else if (obj is BonoboFunction &&
        obj.declaration?.comments?.isNotEmpty == true) docs = obj.documentation;

    renderHtml(
        res,
        writeHtml(
          res,
          title: 'Symbol $symbol',
          header: (b) {
            b.writeln('<label>${obj.type.name}</label><h1>$symbol</h1>');
          },
          body: (b) {
            b
              .writeln(markdownToHtml(docs));

            /*if (obj is BonoboEnumType)
              renderEnum(b, obj);
            else if (obj is BonoboTupleType)
              renderTupleType(b, obj);
            else if (obj is BonoboStructType)
              renderStructType(b, obj);
            else if (obj is BonoboFunctionType)
              renderFunctionType(b, obj);
            else*/
            if (obj is BonoboFunction)
              renderFunction(b, obj);
            else
              b.writeln(obj.runtimeType);

            writeSource(b, span);
          },
        ));
  }

  void renderEnum(StringBuffer b, BonoboEnumType type) {
    b.writeln('<ul>');
    type.values.forEach((v) => b.writeln('''
        <li>
          <b>${v.name}</b> = ${v.index ?? type.values.indexOf(v)}
        </li>
        '''));
    b.writeln('</ul>');
  }

  void renderTupleType(StringBuffer b, BonoboTupleType type) {
    b.write('(');

    for (int i = 0; i < type.types.length; i++) {
      if (i > 0) b.write(',&nbsp;');
      var t = type.types[i];
      b.write('<span><b>$t</b></span>');
    }

    b.write(')');
  }

  void renderStructType(StringBuffer b, BonoboStructType type) {
    b.write('<h2>Fields (${type.fields.length}):</h2><ul>');
    type.fields.forEach((name, type) {
      b.write('<li>$name: <b>$type</b></li>');
    });
    b.writeln('</ul>');
  }

  void renderFunctionType(StringBuffer b, BonoboFunctionType type) {
    b.writeln('<p>Returns: <b>${type.returnType?.toString() ??
        BonoboType.Root.toString()}</b></p>');

    if (type.parameters.isNotEmpty) {
      b.writeln('<h2>Parameters (${type.parameters.length}):</h2><ul>');
      type.parameters.forEach((p) => b.writeln('<li><b>$p</b></li>'));
      b.writeln('</ul>');
    }
  }

  void renderFunction(StringBuffer b, BonoboFunction obj) {
    b.writeln('<p>Returns: <b>${obj.returnType?.toString() ??
        BonoboType.Root.toString()}</b></p>');

    if (obj.parameters.isNotEmpty) {
      b.writeln('<h2>Parameters (${obj.parameters.length}):</h2><ul>');
      obj.parameters
          .forEach((p) => b.writeln('<li>${p.name}: <b>${p.type}</b></li>'));
      b.writeln('</ul>');
    }
  }
}
