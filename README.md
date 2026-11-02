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

2. **(5 pts) Why `memo` is not enough.** Try `Memo.memo Handmemo.fib_naive` on 35, twice. Paste
   what you ran and the times. Why is the first call no faster than `fib_naive`, and what does
   `memo_rec` do differently? Point at the line of your `memo_rec` that makes the difference.

3. **(5 pts) Choosing the key.** Part C names subproblems by indices `(i, j)` instead of by the
   suffix strings themselves. Write a version of `edit_step` whose key is the pair of suffixes
   (`string * string`), and compare its time on the 60- and 80-letter strings in the tests with
   yours. What makes the difference?

4. **(4 pts) When memoization is wrong.** Give a function for which `memo` changes the
   *behaviour* of a program, not just its speed. Show a `utop` session where the memoized and
   unmemoized versions give different results, and say what property a function needs before it
   is safe to memoize.

## Collaboration and AI

As in the syllabus: talk about the problems, not your code, and only after you have started;
list who you talked to here. Generative AI tools are allowed. If you use one, say here which one,
what for, and which parts of your submission it shaped. Every answer in Part D has to be about
**your own** code and **your own** measurements.

## README (collaboration / AI use)

*Name, Ohio ID, who you talked to, and what AI tools you used for what.*
