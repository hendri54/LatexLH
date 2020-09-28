using LatexLH, Test

function symbol_info_test()
    @testset "SymbolInfo" begin
        si = SymbolInfo(:capShare, "\\alpha", "Capital share", "Technology");
        println(si);
        @test description(si) == "Capital share"
        @test group(si) == "Technology"
        ncStr = newcommand(si);
        println(ncStr)
    end
end

function symbol_table_test()
    @testset "SymbolTable" begin
        s = SymbolTable();
        @test isempty(s)
        @test length(s) == 0

        nGroups = 3;
        nSyms = 4;
        s = LatexLH.test_symbol_table(nGroups, nSyms);
        @test length(s) == nGroups * nSyms

        println(s);
        gl = LatexLH.group_list(s);
        @test length(gl) == nGroups

        fPath = joinpath(testDir, "preamble.tex");
        open(fPath, "w") do io
            write_preamble(io, s);
        end

        fPath = joinpath(testDir, "notation_tex.tex");
        open(fPath, "w") do io
            write_notation_tex(io, s);
        end

        erase!(s);
        @test isempty(s)

        s2 = SymbolTable(["capShare"  "\\alpha"  "Capital share"  "Technology";
            "tfp"  "A"  "Total factor productivity"  "Technology"]);
        @test length(s2) == 2
        @test has_symbol(s2, :capShare)
    end
end

function write_st_csv()
    fPath = joinpath(testDir, "st_csv.csv");
    open(fPath, "w") do io
        for ig = 1 : 3
            println(io, "G$ig,,,");
            for j = 1 : 2
                println(io, ",n$ig$j,l$ig$j,descr$ig$j");
            end
        end
    end
    return fPath
end

function load_st_test()
    fPath = write_st_csv();
    @test isfile(fPath)
    s = SymbolTable(fPath);
    @test has_symbol(s, :n11)
    @test has_symbol(s, :n32)
    si = s[:n21];
    @test group(si) == "G2"
    @test latex(si) == "l21"
end


@testset "SymbolTable" begin
    symbol_info_test();
    symbol_table_test();
    load_st_test();
end

# -----------