using Test
using Colors
using EmergentEcology: get_tile_color, get_tile_name, add_tile!, add_tile_color!, add_tile_type!, tile_from_name, tile_from_id
# include("../src/tile.jl")

@testset "Tile functionality" begin
    @testset "Basic tile operations" begin
        # Test predefined tiles
        @test typeof(water) == Tile
        @test typeof(sand) == Tile
        @test typeof(grass) == Tile
        @test typeof(forest) == Tile
        
        # Test equality
        @test water == water
        @test water != sand
        @test sand != grass
        
        # Test hashing (for dictionary keys)
        tile_dict = Dict(water => "water", sand => "sand")
        @test tile_dict[water] == "water"
        @test tile_dict[sand] == "sand"
    end
    
    @testset "Tile names and colors" begin
        # Test getting names
        @test get_tile_name(water) == :water
        @test get_tile_name(sand) == :sand
        @test get_tile_name(grass) == :grass
        @test get_tile_name(forest) == :forest
        
        # Test getting colors
        @test get_tile_color(water) == colorant"royalblue"
        @test get_tile_color(sand) == colorant"goldenrod1"
        @test get_tile_color(grass) == colorant"yellowgreen"
        @test get_tile_color(forest) == colorant"forestgreen"
    end
    
    @testset "Custom tile creation" begin
        # Add a new tile type
        mountain_id = add_tile!(:mountain)
        mountain_color = colorant"#7f8c8d"
        add_tile_color!(mountain_id, mountain_color)
        mountain = tile_from_name(:mountain)
        
        # Test the new tile
        @test typeof(mountain) == Tile
        @test get_tile_name(mountain) == :mountain
        @test get_tile_color(mountain) == mountain_color
        @test mountain != water
        
        # Test tile from ID
        @test tile_from_id(mountain_id) == mountain
    end
    
    @testset "Display functionality" begin
        # Test string representation
        @test sprint(show, water) == "Tile(water)"
        @test sprint(show, sand) == "Tile(sand)"
        @test sprint(show, grass) == "Tile(grass)"
        
        # Test unknown tile display
        unknown_tile = Tile(999)  # Assuming 999 is not a registered ID
        @test occursin("id=999", sprint(show, unknown_tile))
    end
    
    @testset "Package integration features" begin
        # Test the exported API function
        volcano = add_tile_type!(:volcano, colorant"#e74c3c")
        @test typeof(volcano) == Tile
        @test get_tile_name(volcano) == :volcano
        @test get_tile_color(volcano) == colorant"#e74c3c"
    end
end