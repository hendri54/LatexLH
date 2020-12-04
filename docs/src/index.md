# LatexLH

```@meta
CurrentModule = LatexLH
```

## Writing Beamer Slides

```@docs
write_figure_slides
figure_slide
write_beamer_header
write_beamer_footer
typeset_file
```

## Writing Latex Tables

Latex tables are written row by row. First, initialize an empty `Table` object. Then add rows one by one using `add_rows!`. Any horizontal lines must be added by hand, except for `\toprule` and `\bottomrule` (which require the Latex package `booktabs`).

```@docs
CellColor
Cell
Table
color_string
cell_string
nrows
add_row!
make_row
write_table
```

## SymbolTables

Intended for looking up names and descriptions of model symbols in code. E.g., for correctly naming objects in tables. Also for writing preamble files with model notation.

A `SymbolTable` can be constructed from a `String` array or from a delimited file.

```@docs
SymbolInfo
SymbolTable
add_symbol!
has_symbol
description
latex
group
newcommand
write_preamble
write_notation_tex
```

-----------
