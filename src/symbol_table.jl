"""
	$(SIGNATURES)

Information for one symbol: name, latex symbol, description, group.

For printing: `\\` needs to be escaped as `\\\\` in `latex`.
"""
struct SymbolInfo
    name :: Symbol
    latex :: String
    description :: String
    group :: String
end

"""
	$(SIGNATURES)

Constructor from strings.
"""
SymbolInfo(name :: AbstractString, l :: AbstractString, 
    d :: AbstractString, g :: AbstractString) = 
    SymbolInfo(Symbol(name), l, d, g);

Base.show(io :: IO, si :: SymbolInfo) = 
    print(io, "Symbol $(si.name)");

description(si :: SymbolInfo) = si.description;
group(si :: SymbolInfo) = si.group;
latex(si :: SymbolInfo) = si.latex;

"""
	$(SIGNATURES)

Make a latex `\\newcommand` from a symbol.

# Example
```
println(io, "% ", description(si));
println(io, newcommand(si));
```
"""
newcommand(si :: SymbolInfo) = 
    "\\newcommand{\\$(si.name)}{$(latex(si))}";


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


## ----------  Adding symbols

Base.setindex!(s :: SymbolTable, si :: SymbolInfo) = s.d[si.name] = si;

"""
	$(SIGNATURES)

Add a new symbol. Overwrite existing if `replaceExisting == true`.
"""
function add_symbol!(s :: SymbolTable, si :: SymbolInfo;
    replaceExisting :: Bool = false)

    if !replaceExisting
        @assert !has_symbol(s, si.name)  "$name already exists"
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

Return description of a symbol.
"""
description(s :: SymbolTable, name :: Symbol) =
    description(s[name]);

"""
	$(SIGNATURES)

Latex symbol for a symbol.
"""
latex(s :: SymbolTable, name :: Symbol) =
    latex(s[name]);


"""
	$(SIGNATURES)

Group for a symbol.
"""
group(s :: SymbolTable, name :: Symbol) =
    group(s[name]);


## -------------  Preamble file


"""
	$(SIGNATURES)

Write a set of symbols to a preamble. The idea is that this defines notation in a paper to be consistent with notation in program generated tables and figures.
"""
function write_preamble(io :: IO, s :: SymbolTable)
    if !isempty(s)
        for (name, si) ∈ s.d
            println(io, "% ", group(si), ": ", description(si));
            println(io, newcommand(si));
        end
    end
    return nothing
end


# -------------