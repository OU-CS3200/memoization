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
  (* Empty table to store answers*)
  let table = Hashtbl.create 16 in
  (*shares table*)
  let rec share (i : int) : int =
    (*fib[0]=0, fib[1]= 1*)
    if i < 2 then i
    (*find already solved i, if not solve i*)
    else match Hashtbl.find_opt table i with
      | Some answer -> answer
      | None -> let result = share (i - 1) + share (i - 2) in Hashtbl.replace table i result; (*add two fibs before i, write answer in table*)
      result (*output*)
  in 
  share n (*start with given*)

(** 2. (12 pts) [grid_paths g]: the number of paths from the top-left
    cell [g.(0).(0)] to the bottom-right cell that move only right or
    down and pass only through open cells ([true] = open, [false] =
    blocked). If either corner is blocked, there are no paths.

    An open 3x3 grid has 6 paths. An open 18x18 grid has 2,333,606,220,
    so counting them one at a time is hopeless: the number of paths from
    a cell depends only on the cell, so memoize on (row, column).

    The grid is never empty, and every row has the same length. *)
let grid_paths (g : bool array array) : int =
  let rows = Array.length g in (*Get row amount*)
  let cols = Array.length g.(0) in (*amount of columns measured in first row*)
  let table = Hashtbl.create 16 in (* empty table *)
  let rec share (r : int) (c: int) : int = (*function for counting paths*)
    if r >= rows || c >= cols then 0 (*stay on grid or false*)
    else if not g.(r).(c) then 0 (*cell blocked return false no paths*)
    else if r = rows - 1 && c = cols - 1 then 1 (*reached goal state set true*)
    else match Hashtbl.find_opt table (r, c) with
      | Some answer -> answer
      | None -> let result = share (r+1) c + share r (c+1) in (*path down and right*)
        Hashtbl.replace table (r,c) result; (* answer to the table*)
        result
  in
  share 0 0 (*start a 0 0 *)