(* Memoization tests. Run with:  dune test
   To run one group:          dune exec test/test_memo.exe -- test combinators

   The speed tests give each computation a few seconds. A version without
   a working cache does not finish in that time, so it fails with
   "Timeout" instead of hanging. *)

open Alcotest

exception Timeout

(** [within secs f]: [f ()], or [Timeout] after [secs] seconds. *)
let within (secs : float) (f : unit -> 'a) : 'a =
  let old = Sys.signal Sys.sigalrm (Sys.Signal_handle (fun (_ : int) -> raise Timeout)) in
  let set (t : float) : unit =
    ignore (Unix.setitimer Unix.ITIMER_REAL { Unix.it_interval = 0.0; it_value = t })
  in
  set secs;
  Fun.protect ~finally:(fun () -> set 0.0; Sys.set_signal Sys.sigalrm old) f

let fast (msg : string) (expected : int) (f : unit -> int) : unit =
  match within 3.0 f with
  | v -> (check int) msg expected v
  | exception Timeout -> failf "%s: still running after 3 seconds; is the cache used?" msg

(* ------------------------------------------------------------------ *)
(* Part A — by hand                                                   *)
(* ------------------------------------------------------------------ *)

let test_fib () =
  (check (list int)) "fib 0 .. 10" [ 0; 1; 1; 2; 3; 5; 8; 13; 21; 34; 55 ]
    (List.init 11 Handmemo.fib);
  (check int) "agrees with fib_naive at 25" (Handmemo.fib_naive 25) (Handmemo.fib 25);
  fast "fib 50" 12586269025 (fun () -> Handmemo.fib 50);
  fast "fib 90" 2880067194370816120 (fun () -> Handmemo.fib 90)

let open_grid (r : int) (c : int) : bool array array = Array.make_matrix r c true

let test_grid_paths () =
  (check int) "1x1" 1 (Handmemo.grid_paths (open_grid 1 1));
  (check int) "3x3" 6 (Handmemo.grid_paths (open_grid 3 3));
  (check int) "1x7: one way" 1 (Handmemo.grid_paths (open_grid 1 7));
  let g = open_grid 4 4 in
  g.(1).(1) <- false;
  g.(2).(2) <- false;
  (check int) "4x4, two blocked cells" 4 (Handmemo.grid_paths g);
  let s = open_grid 3 3 in
  s.(0).(0) <- false;
  (check int) "blocked start" 0 (Handmemo.grid_paths s);
  let e = open_grid 3 3 in
  e.(2).(2) <- false;
  (check int) "blocked end" 0 (Handmemo.grid_paths e);
  fast "open 18x18" 2333606220 (fun () -> Handmemo.grid_paths (open_grid 18 18));
  let n = 30 in
  let big =
    Array.init n (fun (r : int) ->
        Array.init n (fun (c : int) ->
            not ((r * 7 + c * 3) mod 11 = 0 && (r, c) <> (0, 0) && (r, c) <> (n - 1, n - 1))))
  in
  fast "30x30 with obstacles" 11856863193075 (fun () -> Handmemo.grid_paths big)

(* ------------------------------------------------------------------ *)
(* Part B — combinators                                               *)
(* ------------------------------------------------------------------ *)

let test_memo () =
  let calls = ref 0 in
  let square (x : int) : int = incr calls; x * x in
  let m = Memo.memo square in
  (check int) "first call" 16 (m 4);
  (check int) "second call" 16 (m 4);
  (check int) "another argument" 25 (m 5);
  (check int) "square ran once per distinct argument" 2 !calls;
  let m2 = Memo.memo square in
  ignore (m2 4);
  (check int) "a second memo has its own cache" 3 !calls;
  let lcalls = ref 0 in
  let len (s : string) : int = incr lcalls; String.length s in
  let ml = Memo.memo len in
  List.iter (fun (s : string) -> ignore (ml s)) [ "ab"; "cde"; "ab"; "ab"; "cde" ];
  (check int) "string keys" 2 !lcalls;
  let pcalls = ref 0 in
  let add ((a, b) : int * int) : int = incr pcalls; a + b in
  let mp = Memo.memo add in
  (check int) "pair key" 7 (mp (3, 4));
  ignore (mp (3, 4));
  ignore (mp (4, 3));
  (check int) "(3, 4) and (4, 3) are different keys" 2 !pcalls

let fib_step (self : int -> int) (n : int) : int = if n < 2 then n else self (n - 1) + self (n - 2)

let test_memo_rec () =
  (check (list int)) "fib 0 .. 10" [ 0; 1; 1; 2; 3; 5; 8; 13; 21; 34; 55 ]
    (List.init 11 (Memo.memo_rec fib_step));
  let calls = ref 0 in
  let f = Memo.memo_rec (Memo.counting calls fib_step) in
  (check int) "fib 30" 832040 (f 30);
  (check int) "the body ran once for each of 0 .. 30" 31 !calls;
  ignore (f 30);
  (check int) "asking again runs nothing" 31 !calls;
  fast "fib 90" 2880067194370816120 (fun () -> Memo.memo_rec fib_step 90);
  let ccalls = ref 0 in
  let collatz (self : int -> int) (n : int) : int =
    if n = 1 then 0 else 1 + self (if n mod 2 = 0 then n / 2 else 3 * n + 1)
  in
  let steps = Memo.memo_rec (Memo.counting ccalls collatz) in
  (check int) "collatz 27" 111 (steps 27);
  (check int) "collatz 27: 112 distinct numbers on the way" 112 !ccalls

(* ------------------------------------------------------------------ *)
(* Part C — dynamic programming                                       *)
(* ------------------------------------------------------------------ *)

let a60 = "CTGTCACCCGGTCACAATTGCAAAGGCCTATTCAGCCCGTGGCCGAGGGACCGAACGTTC"
let b55 = "CCATCACCGCCTCCTCGAGTAGTAGTGAACTGTTTCAGCCTTGGGGTCGTGCTGC"
let c80 = "CTAGCCATTACCCAGTAGATGGGACATTACCTCCAGTGAAGAACCCCTTTGCTTATCGAACATGCCGAGATTTAAATTGA"
let d70 = "CTGCACAATAGTGTGCAAGCCCCCCAAACATTTCGATGTCTGAATCAGGTACATCCAAGTTATGTGAGAA"

let test_edit () =
  (check int) "kitten / sitting" 3 (Dp.edit_distance "kitten" "sitting");
  (check int) "flaw / lawn" 2 (Dp.edit_distance "flaw" "lawn");
  (check int) "intention / execution" 5 (Dp.edit_distance "intention" "execution");
  (check int) "empty / abc" 3 (Dp.edit_distance "" "abc");
  (check int) "abc / empty" 3 (Dp.edit_distance "abc" "");
  (check int) "equal" 0 (Dp.edit_distance "ocaml" "ocaml");
  fast "60 and 55 letters" 30 (fun () -> Dp.edit_distance a60 b55);
  fast "80 and 70 letters" 40 (fun () -> Dp.edit_distance c80 d70)

let test_change () =
  (check int) "5 from 1, 2, 5" 4 (Dp.count_change [| 1; 2; 5 |] 5);
  (check int) "3 from 2" 0 (Dp.count_change [| 2 |] 3);
  (check int) "0 cents: one way" 1 (Dp.count_change [| 1; 5 |] 0);
  (check int) "no coins" 0 (Dp.count_change [||] 7);
  (check int) "a dollar" 293 (Dp.count_change [| 1; 5; 10; 25; 50; 100 |] 100);
  (check int) "order of the coins does not matter" 293
    (Dp.count_change [| 100; 25; 1; 50; 10; 5 |] 100);
  fast "ten dollars" 2103596 (fun () -> Dp.count_change [| 1; 5; 10; 25; 50; 100 |] 1000);
  fast "fifty euros" 10082315214426
    (fun () -> Dp.count_change [| 1; 2; 5; 10; 20; 50; 100; 200 |] 5000)

let test_lcs () =
  (check int) "ABCBDAB / BDCABA" 4 (Dp.lcs_length "ABCBDAB" "BDCABA");
  (check int) "AGGTAB / GXTXAYB" 4 (Dp.lcs_length "AGGTAB" "GXTXAYB");
  (check int) "empty" 0 (Dp.lcs_length "" "abc");
  (check int) "nothing in common" 0 (Dp.lcs_length "abc" "xyz");
  (check int) "equal" 5 (Dp.lcs_length "ocaml" "ocaml");
  fast "60 and 55 letters" 36 (fun () -> Dp.lcs_length a60 b55);
  fast "80 and 70 letters" 49 (fun () -> Dp.lcs_length c80 d70)

(* ------------------------------------------------------------------ *)
(* Style                                                              *)
(* ------------------------------------------------------------------ *)

(** The source with comments and string literals blanked out. *)
let code_of (path : string) : string =
  let s = In_channel.with_open_text path In_channel.input_all in
  let b = Buffer.create (String.length s) in
  let n = String.length s in
  let rec go (i : int) (depth : int) (in_str : bool) : unit =
    if i >= n then ()
    else if in_str then
      if s.[i] = '\\' then (Buffer.add_string b "  "; go (i + 2) depth true)
      else if s.[i] = '"' then (Buffer.add_char b ' '; go (i + 1) depth false)
      else (Buffer.add_char b ' '; go (i + 1) depth true)
    else if i + 1 < n && s.[i] = '(' && s.[i + 1] = '*' then
      (Buffer.add_string b "  "; go (i + 2) (depth + 1) false)
    else if depth > 0 && i + 1 < n && s.[i] = '*' && s.[i + 1] = ')' then
      (Buffer.add_string b "  "; go (i + 2) (depth - 1) false)
    else if depth > 0 then (Buffer.add_char b ' '; go (i + 1) depth false)
    else if s.[i] = '"' then (Buffer.add_char b ' '; go (i + 1) depth true)
    else (Buffer.add_char b s.[i]; go (i + 1) depth false)
  in
  go 0 0 false;
  Buffer.contents b

let has_word (code : string) (w : string) : bool =
  let is_id (c : char) : bool =
    c = '_' || c = '\'' || c = '.' || (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z')
    || (c >= '0' && c <= '9')
  in
  let n = String.length code and k = String.length w in
  let rec at (i : int) : bool =
    i + k <= n
    && ((String.sub code i k = w
         && (i = 0 || not (is_id code.[i - 1]))
         && (i + k = n || not (is_id code.[i + k])))
        || at (i + 1))
  in
  at 0

let test_style () =
  let code = code_of "../student/dp.ml" in
  List.iter
    (fun (w : string) -> (check bool) ("dp.ml does not use " ^ w) false (has_word code w))
    [ "rec"; "Hashtbl" ]

let () =
  Printf.printf "\n----- NAME: %s   ID: %s -----\n%!" Memo.student_name Memo.student_id;
  run "Memoization"
    [ ( "by hand",
        [ test_case "A1 (8): fib" `Quick test_fib;
          test_case "A2 (12): grid_paths" `Quick test_grid_paths ] );
      ( "combinators",
        [ test_case "B3 (10): memo" `Quick test_memo;
          test_case "B4 (15): memo_rec" `Quick test_memo_rec ] );
      ( "dynamic programming",
        [ test_case "C5 (12): edit_distance" `Quick test_edit;
          test_case "C6 (12): count_change" `Quick test_change;
          test_case "C7 (11): lcs_length" `Quick test_lcs ] );
      ( "style", [ test_case "dp.ml: no rec, no Hashtbl (all of Part C)" `Quick test_style ] ) ]
