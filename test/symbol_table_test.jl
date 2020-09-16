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

        for j = 1 : 5
            sStr = "s$j";
            sName = Symbol(sStr);
            si = SymbolInfo(sName, "\\alpha_$j", "Description $sStr", "group$j");
            add_symbol!(s, si);
            @test has_symbol(s, sName)
            s1 = s[sName];
            @test s1.name == sName
            @test length(s) == j

            @test description(s, sName) == description(si)
        end

        println(s);
        gl = LatexLH.group_list(s);
        @test length(gl) == 5

        fPath = joinpath(testDir, "preamble.tex");
        open(fPath, "w") do io
            write_preamble(io, s);
        end

        fPath = joinpath(testDir, "notation_tex.tex");
        open(fPath, "w") do io
            write_notation_tex(io, s);
        end

        s2 = SymbolTable(["capShare"  "\\alpha"  "Capital share"  "Technology";
            "tfp"  "A"  "Total factor productivity"  "Technology"]);
        @test length(s2) == 2
        @test has_symbol(s2, :capShare)
    end
end

@testset "SymbolTable" begin
    symbol_info_test();
    symbol_table_test();
end

# -----------