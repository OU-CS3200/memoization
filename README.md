# Memoization

CS 3200, Fall 2026 · textbook §8.5 (Memoization) and Lecture 11 (`Hashtbl`).

A memoized function remembers every answer it has computed, and answers a repeated question from
memory. For the right functions this turns hours into milliseconds: `fib 90` by the definition
makes about 9 × 10¹⁸ calls; memoized, its body runs 91 times. In this assignment you cache by hand, then
write the cache once as a higher-order function, then use it to solve three classic
dynamic-programming problems, and finally measure what it bought you.

## Getting your copy

Click **Use this template** (top right), set the owner to **OU-CS3200**, and set the visibility to
**Private**. Clone *your* repository, not this one. When you are done, push, download a zip of
your repository (green **Code** button → *Download ZIP*) and submit that zip on Canvas. Also tag
the commit you are submitting:

```
git tag memo && git push origin memo
```

## Setting up

```
opam install dune alcotest
eval $(opam env)
dune build
```

The handout builds cleanly, and most tests fail with `Todo`. That is expected.

## What to do

All of your code goes in `student/`. Each file says what it wants at the top.

| Part | File | Points | What |
| :--- | :--- | ---: | :--- |
| A | `handmemo.ml` | 20 | `fib` (8) and `grid_paths` (12), memoized by hand with a `Hashtbl` |
| B | `memo.ml` | 25 | `memo` (10) and `memo_rec` (15): the cache, written once |
| C | `dp.ml` | 35 | three step functions: edit distance (12), counting change (12), longest common subsequence (11). **No `rec`, no `Hashtbl`.** |
| D | `README.md` | 20 | The questions below, answered from your own measurements |

Part C is written in **open-recursion style**: each step function takes `self`, the function to
call for smaller subproblems, and the given wrappers tie the knot with your `memo_rec`. The same
step, tied with `Memo.fix` instead, runs with no cache at all, which is what Part D measures. The
style check reads `dp.ml` and is all-or-nothing for Part C.

Run the tests with `dune test`. The speed tests give each computation 3 seconds; a version
without a working cache fails them with "still running after 3 seconds" instead of hanging. The
grader also runs hidden tests on other inputs.

```
dune exec test/test_memo.exe -- test combinators     # one group
dune exec bin/main.exe -- fib 30                     # no cache vs memo_rec: calls and time
dune exec bin/main.exe -- edit kitten sitting
dune exec bin/main.exe -- change 300 1 5 10 25
dune exec bin/main.exe -- lcs ABCBDAB BDCABA
dune exec bin/main.exe -- grid 18
```

## Part D — answer here (20 pts)

Write your answers in this file, under this heading, replacing the prompts.

1. **(6 pts) What the cache buys.** Use `bin/main.exe` to fill in a table for `fib` at
   n = 20, 25, 30, 35 and for `edit` on two pairs of strings of growing length: the number of
   calls and the time, with no cache and with `memo_rec`. How does each column grow as the input
   grows? Explain the `memo_rec` call count for `fib n` exactly.

   Input    Calls(no cache)   Time     Calls(memo_rec)   Time
   fib 20   21,891            0.0002s     21             0.0000s
   fib 25   242,785           0.0012s     26             0.0000s
   fib 30   2,692,527         0.0114s     31             0.0000s
   fib 35   29,860,703        0.1011s     36             0.0000s
   edit kitten /      2,763            0.0000s      56             0.0000s
   sitting
   edit intention /   367,039          0.0033s      90             0.0000s
   execution
   edit hippopotamus /  skipped(too slow)   n/a     153            0.0000s
   thermometers

   With no cache, the calls multiply by about 11 each n goes up 5. The edit distance grows the same as the strings getting longer. With memo the caalls grow slow and constant steadily, by exactly 1 for each +1 in the fibs n number. Fib n makes n + 1 calls. The recursive call goes through the cache so the main body only runs once. The only argument that are ever asked for are 0, 1, to n. Which is why n+1 numbers. 

