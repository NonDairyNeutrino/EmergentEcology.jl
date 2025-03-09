# EmergentEcology.jl

[![Build Status](https://github.com/nondairyneutrino/EmergentEcology.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/nondairyneutrino/EmergentEcology.jl/actions/workflows/CI.yml?query=branch%3Amain)

A Julia framework for generative ecosystems combining Wave Function Collapse (WFC) for spatial coherence with Cellular Automata (CA) for temporal evolution.  Parts of this work have been produced using artificial intelligence.

<!-- ![Sample Evolution](assets/sample_evolution.gif) -->

## Overview

EmergentEcology explores the intersection of two powerful generative algorithms by treating them as complementary approaches to different aspects of procedural generation:

1. **Wave Function Collapse (WFC)**: Creates spatially coherent initial states with well-defined boundaries and transitions
2. **Cellular Automata (CA)**: Evolves these states over time to simulate natural processes

This hybridization is analogous to the relationship between boundary-value problems and initial-value problems in mathematics - one defines spatial constraints while the other manages temporal evolution.

## Features

- **Constraint-Based Generation**: Create coherent landscapes with realistic transitions between different terrain types
- **Dynamic Evolution**: Observe how these landscapes change over time according to ecological rules
- **Customizable Rules**: Define your own adjacency constraints and evolution rules
- **Interactive Visualization**: Watch your generated worlds evolve through animated visualizations
- **High-Performance**: Optimized Julia implementation for handling large grid sizes

## Installation

```julia
using Pkg
Pkg.add(url="https://github.com/yourusername/EmergentEcology.jl")
```

## Quick Start

```julia
using EmergentEcology

# Run a simulation with default parameters
width, height = 100, 100
num_steps = 30
simulation_history = run_simulation(width, height, num_steps)

# Visualize the evolution
generate_animation(simulation_history, "evolution.gif")

# Compare initial and final states
visualize_comparison(simulation_history[1], simulation_history[end])
```

## How It Works

### Wave Function Collapse

The WFC algorithm:

1. Initializes each cell with all possible tile types (water, sand, grass, forest)
2. Iteratively collapses cells to specific states based on minimum entropy
3. Propagates constraints to maintain coherent boundaries
4. Produces a spatially coherent initial landscape

### Cellular Automata Evolution

The CA system:

1. Takes the initial WFC state as input
2. Applies transition rules based on neighboring cells
3. Simulates natural processes like erosion, vegetation growth, etc.
4. Creates a dynamic evolving ecosystem

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

Areas for improvement:

- Additional tile types and ecosystems
- More sophisticated evolution rules
- Performance optimizations
- Enhanced visualization options
- Parallelization for large grids

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- This project was inspired by discussions about the relationship between WFC and CA systems
- Thanks to the Julia community for creating an excellent language for scientific computing