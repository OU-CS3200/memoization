(** Measure what the cache buys: the same step function run with [Memo.fix]
    (no cache) and with your [Memo.memo_rec], counting how many times the
    body runs and how long it takes.

    {v
      dune exec bin/main.exe -- fib 30
      dune exec bin/main.exe -- edit kitten sitting
      dune exec bin/main.exe -- change 100 1 5 10 25
      dune exec bin/main.exe -- lcs ABCBDAB BDCABA
      dune exec bin/main.exe -- grid 14
    v}

    The no-cache run is skipped when it would take too long (--no-naive
    skips it always). *)

let fib_step (self : int -> int) (n : int) : int =
  if n < 2 then n else self (n - 1) + self (n - 2)

let time (f : unit -> 'a) : 'a * float =
  let t0 = Unix.gettimeofday () in
  let r = f () in
  (r, Unix.gettimeofday () -. t0)

let compare_runs (label : string) (step : ('a -> int) -> 'a -> int) (start : 'a) (naive_ok : bool) : unit =
  Printf.printf "%s\n" label;
  let row (name : string) (tie : (('a -> int) -> 'a -> int) -> 'a -> int) : unit =
    let calls = ref 0 in
    let (v, secs) = time (fun () -> tie (Memo.counting calls step) start) in
    Printf.printf "  %-10s value %-14d calls %-12d %.4f s\n" name v !calls secs
  in
  if naive_ok then row "no cache" Memo.fix else print_endline "  no cache   (skipped: too slow)";
  row "memo_rec" Memo.memo_rec

let () =
  let args = List.tl (Array.to_list Sys.argv) in
  let no_naive = List.mem "--no-naive" args in
  let args = List.filter (fun (a : string) -> a <> "--no-naive") args in
  match args with
  | [ "fib"; n ] ->
    let n = int_of_string n in
    compare_runs (Printf.sprintf "fib %d" n) fib_step n ((not no_naive) && n <= 35)
  | [ "edit"; a; b ] ->
    compare_runs (Printf.sprintf "edit_distance %S %S" a b) (Dp.edit_step a b) (0, 0)
      ((not no_naive) && String.length a + String.length b <= 22)
  | [ "lcs"; a; b ] ->
    compare_runs (Printf.sprintf "lcs_length %S %S" a b) (Dp.lcs_step a b) (0, 0)
      ((not no_naive) && String.length a + String.length b <= 30)
  | "change" :: amount :: coins when coins <> [] ->
    let coins = Array.of_list (List.map int_of_string coins) in
    let amount = int_of_string amount in
    compare_runs (Printf.sprintf "count_change %d" amount) (Dp.change_step coins) (0, amount)
      ((not no_naive) && amount <= 300)
  | [ "grid"; n ] ->
    let n = int_of_string n in
    let (v, secs) = time (fun () -> Handmemo.grid_paths (Array.make_matrix n n true)) in
    Printf.printf "grid_paths on an open %dx%d grid: %d paths, %.4f s\n" n n v secs
  | _ ->
    prerr_endline "usage: main.exe (fib N | edit A B | lcs A B | change AMOUNT COIN... | grid N) [--no-naive]";
    exit 1
