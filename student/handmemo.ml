(************************************************************************
   Memoization, Part A — Cache it by hand (20 pts)

   Fill in your name and Ohio ID in memo.ml, not here.

   Memoization: remember the result of every call, and answer a repeated
   call from memory instead of computing it again. Here you do it by hand
   with a hash table (textbook 8.5; Hashtbl is in Lecture 11):

     Hashtbl.create 16              a new, empty table
     Hashtbl.find_opt tbl key       Some value, or None
     Hashtbl.replace tbl key value  remember value under key
 ************************************************************************)

open Util

(** Given: the definition, straight from mathematics. It makes two calls
    for every call, so [fib_naive 40] makes about 330 million of them. *)
let rec fib_naive (n : int) : int =
  if n < 2 then n else fib_naive (n - 1) + fib_naive (n - 2)

(** 1. (8 pts) [fib n]: the same numbers as [fib_naive], for 0 <= n <= 90,
    but memoized with a [Hashtbl] so that each [fib k] is computed once.
    [fib 90] must come back at once. (fib 90 still fits in an OCaml int.)

    Where does the table live? If you create it inside [fib], every
    outer call starts with an empty table; that is fine, as long as the
    recursion inside one call shares it. *)
let fib (n : int) : int =
  todo n

(** 2. (12 pts) [grid_paths g]: the number of paths from the top-left
    cell [g.(0).(0)] to the bottom-right cell that move only right or
    down and pass only through open cells ([true] = open, [false] =
    blocked). If either corner is blocked, there are no paths.

    An open 3x3 grid has 6 paths. An open 18x18 grid has 2,333,606,220,
    so counting them one at a time is hopeless: the number of paths from
    a cell depends only on the cell, so memoize on (row, column).

    The grid is never empty, and every row has the same length. *)
let grid_paths (g : bool array array) : int =
  todo g
