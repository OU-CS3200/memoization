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


(** 5. (12 pts) Edit distance (Levenshtein): the fewest single-character
    insertions, deletions and substitutions that turn [a] into [b].
    "kitten" -> "sitting" is 3.

    [edit_step a b self (i, j)] is the edit distance between the suffixes
    of [a] starting at [i] and of [b] starting at [j]. When one suffix is
    empty, the answer is the length of the other. Otherwise compare
    [a.[i]] with [b.[j]], and take the best of the three edits (or of
    no edit at all, when the characters are equal). *)
let edit_step (a : string) (b : string) (self : int * int -> int) ((i, j) : int * int) : int =
  let la = String.length a in (*length of string a*)
  let lb = String.length b in (*length of string b*)
  if i >= la then lb - j (*a is used, add b*)
  else if j >= lb then la - i (*b is used up so delete the rest of a*)
  else if a.[i] = b.[j] then self (i + 1, j + 1) (*letters match *)
  else 
    let delete = self (i + 1, j ) in (*delete a's letter*)
    let inset = self (i, j + 1 ) in (* add b's letter*)
    let replace = self (i + 1, j + 1) in (*swap the letter*)
    1 + min delete (min inset replace) (*pick the cheapest option*)

let edit_distance (a : string) (b : string) : int = Memo.memo_rec (edit_step a b) (0, 0)

(** 6. (12 pts) Counting change: in how many ways can [amount] cents be
    made from coins of the given denominations, using as many of each as
    you like? Order does not matter: 1+2+2 and 2+1+2 are one way.
    With coins [|1; 2; 5|], 5 cents can be made 4 ways.

    [change_step coins self (i, amount)] counts the ways using only
    [coins.(i)], [coins.(i+1)], ... There is exactly one way to make 0
    (use nothing). Either use coin [i] at least once, or never use it. *)
let change_step (coins : int array) (self : int * int -> int) ((i, amount) : int * int) : int =
  if amount = 0 then 1 (*nothing to use only one way*)
  else if amount < 0 then 0 (*too far doesn't work*)
  else if i >= Array.length coins then 0 (*no coins = no ways*)
  else
    let use_it = self (i, amount - coins.(i)) in (* use coin i once, and keep it the same*)
    let skip_it = self (i + 1, amount) in (*move i to next coin*)
    use_it + skip_it (*ways with it plus without*)

let count_change (coins : int array) (amount : int) : int =
  Memo.memo_rec (change_step coins) (0, amount)

(** 7. (11 pts) Longest common subsequence: the length of the longest
    sequence of characters that appears, in order but not necessarily
    next to each other, in both [a] and [b].
    "ABCBDAB" and "BDCABA" have one of length 4 ("BCBA").

    [lcs_step a b self (i, j)]: the same, for the suffixes starting at
    [i] and [j]. *)
let lcs_step (a : string) (b : string) (self : int * int -> int) ((i, j) : int * int) : int =
  let la = String.length a in (*length a *)
  let lb = String.length b in (* length b*)
  if i >= la || j >= lb then 0 (*nothing in common *)
  else if a.[i] = b.[j] then 1 + self (i + 1, j + 1) (*letters match so count 1 and forward*)
  else 
    let skip_a = self (i + 1, j) in (*throws away a's letter*)
    let skip_b = self (i, j + 1) in max skip_a skip_b (* throw away b lettter, then no match so keep the better option*)

let lcs_length (a : string) (b : string) : int = Memo.memo_rec (lcs_step a b) (0, 0)
