import macros, strformat, strutils, os

type
  ViewLoaderException* = object of Exception


macro loadViews*(path: static[string], functionName: untyped = ident("render")): untyped =
  ## Loads the views filenames from a constant path and generates a `functionName` proc
  ## which renders a view based on a path
  ## The function calls render(path: string): string and updateRenderBase(path: string) which is the expected API for
  ## template libs
  ## 
  ## .. code-block:: nim
  ##     loadViews("my_view_dir", render)
  var views: seq[string]
  for view in walkDir(path, relative=true):
    let name = view.path.splitFile[1]
    views.add(name)

  let pathNode = ident"path"
  result = quote:
    template `functionName`*(`pathNode`: string): string =
      discard

  var code = nnkCaseStmt.newTree(pathNode)
  
  for view in views:
    code.add(
      nnkOfBranch.newTree(
        newLit(view),
        quote do: render(`view`)))

  let r = quote:
    raise newException(ViewLoaderException, "missing view")
  
  code.add(
    nnkElse.newTree(
      r    
    ))

  result[^1] = code
  result = quote:
    updateRenderBase(`path`)
    `result`
  echo result.repr


when isMainModule:
  
  discard existsOrCreateDir("views")
  writeFile("views/view.nim", "test")
  loadViews("../views", render)
  var a = "view"
  echo render(a)
