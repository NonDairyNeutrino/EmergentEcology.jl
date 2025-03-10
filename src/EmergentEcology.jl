module EmergentEcology

using Random
using Colors
using Plots

# Export public interface
export Tile, water, sand, grass, forest
export run_simulation, visualize, generate_animation
export visualize_comparison, add_tile_type!, add_evolution_rule!

# Include component files
include("tile.jl")
# include("wfc.jl")
# include("ca.jl")
# include("visualization.jl")

"""
    run_simulation(width :: Int, height :: Int, num_steps :: Int; 
                  adjacency_rules = nothing, 
                  evolution_rules = nothing,
                  random_seed = nothing) :: Vector{Matrix{Tile}}

Run the full simulation, generating an initial state with WFC and evolving it with CA.

# Arguments
- `width`: Width of the simulation grid
- `height`: Height of the simulation grid
- `num_steps`: Number of CA evolution steps to run
- `adjacency_rules`: Optional custom adjacency rules for WFC
- `evolution_rules`: Optional custom evolution rules for CA
- `random_seed`: Optional seed for reproducibility

# Returns
- Vector of grid states for each step of the simulation
"""
function run_simulation(width :: Int, height :: Int, num_steps :: Int; 
                       adjacency_rules = nothing, 
                       evolution_rules = nothing,
                       random_seed = nothing) :: Vector{Matrix{Tile}}
    
    # Set random seed if provided
    if random_seed !== nothing
        Random.seed!(random_seed)
    end
    
    # Use custom rules if provided
    if adjacency_rules !== nothing
        WFC.set_adjacency_rules(adjacency_rules)
    end
    
    if evolution_rules !== nothing
        CA.set_evolution_rules(evolution_rules)
    end
    
    # Generate initial state using WFC
    println("Generating initial state with WFC...")
    initial_grid = WFC.generate_map(width, height)
    
    # Pre-allocate simulation history array for efficiency
    history = Vector{Matrix{Tile}}(undef, num_steps + 1)
    history[1] = initial_grid
    
    # Evolve using CA
    println("Evolving with Cellular Automata...")
    current_grid = initial_grid
    for step in 1:num_steps
        current_grid = CA.update_grid(current_grid)
        history[step + 1] = copy(current_grid)
        
        # Progress indicator
        if step % 5 == 0 || step == num_steps
            println("Completed step $step of $num_steps")
        end
    end
    
    return history
end

"""
    visualize_comparison(initial_grid :: Matrix{Tile}, final_grid :: Matrix{Tile}; 
                        title_initial = "Initial State (WFC)", 
                        title_final = "Final State (after CA evolution)",
                        size = (800, 400))

Create a side-by-side comparison of initial and final states.
"""
function visualize_comparison(initial_grid :: Matrix{Tile}, final_grid :: Matrix{Tile}; 
                             title_initial = "Initial State (WFC)", 
                             title_final = "Final State (after CA evolution)",
                             size = (800, 400))
    
    initial_plot = visualize(initial_grid)
    title!(initial_plot, title_initial)
    
    final_plot = visualize(final_grid)
    title!(final_plot, title_final)
    
    return plot(initial_plot, final_plot, layout=(1,2), size=size)
end

"""
    add_evolution_rule!(rule_function, tile_type = nothing)

Add a custom evolution rule for a specific tile type or for all tiles.

Example:
```julia
add_evolution_rule!(fire) do grid, i, j, neighbor_counts
    # Return new tile state based on current state and neighbors
    if neighbor_counts[forest] > 3
        return fire
    else
        return current_tile
    end
end
```
"""
function add_evolution_rule!(rule_function, tile_type = nothing)
    CA.add_rule!(rule_function, tile_type)
end

end # module EmergentEcology