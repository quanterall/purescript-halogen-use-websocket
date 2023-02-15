{ name = "halogen-use-websocket"
, dependencies =
  [ "effect"
  , "either"
  , "foreign"
  , "halogen"
  , "halogen-hooks"
  , "maybe"
  , "prelude"
  , "simple-json"
  , "web-socket"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
