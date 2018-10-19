# view-loader

Load views for your web framework

### API

A library that provides a `loadViews` macro which helps you to load views based on a variable value known on runtime.

It reads the views filenames from a static path on compile time and generates a `functionName` proc
which renders a view based on a path.  The path should be relative to the source file where you invoke the macro.

It expects that you have pluggable template libs with the API `render(path: static[string]): string`. In this case
it generates a template which looks like

```nim
loadViews(my views path)
```


```nim
template render(path: string): untyped = # path without .nim
  case path:
  of "main_view":
    render("main_view")
  of "home_view":
    render("home_view")
  else:
    raise newException(ViewLoaderException, ..)

```


Usually template libs need a compile time known path for their render macro, so for those cases we generate code to make it possible to pass a runtime path

TODO: add support for multiple path directories and layouts

### Support

discussions with @yyyc514 inspired me to try to work on reusable view tooling

