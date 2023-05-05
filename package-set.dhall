let upstream = https://github.com/dfinity/vessel-package-set/releases/download/mo-0.8.7-20230406/package-set.dhall sha256:cb4ea443519a950c08db572738173a30d37fb096e32bc98f35b78436bae1cd17
let Package =
    { name : Text, version : Text, repo : Text, dependencies : List Text }

let
  additions =
      [{ name = "mospec"
  , repo = "https://github.com/MoSpec/mo-spec"
  , version = "v0.1.0"
  , dependencies = [ "base", "matchers" ]
  }] : List Package

in upstream # additions