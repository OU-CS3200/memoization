(lang dune 3.1)

(name memo)

(generate_opam_files true)

(source
 (github OU-CS3200/ou-cs3200-fall-2026-memo))

(authors "Ohio University CS 3200")

(maintainers "Ohio University CS 3200")

(package
 (name memo)
 (synopsis "CS 3200 Memoization assignment")
 (description
  "Memoization assignment for CS 3200 at Ohio University: cache by hand, write the memo and memo_rec combinators, solve three dynamic-programming problems in open-recursive style, and measure what the cache buys.")
 (depends
  ocaml
  dune
  alcotest)
 (allow_empty)
 (tags
  ("ocaml" "education" "cs3200")))
