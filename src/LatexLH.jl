module LatexLH

using DelimitedFiles
using DocStringExtensions

export write_figure_slide, figure_slide
# Tables
export CellColor, Cell
export add_row!, color_string, cell_string, nrows, write_table
# Parameter table
export ParameterTable
export add_row!
# SymbolTable
export SymbolTable, SymbolInfo
export add_symbol!, has_symbol, newcommand, description, group, latex, load_from_csv!, erase!
export write_preamble, write_notation_tex

include("table.jl");
include("parameter_table.jl");
include("symbol_info.jl");
include("symbol_table.jl");
include("beamer.jl")
# include("latex/symbol_table.jl")

end # module
