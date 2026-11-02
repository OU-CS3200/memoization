(************************************************************************
   Memoization, Part B — The combinators (25 pts)

   Fill in your name and Ohio ID: *)
let student_name = "YOUR NAME"
let student_id = "YOUR OHIO ID"

(* Part A memoized two particular functions. Here you write the cache
   ONCE, as a higher-order function, and get memoization for any function
   by passing it in. Read textbook 8.5 first: it builds exactly these.

   Your memo and memo_rec may use [Hashtbl] (with OCaml's structural
   hashing, keys can be ints, strings, tuples, ...). The tests count how
   many times the function body runs, so a cache that the recursion goes
   around, instead of through, will show.
 ************************************************************************)

open Util

(** 3. (10 pts) [memo f] behaves like [f], but calls [f] at most once per
    distinct argument: the second [memo f x] answers from the cache.

      let slow_square (x : int) : int = (* ... takes a second ... *) x * x
      let fast = memo slow_square
      fast 4   (* slow, calls slow_square *)
      fast 4   (* instant *)

    Each call [memo f] makes a new, empty cache. *)
let memo (f : 'a -> 'b) : 'a -> 'b =
  todo f

(** 4. (15 pts) [memo_rec step] is the memoized version of a recursive
    function written in "open recursion" style: [step] takes, as its
    first argument, the function to call for its recursive calls.

      let fib_step (self : int -> int) (n : int) : int =
        if n < 2 then n else self (n - 1) + self (n - 2)

      let fib = memo_rec fib_step      (* fib 90 is instant *)

    Every recursive call must go through the cache, so each argument is
    computed once in total. (Why [memo fib_naive] is NOT enough is a
    Part D question.) *)
let memo_rec (step : ('a -> 'b) -> 'a -> 'b) : 'a -> 'b =
  todo step

(* ---- Given: the same recursion with no cache, and a call counter --- *)

(** [fix step] ties the knot WITHOUT a cache: [fix fib_step] is
    [fib_naive]. Compare it with [memo_rec step] in Part D. *)
let rec fix (step : ('a -> 'b) -> 'a -> 'b) (x : 'a) : 'b = step (fix step) x

(** [counting step] is [step] with a counter: every call to the returned
    step adds one to [!calls]. [memo_rec (counting step)] then tells you
    how many times the body actually ran. *)
let counting (calls : int ref) (step : ('a -> 'b) -> 'a -> 'b) : ('a -> 'b) -> 'a -> 'b =
  fun (self : 'a -> 'b) (x : 'a) -> incr calls; step self x
