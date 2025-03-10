"""
    Tile Module

Defines the Tile type and basic tile operations for the EmergentEcology package.
Tiles represent different terrain types in the simulation.
"""

# Define the Tile type as a wrapper around an integer ID
struct Tile
    id::Int
end

# Dictionary to map tile names to their IDs
const TILE_NAMES = Dict{Int, Symbol}()

# Dictionary to map tile IDs to their display colors
const TILE_COLORS = Dict{Int, Colorant}()

# Dictionary to map tile names to Tile instances
const TILE_INSTANCES = Dict{Symbol, Tile}()

# Next available tile ID
next_tile_id = Ref(1)

"""
    add_tile!(name::Symbol) :: Int

Register a new tile type with the given name.
Returns the ID assigned to the new tile type.
"""
function add_tile!(name::Symbol) :: Int
    id = next_tile_id[]
    next_tile_id[] += 1
    
    TILE_NAMES[id] = name
    TILE_INSTANCES[name] = Tile(id)
    
    return id
end

"""
    add_tile_color!(id::Int, color::Colorant)

Associate a color with a tile ID for visualization purposes.
"""
function add_tile_color!(id::Int, color::Colorant)
    TILE_COLORS[id] = color
end

"""
    add_tile_type!(name :: Symbol, color :: Colorant)

Register a new tile with a given color.
"""
function add_tile_type!(name :: Symbol, color :: Colorant) :: Tile
    id = add_tile!(name)
    add_tile_color!(id, color)
    return TILE_INSTANCES[name]
end

"""
    get_tile_name(tile::Tile) :: Symbol

Get the name associated with a tile.
"""
function get_tile_name(tile::Tile) :: Symbol
    return TILE_NAMES[tile.id]
end

"""
    get_tile_color(tile::Tile) :: Colorant

Get the color associated with a tile for visualization.
"""
function get_tile_color(tile::Tile) :: Colorant
    return TILE_COLORS[tile.id]
end

"""
    Base.show(io::IO, tile::Tile)

Custom display for Tile objects.
"""
function Base.show(io::IO, tile::Tile)
    if haskey(TILE_NAMES, tile.id)
        print(io, "Tile($(TILE_NAMES[tile.id]))")
    else
        print(io, "Tile(id=$(tile.id))")
    end
end

"""
    Base.:(==)(a::Tile, b::Tile) :: Bool

Compare two tiles by their IDs.
"""
Base.:(==)(a::Tile, b::Tile) = a.id == b.id

"""
    Base.hash(tile::Tile, h::UInt) :: UInt

Hash function for Tile objects.
"""
Base.hash(tile::Tile, h::UInt) = hash(tile.id, h)

# Define basic terrain types
const water = begin
    id = add_tile!(:water)
    add_tile_color!(id, colorant"royalblue")
    TILE_INSTANCES[:water]
end

const sand = begin
    id = add_tile!(:sand)
    add_tile_color!(id, colorant"goldenrod1")
    TILE_INSTANCES[:sand]
end

const grass = begin
    id = add_tile!(:grass)
    add_tile_color!(id, colorant"yellowgreen")
    TILE_INSTANCES[:grass]
end

const forest = begin
    id = add_tile!(:forest)
    add_tile_color!(id, colorant"forestgreen")
    TILE_INSTANCES[:forest]
end

"""
    tile_from_name(name::Symbol) :: Tile

Get a Tile instance by its name.
"""
function tile_from_name(name::Symbol) :: Tile
    return TILE_INSTANCES[name]
end

"""
    tile_from_id(id::Int) :: Tile

Get a Tile instance by its ID.
"""
function tile_from_id(id::Int) :: Tile
    return Tile(id)
end