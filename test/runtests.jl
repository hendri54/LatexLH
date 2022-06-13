using LatexLH
using Test

mdl = LatexLH;
# testDir = joinpath(@__DIR__, "test_files");

function pieces_test()
	@testset "Pieces" begin
		s = mdl.latex_width(51);
		@test s == "width=0.51\\textwidth";
		s = mdl.latex_height(52);
		@test s == "height=0.52\\textheight";
		s = mdl.latex_figure("abc"; w = 53);
		@test s == "\\includegraphics[width=0.53\\textwidth]{abc}";
	end
end

function make_doc_test()
	@testset "Test doc" begin
		fPath = mdl.test_doc_path();
		isfile(fPath)  &&  rm(fPath);
		mdl.make_test_doc(; fPath);
		@test isfile(fPath);
		success = typeset_file(fPath);
		@test success;
	end
end

function figure_comparison_test()
	@testset "Figure comparison" begin
		dirV = fill(test_dir(), 2);
		fnV = mdl.common_files(dirV);
		@test fnV == readdir(first(dirV));

		fPath = joinpath(test_dir(), "fig_compare.tex");
		isfile(fPath)  &&  rm(fPath);
		dirV = fill(joinpath(test_dir(), "test_figures"), 2);
		figure_comparison(dirV, fPath);
		@test isfile(fPath);
	end
end

function beamer_test()
	@testset "Beamer" begin
		testDir = test_dir();
		@test isdir(testDir);

		figPath = joinpath(testDir, "afqtMeanByQual.pdf");
		lineV = figure_slide("Title", figPath);
		@test isa(lineV, Vector{String})

		fPath = joinpath(testDir, "beamer_test.tex");
		isfile(fPath)  &&  rm(fPath);
		open(fPath, "w") do io
			write_beamer_header(io);
			for figName ∈ ("afqtMeanByQual.pdf", "fracGradByQual.pdf", 
				"parameter_table_test.tex")

				figPath = joinpath(testDir, figName);
				write_figure_slide(io, figName, figPath);
			end
			write_beamer_footer(io);
		end
		@test isfile(fPath)

		success = typeset_file(fPath);
		@test success
	end
end

function param_tb_test()
	@testset "ParameterTable" begin
		pt = ParameterTable();
		add_row!(pt, "p1", "param 1", "1.23");
		# Not robust. Skipping 2 header rows
		@test nrows(pt.tb) == 3
		@test pt.tb.bodyV[3] == "p1 & param 1 & 1.23"
		add_row!(pt, "p2", "param 2", "2.34");
		write_table(pt, joinpath(test_dir(), "parameter_table_test.tex"))
	end
end

function cell_test()
	@testset "Cell" begin
		c = LatexLH.Cell("abc", 1, 'c', LatexLH.CellColor("blue", 40))
		@test c.text == "abc"
		@test cell_string(c) == "\\cellcolor{blue!40}abc"

		c = LatexLH.Cell("abc");
		@test c.text == "abc"

		c = LatexLH.Cell("abc", 'c');
		@test c.text == "abc"
		@test c.align == 'c'
		@test cell_string(c) == "abc"

		c = LatexLH.Cell("abc", 2, 'c', LatexLH.CellColor("blue", 40))
		@test cell_string(c) == "\\multicolumn{2}{c}{\\cellcolor{blue!40}abc}"
	end
end

function table_test()
	@testset "Table" begin
		nCols = 5;
		tb = LatexLH.Table(nCols, "lSSSS");
		LatexLH.add_row!(tb, " & \\multicolumn{3}{c}{Heading 1} & ");
		@test length(tb.bodyV) == 1

		cellV = [LatexLH.Cell("cell1"),  LatexLH.Cell("cell2", 4, 'c')]
		rowStr = LatexLH.make_row(tb, cellV);
		@test rowStr == "cell1 & \\multicolumn{4}{c}{cell2}"
		LatexLH.add_row!(tb, rowStr);
		@test length(tb.bodyV) == 2

		LatexLH.add_row!(tb, "\\cline{2-5}")
		LatexLH.add_row!(tb, "x1 & 1.2 & 2.3 & 3.4 & 4.5")

		filePath = joinpath(test_dir(), "TableTest.tex")
		if isfile(filePath)
			rm(filePath)
		end
		write_table(tb, filePath)
		@test isfile(filePath)
	end
end

function cell_color_test()
	@testset "CellColor" begin
		x = LatexLH.CellColor("blue", 40);
		s = color_string(x);
		# println(s)
		@test s == "\\cellcolor{blue!40}"

		x = LatexLH.CellColor("green", 0)
		s = color_string(x);
		# println(s)
		@test s == ""
	end
end

@testset "LatexLH" begin
	pieces_test();
	make_doc_test();
	figure_comparison_test();
	cell_color_test();
	table_test();
	cell_test();
	param_tb_test();
    beamer_test();
    include("symbol_table_test.jl")
end

# -----------