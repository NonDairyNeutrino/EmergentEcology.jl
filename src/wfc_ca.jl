using Random
using Colors
using Plots

# Tile-based Wave Function Collapse implementation
module WFC
    # Define tile types and their allowed neighbors
    const TILE_TYPES = [:water, :sand, :grass, :forest]
    
    # Adjacency rules: which tiles can be placed next to each other
    const ADJACENCY_RULES = Dict(
        :water => [:water, :sand],
        :sand => [:water, :sand, :grass],
        :grass => [:sand, :grass, :forest],
        :forest => [:grass, :forest]
    )
    
    # Entropy-based Wave Function Collapse algorithm
    function generate_map(width, height)
        # Initialize with all cells having all possibilities
        grid = [Set(TILE_TYPES) for _ in 1:height, _ in 1:width]
        
        # Keep track of cells with their entropy (number of possible states)
        function calculate_entropy(cell)
            return length(cell) > 1 ? length(cell) + rand() * 0.1 : Inf
        end
        
        # Main WFC loop
        while any(cell -> length(cell) > 1, grid)
            # Find cell with minimum entropy
            min_entropy = Inf
            min_i, min_j = 1, 1
            
            for i in 1:height, j in 1:width
                if length(grid[i, j]) > 1
                    entropy = calculate_entropy(grid[i, j])
                    if entropy < min_entropy
                        min_entropy = entropy
                        min_i, min_j = i, j
                    end
                end
            end
            
            # If no cells with multiple options remain, we're done
            if min_entropy == Inf
                break
            end
            
            # Collapse the cell with minimum entropy to a random valid state
            cell = grid[min_i, min_j]
            chosen_tile = rand(collect(cell))
            grid[min_i, min_j] = Set([chosen_tile])
            
            # Propagate constraints
            propagate_constraints!(grid, min_i, min_j, height, width)
        end
        
        # Convert from sets to single values
        return [first(grid[i, j]) for i in 1:height, j in 1:width]
    end
    
    # Propagate constraints after collapsing a cell
    function propagate_constraints!(grid, i, j, height, width)
        queue = [(i, j)]
        
        while !isempty(queue)
            i, j = popfirst!(queue)
            cell = grid[i, j]
            
            # Skip if the cell has multiple possibilities
            length(cell) != 1 && continue
            current_tile = first(cell)
            
            # Check all 4 neighbors
            for (di, dj) in [(0, 1), (1, 0), (0, -1), (-1, 0)]
                ni, nj = i + di, j + dj
                
                # Skip if out of bounds
                !(1 <= ni <= height && 1 <= nj <= width) && continue
                
                neighbor = grid[ni, nj]
                allowed_neighbors = ADJACENCY_RULES[current_tile]
                
                # Calculate the intersection of current possibilities and allowed neighbors
                new_possibilities = intersect(neighbor, Set(allowed_neighbors))
                
                # If this changes the neighbor's possibilities, update and add to queue
                if new_possibilities != neighbor && !isempty(new_possibilities)
                    old_size = length(neighbor)
                    grid[ni, nj] = new_possibilities
                    if length(new_possibilities) < old_size
                        push!(queue, (ni, nj))
                    end
                end
            end
        end
    end
end

# Cellular Automata implementation
module CA
    # Define CA rules for each tile type
    function apply_rule(grid, i, j, height, width)
        current = grid[i, j]
        
        # Count neighbors of each type
        neighbor_counts = Dict(:water => 0, :sand => 0, :grass => 0, :forest => 0)
        
        for di in -1:1, dj in -1:1
            (di == 0 && dj == 0) && continue
            ni, nj = i + di, j + dj
            if 1 <= ni <= height && 1 <= nj <= width
                neighbor_counts[grid[ni, nj]] += 1
            end
        end
        
        # Apply transition rules based on current tile and neighbors
        if current == :water
            # Water spreads to lower areas or stays water
            return :water
            
        elseif current == :sand
            # Sand can become water if surrounded by water, or grass if enough grass neighbors
            if neighbor_counts[:water] >= 5
                return :water
            elseif neighbor_counts[:grass] >= 3
                return :grass
            else
                return :sand
            end
            
        elseif current == :grass
            # Grass can become forest if enough forest neighbors
            # Or revert to sand if too dry (too many sand neighbors)
            if neighbor_counts[:forest] >= 3
                return :forest
            elseif neighbor_counts[:sand] >= 5
                return :sand
            else
                return :grass
            end
            
        elseif current == :forest
            # Forest stays forest unless too much water or sand nearby
            if neighbor_counts[:water] >= 4
                return :grass
            elseif neighbor_counts[:sand] >= 5
                return :grass
            else
                return :forest
            end
        end
        
        return current  # Default is no change
    end
    
    # Update the entire grid for one step
    function update_grid(grid)
        height, width = size(grid)
        new_grid = similar(grid)
        
        for i in 1:height, j in 1:width
            new_grid[i, j] = apply_rule(grid, i, j, height, width)
        end
        
        return new_grid
    end
end

# Visualization
function visualize(grid)
    color_map = Dict(
        :water => colorant"#0077be",
        :sand => colorant"#c2b280",
        :grass => colorant"#228b22",
        :forest => colorant"#013220"
    )
    
    colors = [color_map[cell] for cell in grid]
    return heatmap(colors, aspect_ratio=1, axis=nothing, legend=false)
end

# Main simulation
function run_simulation(width, height, num_steps)
    # Generate initial state using WFC
    println("Generating initial state with WFC...")
    initial_grid = WFC.generate_map(width, height)
    
    # Store simulation history
    history = [initial_grid]
    
    # Evolve using CA
    println("Evolving with Cellular Automata...")
    current_grid = initial_grid
    for step in 1:num_steps
        current_grid = CA.update_grid(current_grid)
        push!(history, copy(current_grid))
    end
    
    return history
end

# Set random seed for reproducibility
Random.seed!(42)

# Run the simulation
width, height = 256, 256
num_steps = 20
simulation_history = run_simulation(width, height, num_steps)

# Visualize the results
function generate_animation(history)
    println("Generating animation...")
    anim = @animate for (i, grid) in enumerate(history)
        p = visualize(grid)
        title!(p, "Step $(i-1)")
    end
    
    return anim
end

# Create and save animation
anim = generate_animation(simulation_history)
gif(anim, "wfc_ca_hybrid.gif", fps = 2)

# Also show initial and final states
println("Visualization complete.")
initial_plot = visualize(simulation_history[1])
title!(initial_plot, "Initial State (WFC)")

final_plot = visualize(simulation_history[end])
title!(final_plot, "Final State (after CA evolution)")

plot(initial_plot, final_plot, layout=(1,2), size=(1280, 720))
