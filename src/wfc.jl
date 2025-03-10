"""
    Wave Function Collapse (WFC) Module

Implements the Wave Function Collapse algorithm for procedural terrain generation.
This module generates coherent initial states for the cellular automata system.
"""
module WFC

using Random
using ..EmergentEcology: Tile, water, sand, grass, forest

# Default possible tiles
const DEFAULT_TILES = [water, sand, grass, forest]

# Default adjacency rules
# Format: Dict(tile => Dict(direction => [allowed_neighbor_tiles]))
const DEFAULT_ADJACENCY_RULES = Dict(
    water => Dict(
        :up => [water, sand],
        :down => [water],
        :left => [water, sand],
        :right => [water, sand]
    ),
    sand => Dict(
        :up => [sand, grass],
        :down => [water, sand],
        :left => [water, sand, grass],
        :right => [water, sand, grass]
    ),
    grass => Dict(
        :up => [grass, forest],
        :down => [sand, grass],
        :left => [sand, grass, forest],
        :right => [sand, grass, forest]
    ),
    forest => Dict(
        :up => [forest],
        :down => [grass, forest],
        :left => [grass, forest],
        :right => [grass, forest]
    )
)

const DIRECTIONS = Dict(
    :up => CartesianIndex(-1, 0),
    :down => CartesianIndex(1, 0),
    :left => CartesianIndex(0, -1),
    :right => CartesianIndex(0, 1)
)

const OPPOSITES = Dict(
    :up => :down, 
    :down => :up, 
    :left => :right, 
    :right => :left
)

# Current adjacency rules (mutable to allow customization)
global ADJACENCY_RULES = deepcopy(DEFAULT_ADJACENCY_RULES)

"""
    set_adjacency_rules(rules::Dict{Tile, Dict{Symbol, Vector{Tile}}})

Set custom adjacency rules for the WFC algorithm.
"""
function set_adjacency_rules(rules::Dict{Tile, Dict{Symbol, Vector{Tile}}})
    global ADJACENCY_RULES = deepcopy(rules)
end

"""
    reset_adjacency_rules()

Reset adjacency rules to the defaults.
"""
function reset_adjacency_rules()
    global ADJACENCY_RULES = deepcopy(DEFAULT_ADJACENCY_RULES)
end

"""
    get_allowed_neighbors(tile::Tile, direction::Symbol) :: Vector{Tile}

Get tiles allowed to be neighbors in the specified direction.
"""
function get_allowed_neighbors(tile::Tile, direction::Symbol) :: Vector{Tile}
    if haskey(ADJACENCY_RULES, tile) && haskey(ADJACENCY_RULES[tile], direction)
        return ADJACENCY_RULES[tile][direction]
    else
        # If no specific rule, allow all tiles
        return DEFAULT_TILES
    end
end

"""
    is_valid_neighbor(tile::Tile, neighbor::Tile, direction::Symbol) :: Bool

Check if a tile can be placed next to another tile in the specified direction.
"""
@inline function is_valid_neighbor(tile::Tile, neighbor::Tile, direction::Symbol) :: Bool
    return neighbor in get_allowed_neighbors(tile, direction)
end

"""
    get_opposite_direction(direction::Symbol) :: Symbol

Get the opposite direction.
"""
@inline function get_opposite_direction(direction::Symbol) :: Symbol
    return OPPOSITES[direction]
end

"""
    calculate_entropy(possibilities::Vector{Tile}) :: Float64

Calculate the entropy (uncertainty) of a cell based on its possible states.
"""
@inline function calculate_entropy(possibilities::Vector{Tile}) :: Int
    return length(possibilities) - 1
end

"""
    collapse(cell :: Vector{Tile}) :: Vector{Tile}

Collapse the cell to one of its possible values.
"""
function collapse!(gp :: Matrix{Vector{Tile}}, ci :: CartesianIndex{2}) :: Nothing
    gp[ci] = [rand(gp[ci])]
    return nothing
end

"""
    generate_map(height :: UInt, width :: UInt) :: Matrix{Tile}

Generate a terrain map using the Wave Function Collapse algorithm.
"""
function generate_map(height :: UInt, width :: UInt) :: Matrix{Tile}
    # Initialize grid with all possibilities for each cell
    gp = fill(DEFAULT_TILES, height, width) # grid possibilities
    
    # Initialize mask of uncollapsed cells (true = uncollapsed)
    uncollapsed = fill(true, height, width)
    
    while any(uncollapsed)
        # collapse the cell with minimum entropy
        ci = argmin(calculate_entropy, gp) # collapse index
        collapse!(gp, ci)
        uncollapsed[ci] = false

        # Propagate constraints
        propagate_constraints!(gp, uncollapsed, ci, (height, width))
    end
    
    return first.(gp)
end

"""
    propagate_constraints!(grid_possibilities, uncollapsed, idx, dims)

Propagate constraints using optimized functional approach.
"""
function propagate_constraints!(gp :: Matrix{Vector{Tile}}, uncollapsed :: Matrix{Bool}, idx :: CartesianIndex, dims :: Dims)
    height, width = dims
    queue = [idx]
    
    # Process queue
    while !isempty(queue)
        current_idx = popfirst!(queue)
        current_options = gp[current_idx]
        
        # Process each direction
        valid_directions = filter(DIRECTIONS) do (_, offset)
            checkbounds(Bool, gp, current_idx + offset)
        end

        for (dir, offset) in valid_directions
            neighbor_idx = current_idx + offset
            
            neighbor_options = gp[neighbor_idx]
            original_count = length(neighbor_options)
            
            # Filter options using broadcast + any
            valid_options = filter(neighbor_options) do option
                any(tile -> is_valid_neighbor(tile, option, dir), current_options)
            end
            
            # Update if changed
            if !isempty(valid_options) && length(valid_options) < original_count
                gp[neighbor_idx] = valid_options
                push!(queue, neighbor_idx)
                
                # Mark as collapsed if only one option remains
                if length(valid_options) == 1
                    uncollapsed[neighbor_idx] = false
                end
            elseif isempty(valid_options) && !isempty(neighbor_options)
                # Handle contradiction
                gp[neighbor_idx] = [rand(neighbor_options)]
                uncollapsed[neighbor_idx] = false
                push!(queue, neighbor_idx)
            end
        end
    end
end
end