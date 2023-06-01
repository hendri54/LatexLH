## ----------  SymbolTable

struct SymbolTable
    d :: Dict{Symbol, SymbolInfo}
end

Base.show(io :: IO, s :: SymbolTable) =
    Base.print(io, "SymbolTable of length ", length(s));

Base.isempty(s :: SymbolTable) = Base.isempty(s.d);
Base.length(s :: SymbolTable) = Base.length(s.d);

"""
	$(SIGNATURES)

Erase the SymbolTable in place.
test this +++
"""
function erase!(s :: SymbolTable)
    for k in keys(s.d)
        delete!(s.d, k);
    end
end


"""
	$(SIGNATURES)

Constructor for empty SymbolTable.
"""
SymbolTable() = SymbolTable(Dict{Symbol, SymbolInfo}());

"""
	$(SIGNATURES)

Constructor from String array with names, latex symbols, descriptions, groups.

# Example
```
SymbolTable(["capShare"  "\\alpha"  "Capital share"  "Technology";
    "tfp"  "A"  "Total factor productivity"  "Technology"]);
```
"""
function SymbolTable(m :: Matrix{String})
    @assert size(m, 2) == 4  "Invalid no of columns: $(size(m))"
    s = SymbolTable();
    for j = 1 : size(m, 1)
        add_symbol!(s, SymbolInfo(m[j,:]...));
    end
    return s
end


"""
	$(SIGNATURES)

Read a file that defines notation. Comma delimited.

Format:
- header row: Group | Name | Latex | Description
- group rows: only the group entry is filled
- other rows: only the other entries are filled

# Example
```
Group,Name,Latex,Description
G1,,,
,nameG1,lG1,DescrG1
G2,,,
,nameG2,lG2,DescrG2
```
"""
function SymbolTable(fPath :: AbstractString; delimChar = ',')
    s = SymbolTable();
    load_from_csv!(s, fPath; delimChar = delimChar);
    return s
end


"""
	$(SIGNATURES)

Load a comma delimited file into an existing SymbolTable.
Does not erase existing content.
"""
function load_from_csv!(s :: SymbolTable, fPath :: AbstractString; delimChar = ',')
    m = readdlm(fPath, delimChar, String, skipstart = 1);
    grp = "";
    for j = 1 : size(m, 1)
        if !isempty(m[j,1])
            grp = m[j,1];
        else
            add_symbol!(s, SymbolInfo(m[j,2], m[j,3], m[j,4], grp));
        end
    end
    return nothing
end


## ----------  Adding symbols

Base.setindex!(s :: SymbolTable, si :: SymbolInfo) = 
    s.d[si.name] = si;

"""
	$(SIGNATURES)

Add a new symbol. Overwrite existing if `replaceExisting == true`.
"""
function add_symbol!(s :: SymbolTable, si :: SymbolInfo;
    replaceExisting :: Bool = false)

    if !replaceExisting
        @assert !has_symbol(s, si.name)  "$(si.name) already exists"
    end
    s.d[si.name] = si;
    return nothing
end

"""
	$(SIGNATURES)

Does symbol exist?
"""
has_symbol(s :: SymbolTable, name) = haskey(s.d, name);


# ---------------  Retrieving symbols

"""
	$(SIGNATURES)

Retrieve a symbol by name. Returns a `SymbolInfo`.

# Example
```
s[:alpha]
```
"""
function Base.getindex(s :: SymbolTable, name :: Symbol)
    @assert has_symbol(s, name)  "Not found: $name"
    return s.d[name]
end

"""
	$(SIGNATURES)

Return description of a symbol. If not found, return `defaultValue`.
"""
function description(s :: SymbolTable, name :: Symbol; defaultValue = string(name))
    if has_symbol(s, name)
        return description(s[name]);
    else
        return defaultValue;
    end
end

"""
	$(SIGNATURES)

Latex symbol for a symbol. If not found, return `defaultValue`.
"""
function latex(s :: SymbolTable, name :: Symbol; defaultValue = string(name))
    if has_symbol(s, name)
        return latex(s[name]);
    else
        return defaultValue
    end
end


"""
	$(SIGNATURES)

Group for a symbol.
"""
group(s :: SymbolTable, name :: Symbol) =
    group(s[name]);


function group_list(s :: SymbolTable)
    n = length(s);
    gl = Vector{String}();
    if n > 0
        for (name, si) ∈ s.d
            if !(group(si) ∈ gl)
                push!(gl, group(si));
            end
        end
    end
    return gl
end


## -------------  Preamble file


"""
	$(SIGNATURES)

Write a set of symbols to a preamble. The idea is that this defines notation in a paper to be consistent with notation in program generated tables and figures.
"""
function write_preamble(io :: IO, s :: SymbolTable)
    if !isempty(s)
        groupV = sort(group_list(s));
        for group ∈ groupV
            write_preamble_one_group(io, s, group);
        end
    end
    return nothing
end

function write_preamble_one_group(io :: IO, s :: SymbolTable, grp)
    println(io, "% =====  ", grp, ":");
    for (name, si) ∈ s.d
        if group(si) == grp
            println(io, "% ", description(si));
            println(io, newcommand(si));
        end
    end
    println(io, "% ----------");
    return nothing
end


## -----------  Latex doc with notation, by group

"""
	$(SIGNATURES)

Write a tex file with notation, by group. The output looks like:

    Endowments
    * \$\\alpha\$: some endowment
    * \$\\beta\$: another endowment
    Preferences
    * [...]

This writes a document section. It is meant to be included in the Notation section of an existing document.

In `Lyx`: Insert | File | Child document. Use the `input` format (not `include`).
"""
function write_notation_tex(io :: IO, s :: SymbolTable)
    # println(io, "\\Section{Notation}")
    groupV = sort(group_list(s));
    for group ∈ groupV
        write_notation_tex_one_group(io, s, group);
    end
end

function write_notation_tex_one_group(io :: IO, s :: SymbolTable, grp :: String)
    println(io,  grp, "\n");
    # println(io,  "\\begin{itemize}");
    println(io, "\\begin{tabular}{lll}")
    println(io, "\\hline");
    # println(io, "Symbol & Abbrev. & Description", "\\tabularnewline");
    # println(io, "\\hline");

    listV = Vector{String}();
    for (name, si) ∈ s.d
        if group(si) == grp
            push!(listV, notation_line(si));
        end
    end
    listV = sort(listV);
    for line ∈ listV
        println(io, line);
    end
    # println(io, "\\end{itemize}");
    println(io, "\\hline");
    println(io, "\\end{tabular}")
    println(io, " ")
end

# Line in latex file of the form
# `* \\alpha:  Capital share (capShare)`
# where `capShare` is the `newcommand` defined for the symbol.
function notation_line(si :: SymbolInfo)
    return "\$" * latex(si) * "\$ & $(si.name) & " * description(si) *
        "\\tabularnewline";
        # println(io, "\\item \$", latex(si), "\$:  ", description(si), 
        # "  ($(si.name))");
end


## --------  For testing

function test_symbol_table(nGroups, nSyms)
    s = SymbolTable();
    for ig = nGroups : -1 : 1
        gName = "$group$ig";
        # Reverse, so that sorting can be checked in output files.
        for j = nSyms : -1 : 1
            sStr = "s_$(ig)_$j";
            sName = Symbol(sStr);
            si = SymbolInfo(sName, "\\alpha_{$ig,$j}", "Description $sStr in $gName", gName);
            add_symbol!(s, si);
        end
    end
    return s
end


# -------------