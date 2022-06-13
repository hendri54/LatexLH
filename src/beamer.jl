# Writing beamer slides

"""
	$(SIGNATURES)

Escape latex string, including `_`.

test this +++++
must ignore already escaped ones
"""
function escape_string(s :: AbstractString)
    return replace(s, "_" => "\\_")
end


"""
	$(SIGNATURES)

Write header for a Beamer slide file. Lines up to "begin{document}".

# Arguments
- useBookTabs (optional): Includes `booktabs` for tables.
- lineV (optional): additional lines to write to preamble, such as `usepackage` or `input` lines.
"""
function write_beamer_header(io :: IO; useBookTabs :: Bool = true,
    lineV = nothing)

    write_lines(io, [
        "\\documentclass[english]{beamer}",
        "\\usepackage[T1]{fontenc}",
        "\\usepackage{graphicx}",
        "\\usepackage{adjustbox}",  # used to size tables
        "\\usepackage{verbatim}"  # for including plain text files
    ]);

    if useBookTabs
        write_lines(io, "\\usepackage{booktabs}");
    end

    write_lines(io, lineV);

    write_lines(io, [
        "\\makeatletter",
        "\\newcommand\\makebeamertitle{\\frame{\\maketitle}}%",
        "\\makeatother",
        "\\begin{document}"
    ]);
end



write_lines(io :: IO, x :: Nothing) = nothing;
write_lines(io :: IO, x :: AbstractString) = println(io, x);

"""
	$(SIGNATURES)

Write lines to latex file. Strings must be properly escaped.
"""
function write_lines(io :: IO, xV)
    for x in xV
        println(io, x);
    end
end

"""
	$(SIGNATURES)

Write footer for a Beamer slide file.
"""
function write_beamer_footer(io :: IO)
    write_lines(io, "\\end{document}")
end


"""
	$(SIGNATURES)

Typeset a file with `pdflatex`.
"""
function typeset_file(fPath)
    @assert isfile(fPath)  "Not found: $fPath";
    fExt = last(splitext(fPath));
    @assert fExt == ".tex"  "Invalid extension: $fPath";
    fDir, _ = splitdir(fPath);
    logFn = joinpath(fDir, "lyx_typeset.log");
    # Beware: if the process asks for user input, this could hang!
    # That's why `halt-on-error` is important.
    success = try 
        run(pipeline(`pdflatex -halt-on-error -output-directory $fDir $fPath`, 
            logFn));
        true
    catch
        @warn "Could not typeset file  $fPath"
        false
    end
    return success
end



"""
	$(SIGNATURES)

Make a file that contains a set of slides. Each slide is just a title with one figure or table. 

Input is a vector of tuples. Each contains a title and a file path for the figure or table file. Assume that tables have extension ".tex". Otherwise, assume the file is a figure.

Optionally, preprend a common base directory to each path.
"""
function write_figure_slides(io :: IO,  slideV;
    baseDir :: AbstractString = "")
    for slide in slideV
        figPath = joinpath(baseDir, slide[2]);
        write_figure_slide(io, slide[1], figPath);
    end
end

is_table_path(fPath) = splitext(fPath)[2] == ".tex";
is_figure_path(fPath) = splitext(fPath)[2] == ".pdf";
is_text_path(fPath) = splitext(fPath)[2] == ".txt";


"""
	$(SIGNATURES)

Write lines for a slide that contains one figure or table to `io`.

File extension determines whether a figure or table is written.
"""
function write_figure_slide(io :: IO, title, figPath)
    if is_table_path(figPath)
        lineV = table_slide(title, figPath);
    elseif is_text_path(figPath)
        lineV = text_slide(title, figPath);
    elseif is_figure_path(figPath)
        lineV = figure_slide(title, figPath);
    else
        _, fExt = splitext(figPath);
        @warn "File extension not recognized: $fExt"
    end 
    for line ∈ lineV
        println(io, line);
    end
end

"""
	$(SIGNATURES)

Latex lines for slide with a single figure.
"""
function figure_slide(title, fPath)
    v = Vector{String}();
    push!(v, begin_frame(title));
    for line ∈ include_figure(fPath)
        push!(v, line);
    end
    push!(v, end_frame());
    return v
end

function begin_frame(title)
    return "\\begin{frame}{$(escape_string(title))}";
end

function end_frame()
    return "\\end{frame}"
end

function include_figure(fPath)
    return [
        "\\begin{center}",
        "\\includegraphics[width=0.95\\textwidth]{$fPath}",
        "\\end{center}"
    ]    
end

## ---------  Table slides

# Using `include` can generate write errors.
function table_slide(title, fPath)
    return [
        begin_frame(title),
        "\\begin{table}[h]",
        "\\centering",
        "\\begin{adjustbox}{width=1\\textwidth}",
        "\\input{$fPath}",
        "\\end{adjustbox}",
        "\\end{table}",
        end_frame()
    ]    
end


## ---------  Verbatim text

function text_slide(title, fPath)
    return [
        begin_frame(title),
        # "\\centering",
        # "\\begin{adjustbox}{width=1\\textwidth}",
        "\\verbatiminput{$fPath}",
        # "\\end{adjustbox}",
        end_frame()
    ]    
end


# ------------