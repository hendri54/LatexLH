"""
	$(SIGNATURES)

Write a complete tex document to a file.

# Arguments:
- `fPath`: File path.
- `docBodyV`: Vector of String with document body.
- `preambleCommands`: Vector of String with preamble commands.
- `inputFiles`: Vector of String with files to include in preamble.
"""
function write_doc(fPath :: AbstractString, docBodyV :: AbstractVector{String};
        preambleCommands = nothing, inputFiles = nothing)

    sStart = doc_start();
    sBegin = begin_doc(; inputFiles, preambleCommands);
    sFoot = doc_footer();
    open(fPath, "w") do io
        for line ∈ vcat(sStart, sBegin, docBodyV, sFoot)
            println(io, line, "\n");
        end
    end
    return fPath
end


function doc_start()
    return vcat(doc_header(), use_packages());
end

function doc_header()
    s = ["\\documentclass[english]{article}",
        "\\setlength{\\parskip}{\\smallskipamount}",
        "\\setlength{\\parindent}{0pt}"
    ];
    return s
end

function use_packages()
    s = [
        "\\usepackage[T1]{fontenc}",
        "\\usepackage[latin9]{inputenc}",
        "\\usepackage{geometry}",
        "\\geometry{verbose,tmargin=1in,bmargin=1cm,lmargin=2cm,rmargin=2cm}",
        "\\usepackage{graphicx}",
        "\\usepackage{booktabs}"
        ];
    return s
end    


"""
	$(SIGNATURES)

Write the begin document part. Body comes right after this.

# Arguments:
- `includeFiles`: list of files to be included with `input`.
- `preambleCommands`: String Vector with `newcommand`s.
"""
function begin_doc(; inputFiles = nothing, preambleCommands = nothing)
    sStart = ["\\makeatletter"];
    sPreamble = Vector{String}();
    if !isnothing(inputFiles)
        for fPath in string_vector(inputFiles)
            push!(sPreamble, "\\input{$fPath}");
        end
    end
    if !isnothing(preambleCommands)
        append!(sPreamble, preambleCommands);
    end
    sEnd = [
        "\\makeatother",
        "\\begin{document}"
        ];
    s = vcat(sStart, sPreamble, sEnd);
    return s
end

doc_footer() = ["\\end{document}"];

string_vector(s :: AbstractString) = [s];
string_vector(v :: AbstractVector{T}) where T = v;


## -------------  Doc with side-by-side figures in two directories

"""
	$(SIGNATURES)

Create a tex / pdf document that compares all figures that are common to the provided directories.
"""
function figure_comparison(dirV :: AbstractVector{String}, 
        fPath :: AbstractString; 
        fileExtensions = [".pdf", ".eps"], typeset = true)

    fnV = common_files(dirV; fileExtensions);
    docBodyV = figures_side_by_side(dirV, fnV);
    write_doc(fPath, docBodyV);
    typeset  &&  typeset_file(fPath);
end


"""
	$(SIGNATURES)

Find all common files in a set of directories `dirV`. Optionally restrict to given file extensions (provided as ".ext").

move to FilesLH +++++
"""
function common_files(dirV; fileExtensions = nothing)
    d1 = readdir(first(dirV));
    if !isnothing(fileExtensions)
        filter!(fn -> last(splitext(fn)) ∈ fileExtensions, d1);
    end

    for (j, d) in enumerate(dirV)
        if j > 1
            d2 = readdir(d);
            d1 = intersect(d1, d2);
        end
    end
    return d1
end


## --------------  Testing

function make_test_doc(; fPath = test_doc_path())
    write_doc(fPath, test_doc_body(); 
        preambleCommands = test_preamble_commands(),
        inputFiles = joinpath(test_dir(), "test_doc_preamble.tex"));
    return fPath
end

test_doc_path() = joinpath(test_dir(), "testdoc.tex");

function test_preamble_commands()
    return [
        "\\newcommand{\\testOne}{1}",
        "\\newcommand{\\testTwo}{2}",
        "\\usepackage{siunitx}"
    ]
end

function test_doc_body()
    testDir = test_dir();
    sFigV = figures_side_by_side([testDir, testDir], 
        ["afqtMeanByQual.pdf", "fracGradByQual.pdf"]);
    s = [
        latex_section(1, "Level 1 header"),
        "This is the document body.",
        "Testing preamble constants: \$\\testOne\$ and \$\\testTwo\$.",
        "Testing included file: \$\\testDocOne\$ and \$\\testDocTwo\$.",
        latex_section(2, "Included graphics"),
        latex_figure(joinpath(testDir, "afqtMeanByQual.pdf"); w = 75),
        sFigV...,
        latex_section(2, "Included tables"),
        latex_table(joinpath(testDir, "TableTest.tex"))
        ];
    return s
end

# ---------------