2. **(5 pts) Why `memo` is not enough.** Try `Memo.memo Handmemo.fib_naive` on 35, twice. Paste
   what you ran and the times. Why is the first call no faster than `fib_naive`, and what does
   `memo_rec` do differently? Point at the line of your `memo_rec` that makes the difference.

   let time f = let t = Unix.gettimeofday () in let r = f () in (r, Unix.gettimeofday () -. t);;
   let slow = Memo.memo Handmemo.fib_naive;;
   time (fun () -> slow 35);;    9227465 in 0.2696 s 
   time (fun () -> slow 35);;    9227465 in 0.00000095 s 

   Memo only keeps the answer to the outter call. fib_naive calls itself by name, so the inner calls go around the cache and redo all the work. The cache only helps for the second call when the same input.
   Memo_rec gives the step the cached self to use for the recursive calls, so inner calls check the cache first. 

   let result = step self x in (*makes the difference)

   The 0.2696 is a bit slower because utop runs slower the noraml program. That is expected and doesn't change the reasoning.

3. **(5 pts) Choosing the key.** Part C names subproblems by indices `(i, j)` instead of by the
   suffix strings themselves. Write a version of `edit_step` whose key is the pair of suffixes
   (`string * string`), and compare its time on the 60- and 80-letter strings in the tests with
   yours. What makes the difference?

   Strings              Index key   String key
   60 and 55 letters    0.00094s    0.00164s
   80 and 70 letters    0.00166s    0.00592s

   Both return close to the same answers. The string-key version is about 1.7 times slow on the 60 to 55 pair and about 3.6 times slower on the 80 to 70 pair, so the gap grows as the string gets larger. The index keys, each look at the hashes and compares two small integers, which cost the same no matter what the string lengths are. String keys, every step builds two new different substrings, and every look of them has to hash and compare. Each step costs more as the string length grows.



4. **(4 pts) When memoization is wrong.** Give a function for which `memo` changes the
   *behaviour* of a program, not just its speed. Show a `utop` session where the memoized and
   unmemoized versions give different results, and say what property a function needs before it is safe to memoize.

utop # let counter = ref 0;;
val counter : int ref = {contents = 0}
─( 15:12:27 )─< command 27 >──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────{ counter: 0 }─
utop # let next (_ : int) : int = counter := !counter + 1; !counter;;
val next : int -> int = <fun>
─( 15:18:44 )─< command 28 >──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────{ counter: 0 }─
utop # let memo_next = Memo.memo next;;
val memo_next : int -> int = <fun>
─( 15:18:45 )─< command 29 >──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────{ counter: 0 }─
utop # 
next 0;;                 (* unmemoized, first call *)
- : int = 1
─( 15:18:45 )─< command 30 >──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────{ counter: 0 }─
utop # next 0;;                 (* unmemoized, second call *)
- : int = 2
─( 15:18:45 )─< command 31 >──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────{ counter: 0 }─
utop # next 0;;                 (* unmemoized, third call *)
- : int = 3
─( 15:18:45 )─< command 32 >──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────{ counter: 0 }─
utop # 
counter := 0;;           (* reset the counter *)
- : unit = ()
─( 15:18:45 )─< command 33 >──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────{ counter: 0 }─
utop # memo_next 0;;            (* memoized, first call *)
- : int = 1
─( 15:18:45 )─< command 34 >──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────{ counter: 0 }─
utop # memo_next 0;;            (* memoized, second call *)
- : int = 1
─( 15:18:45 )─< command 35 >──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────{ counter: 0 }─
utop # memo_next 0;;            (* memoized, third call *)
- : int = 1

The memoized version gives different results and not just faster results. Memo runs next only one time for the input 0, saves the answer 1. It then never runs it again so the counter will not go up. A function can only me memoized if it is pure. Meaning the result depends only on the input. Also it has to have no side effects such like changing the counter or reading input or the use of random numbers. The replacing a repeat call with the saved answer is the same as redoing the function.

## Collaboration and AI

As in the syllabus: talk about the problems, not your code, and only after you have started;
list who you talked to here. Generative AI tools are allowed. If you use one, say here which one,
what for, and which parts of your submission it shaped. Every answer in Part D has to be about
**your own** code and **your own** measurements.

## README (collaboration / AI use)

I didn't talk to anyone and I used claude to help me organiz, format, and inspire code. 
