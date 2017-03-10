
let cmd_test_case ~term ~argv ~expected ~pprinter what =
  let info = Cmdliner.Term.info "cmd" in
  Alcotest.(check (of_pp pprinter)) what expected
    begin match Cmdliner.Term.eval ~argv (term, info) with
    | `Error msg -> assert false
    | `Ok actual -> actual
    | `Version -> assert false
    | `Help -> assert false
    end


type common_types = {
  a1: string;
  b1: int;
  c1: float;
  d1: string option;
  e1: string list;
  f1: int array;
  g1: int list;
  h1: bool;
} [@@deriving cmdliner,show]
let simple () =
  let argv = [|
    "cmd";
    "--a1"; "apple";
    "--b1"; "123";
    "--c1"; "1.20";
    "--d1"; "yes";
    "--e1"; "apple,banana,pear";
    "--f1"; "1,2,3,4,5";
    "--g1"; "100,200,300";
    "--h1";
  |] in
  let expected = {
    a1 = "apple";
    b1 = 123;
    c1 = 1.20;
    d1 = Some "yes";
    e1 = ["apple";"banana";"pear"];
    f1 = [|1;2;3;4;5|];
    g1 = [100;200;300];
    h1 = true
  } in
  cmd_test_case "expected simple types to match"
    ~term:(common_types_cmdliner_term ())
    ~argv ~expected ~pprinter:pp_common_types


type default_types = {
  a1: string; [@default "apple"]
  b1: int; [@default 10]
  c1: float; [@default 1.20]
  e1: string list; [@default []]
  f1: int array; [@default [|1;2;3|]]
  g1: int list; [@default [1;2;3]]
  h1: bool; [@default true]
} [@@deriving cmdliner,show]
let defaults () =
  let argv = [|
    "cmd";
  |] in
  let expected = {
    a1 = "apple";
    b1 = 10;
    c1 = 1.20;
    e1 = [];
    f1 = [|1;2;3|];
    g1 = [1;2;3];
    h1 = true
  } in
  cmd_test_case "expected defaults to work"
    ~term:(default_types_cmdliner_term ())
    ~argv ~expected ~pprinter:pp_default_types


type env_types = {
  a1: string; [@env "A_ONE_ENV"]
} [@@deriving cmdliner,show]
let env () =
  let argv = [|
    "cmd";
  |] in
  let expected = {
    a1 = "foobar";
  } in
  Unix.putenv "A_ONE_ENV" "foobar";
  cmd_test_case "expected env variables to work"
    ~term:(env_types_cmdliner_term ())
    ~argv ~expected ~pprinter:pp_env_types


type list_sep_types = {
  a1: int list; [@sep '@']
  b1: string array; [@sep '*']
} [@@deriving cmdliner,show]
let list_sep () =
  let argv = [|
    "cmd";
    "--a1";
    "1@9@3@5";
    "--b1";
    "foo*bar*baz";
  |] in
  let expected = {
    a1 = [1;9;3;5];
    b1 = [|"foo"; "bar"; "baz"|]
  } in
  cmd_test_case "expected custom list sep to work"
    ~term:(list_sep_types_cmdliner_term ())
    ~argv ~expected ~pprinter:pp_list_sep_types


type pos_types = {
  a1: string; [@pos 1]
  b1: int; [@pos 0]
} [@@deriving cmdliner,show]
let positional () =
  let argv = [|
    "cmd";
    "1";
    "second-pos";
  |] in
  let expected = {
    a1 = "second-pos";
    b1 = 1
  } in
  cmd_test_case "expected positional args to work"
    ~term:(pos_types_cmdliner_term ())
    ~argv ~expected ~pprinter:pp_pos_types



let test_set = [
  "simple types" , `Quick, simple;
  "default types" , `Quick, defaults;
  "ENV types" , `Quick, env;
  "list sep types" , `Quick, list_sep;
  "positional types" , `Quick, positional;
]

let () =
  Alcotest.run "Ppx_deriving_cmdliner" [
    "****", test_set;
  ]