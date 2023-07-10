## ----------  Pieces to write in body

"""
	$(SIGNATURES)

Given a set of directories and a list of file names, write the body of a document that contains these figures side-by-side.
"""
function figures_side_by_side(dirV, fnV; showFileNames = true)
    n = length(fnV);
    showFileNames  &&  (n = n * 2);
    sV = Vector{String}(undef, n);

    iRow = 0;
    for fn in fnV
        if showFileNames
            iRow += 1;
            sV[iRow] = latex_line(fn);
        end
        iRow += 1;
        sV[iRow] = latex_figures(dirV, fn);
    end
    return sV
end


"""
	$(SIGNATURES)

Write a latex line, replacing characters that do not typeset.
"""
function latex_line(lineIn)
    replace(lineIn, '_' => '-', '[' => '(', ']' => ')');
end


"""
	$(SIGNATURES)

Input command for a table.
"""
function latex_table(fPath)
    return "\\input{$fPath}"
end

"""
	$(SIGNATURES)

Latex command for a section or subsection. 

# Arguments:
- `hLevel`: Heading level >= 1.
"""
function latex_section(hLevel :: Integer, hText :: AbstractString)
    @argcheck hLevel >= 1;
    subStr = repeat("sub", hLevel - 1);
    return "\\$(subStr)section{$hText}"
end

"""
	$(SIGNATURES)

Latex command for multiple figures in directories `dirV` with file name `fn`. Separated by `joinStr`.
"""
function latex_figures(dirV, fn; joinStr = " ");
    n = length(dirV);
    wFrac = round(Int, 100/n);
    s = join([latex_figure(joinpath(d, fn); w = wFrac)  for d in dirV], joinStr);
    return s
end

"""
	$(SIGNATURES)

Latex command for a figure with optional width or height (given as Integer pct of textwidth or textheight).
"""
function latex_figure(figPath; w = nothing, h = nothing)
    widthStr = latex_width(w);
    heightStr = latex_height(h);
    s = "\\includegraphics[$widthStr$heightStr]{$figPath}";
end


function latex_width(widthFrac :: Integer; widthUnit = "textwidth")
    @argcheck 10 < widthFrac <= 100;
    widthStr = round(widthFrac / 100; digits = 2);
    s = "width=$widthStr\\$widthUnit";
end

latex_width(::Nothing; kwargs...) = "";

function latex_height(heightFrac :: Integer; heightUnit = "textheight")
    @argcheck 10 < heightFrac <= 100;
    heightStr = round(heightFrac / 100; digits = 2);
    s = "height=$heightStr\\$heightUnit";
end

latex_height(::Nothing; kwargs...) = "";


# ------------