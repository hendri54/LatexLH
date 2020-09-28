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

# Arguments:
- name
- latex symbol
- description
- group
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


# -----------