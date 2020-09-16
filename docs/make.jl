Pkg.activate("./docs");

using Documenter, FilesLH, LatexLH

makedocs(
    modules = [LatexLH],
    format = Documenter.HTML(; prettyurls = get(ENV, "CI", nothing) == "true"),
    authors = "hendri54",
    sitename = "LatexLH.jl",
    pages = Any["index.md"]
    # strict = true,
    # clean = true,
    # checkdocs = :exports,
)

pkgDir = rstrip(normpath(@__DIR__, ".."), '/');
@assert endswith(pkgDir, "LatexLH")
deploy_docs(pkgDir);

Pkg.activate(".");


# deploydocs(
#     repo = "github.com/hendri54/LatexLH.jl.git",
#     push_preview = true
# )
