module Ant

using Plots, Random
export System, BoundaryType, animate!, step!
########
# System
########

"""
0 -> white
1 -> black
"""

# Boundary structure
abstract type BoundaryType end

struct RigidBoundary <: BoundaryType end  
struct BouncingBoundary <: BoundaryType end  
struct PeriodicBoundary <: BoundaryType end  

# System structure
@kwdef struct System{T, Boundary <: BoundaryType}
    grid::Matrix{T}  # Cellular automata's grid
    ant::Vector{Int}  # Ant's position and direction
    directions::Dict  # Direction dictionary
    boundary::Boundary  # Type of boundary
end
# System constructor
function System{T, Boundary}(x::Int, y::Int, boundary::Boundary) where {T, Boundary <: BoundaryType}
    ant = [rand(1:x), rand(1:y), rand(0:3)]  # Randomly initialize the ant's position and direction
    matrix = zeros(T, x, y)  # Initialize the grid
    dict = Dict(
        0 => (0,1), # up
        1 => (1,0), # right
        2 => (0,-1), # down
        3 => (-1,0) # left
        )
    System(grid=matrix, ant=ant, directions=dict, boundary=boundary)
end

###########
# Direction
###########

"Rotate the ant by m * 90 degrees."
function rotation!(system::System, m::Int)
    system.ant[3] = (system.ant[3] + m) % 4
end

"Change direction of ant based on the tile it is located."
function direction!(system::System)
    # Change direction
    if system.grid[system.ant[1],system.ant[2]] == 0 # white -> clockwise
        rotation!(system,1)
    else # black -> counter-clockwise
        rotation!(system,3) # adds 3 to avoid negative indices: (dir - 1 + 4) % 4
    end
end

############
# Tile color
############

"Change color of tile from white->black (0->1) or black->white (1->0)."
function tile_color!(system::System,x::Int,y::Int)
    system.grid[x,y] = (system.grid[x,y] + 1) % 2
end

##########
# Movement
##########

"Moves the ant according to its direction."
function move!(system::System{T, PeriodicBoundary}) where {T}
    # Variables
    length, height = size(system.grid)
    x, y, dir = copy(system.ant)
    # Change tile
    tile_color!(system,x,y)
    # Move
    dx, dy = system.directions[dir] # increment
    x += dx
    y += dy
    # Periodic boundary conditions:
    ## The modulus operator uses x-1 and y-1 to account for Julia's 1-indexing
    ## After taking the remainder, adds length or height to ensure the indices are positive
    ## Takes the remainder again, with positive indices
    ## Adds 1 to restore 1-indexing
    system.ant[1] = ((x-1) % length + length) % length + 1
    system.ant[2] = ((y-1) % height + height) % height + 1
end
function move!(system::System{T, RigidBoundary}) where {T}
    # Variables
    length, height = size(system.grid)
    x, y, dir = copy(system.ant)
    # Move
    dx, dy = system.directions[dir] # increment
    newx = x+dx
    newy = y+dy
    # Rigid boundary conditions:
    ## The ant stays in place
    newx = clamp(newx,1,length)
    newy = clamp(newy,1,height)
    system.ant[1] = newx
    system.ant[2] = newy
    # Change tile
    if newx != x || newy != y
        tile_color!(system,x,y)
    end
end
function move!(system::System{T, BouncingBoundary}) where {T}
    # Variables
    length, height = size(system.grid)
    x, y, dir = copy(system.ant)
    # Move
    dx, dy = system.directions[dir] # increment
    newx = x+dx
    newy = y+dy
    # Bouncing boundary conditions:
    ## The ant goes back one step and changes direction by 180 degrees
    if newx < 1 || newx > length
        newx -= 2dx
        rotation!(system,2)
    end
    if newy < 1 || newy > height
        newy -= 2dy
        rotation!(system,2)
    end
    system.ant[1] = newx
    system.ant[2] = newy
    # Change tile
    tile_color!(system,x,y)
end

###########
# Time step
###########

"Make one ant step."
function step!(system::System)
    direction!(system)
    move!(system)
end

function animate!(sys::System,step::Int64)
    color_map = cgrad([:white, :black, :red], [0, 1, 2])
    data = copy(sys.grid) # if copy not taken, the grid will receive wrong values
    data[sys.ant[1],sys.ant[2]] = 2 # paints red where ant is
    heatmap(transpose(data),color=color_map,colorbar=false,display=true,title="$step steps")
end

end # module

######
# Main
######

import .Ant
function main()
    n = 100
    m = 100
    sys = Ant.System{Int64,Ant.BouncingBoundary}(n,m,Ant.BouncingBoundary())
    for i in 1:1000
        Ant.animate!(sys,i)
        Ant.step!(sys)
        #println(sys.ant[3])
        sleep(.001)
    end
end

main()