module LatexLH

using ArgCheck, DelimitedFiles
using DocStringExtensions

# Beamer
export write_beamer_header, write_beamer_footer, typeset_file
export write_figure_slide, figure_slide, table_slide;

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

# Writing tex files and their pieces
export write_doc, doc_header, doc_footer;
export figure_comparison;
export latex_table, latex_section, latex_figures, latex_figure, latex_line;
export figures_side_by_side;

# Testing
export test_dir;

test_dir() = normpath(joinpath(@__DIR__, "..", "test", "test_files"));

include("pieces.jl");
include("write_doc.jl");
include("table.jl");
include("parameter_table.jl");
include("symbol_info.jl");
include("symbol_table.jl");
include("beamer.jl");

end # module
