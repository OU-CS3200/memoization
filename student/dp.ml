(************************************************************************
   Memoization, Part C — Dynamic programming (35 pts)

   Each problem below is written as a STEP function in open-recursion
   style, like [fib_step] in memo.ml: [self] is the function to call for
   every smaller subproblem. The wrapper under each step (given) ties the
   knot with your [Memo.memo_rec]. Write only the steps.

   Rules for this file: no [let rec] (recursion goes through [self]) and
   no [Hashtbl] (the cache is memo_rec's job). The tests read the file and
   check; comments are skipped.

   Every subproblem is named by INDICES into the inputs, never by
   substrings or sublists: the cache key (i, j) is cheap to hash and
   compare, a substring is not. Part D asks you to measure that claim.
 ************************************************************************)

open Util

(** 5. (12 pts) Edit distance (Levenshtein): the fewest single-character
    insertions, deletions and substitutions that turn [a] into [b].
    "kitten" -> "sitting" is 3.

    [edit_step a b self (i, j)] is the edit distance between the suffixes
    of [a] starting at [i] and of [b] starting at [j]. When one suffix is
    empty, the answer is the length of the other. Otherwise compare
    [a.[i]] with [b.[j]], and take the best of the three edits (or of
    no edit at all, when the characters are equal). *)
let edit_step (a : string) (b : string) (self : int * int -> int) ((i, j) : int * int) : int =
  todo (a, b, self, i, j)

let edit_distance (a : string) (b : string) : int = Memo.memo_rec (edit_step a b) (0, 0)

(** 6. (12 pts) Counting change: in how many ways can [amount] cents be
    made from coins of the given denominations, using as many of each as
    you like? Order does not matter: 1+2+2 and 2+1+2 are one way.
    With coins [|1; 2; 5|], 5 cents can be made 4 ways.

    [change_step coins self (i, amount)] counts the ways using only
    [coins.(i)], [coins.(i+1)], ... There is exactly one way to make 0
    (use nothing). Either use coin [i] at least once, or never use it. *)
let change_step (coins : int array) (self : int * int -> int) ((i, amount) : int * int) : int =
  todo (coins, self, i, amount)

let count_change (coins : int array) (amount : int) : int =
  Memo.memo_rec (change_step coins) (0, amount)

(** 7. (11 pts) Longest common subsequence: the length of the longest
    sequence of characters that appears, in order but not necessarily
    next to each other, in both [a] and [b].
    "ABCBDAB" and "BDCABA" have one of length 4 ("BCBA").

    [lcs_step a b self (i, j)]: the same, for the suffixes starting at
    [i] and [j]. *)
let lcs_step (a : string) (b : string) (self : int * int -> int) ((i, j) : int * int) : int =
  todo (a, b, self, i, j)

let lcs_length (a : string) (b : string) : int = Memo.memo_rec (lcs_step a b) (0, 0)
