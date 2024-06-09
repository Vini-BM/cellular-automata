using Random

function getRule(rule,numNeigh)
    """
    Returns a vector with all possible outcomes for a given rule.
    Uses a numNeigh + 1 neighborhood.
    The number of possible rules is 2^(2^(numNeigh+1)).
    """
    R = [] # vector for saving outcomes
    for i in 1:2^(numNeigh+1) # possible combinations
        push!(R,rule%2) # binary decomposition
        rule = div(rule,2)
    end
    return R
end

function printState(state)
    """
    Prints the automaton state on the terminal.
    """
    state_str = Vector(undef,length(state))
    for i in 1:length(state)
        if state[i] == 1
            state_str[i] = '#'
        else
            state_str[i] = ' '
        end
    end
    sleep(0.025)
    foreach(print,state_str) # prints only vector elements
    println()
end

function automaton!(rule,numNeigh=2,N=50,tmax=50,random=0)
    """
    Runs an N-cell automaton with numNeighb neighbors for tmax timesteps using a given rule.
    Begins with the middle cell set to 1 and all others set to 0. If random!=0, begins with a random state.
    """

    R = getRule(rule,numNeigh) # list for outcomes
    # Initial state
    if Int(random) == 0
        state = zeros(Int64,N)
        state[Int(N/2)] = 1 # middle cell set to 1
    else
        state = rand(0:1,N) # initial random state
    end
    # Print initial state
    printState(state) # prints initial state
    # Initialization
    ## Counter
    t = 0 # timestep
    ## Variable for loop on neighbors
    lim = div(numNeigh,2) # limit for neighborhood -> boundary conditions treated differently
    ## Auxiliary state
    newstate = zeros(Int64, N) # auxiliary state for simultaneous update
    ## Exponent for decimal decomposition of rule
    exp = [e for e in 0:numNeigh] # rule exponent
    reverse!(exp) # reverse order
    
    # Loop
    while t <= tmax
        t+=1 # update counter
        
        # Loop on automaton -> from left to right
        # Using periodic boundary conditions
        for i in 1:N # site i
            d = 0 # decimal number to associate to rule
            for j in 1:lim+2 # loop on neighbors and exponents
                index = i+j-lim-1 # index for neighbor
                if index > N # PBC
                    index -= N # reverse index to beginning
                elseif index <= 0
                    index = N-index # reverse index to end
                end
                d += 2^exp[j]*state[index] # decimal decomposition of neighbors
            end
            newstate[i] = R[d+1] # get result from rule
        end
        state = copy(newstate) # update state
        printState(state) # print state
    end
end

if abspath(PROGRAM_FILE) == @__FILE__
    if length(ARGS) == 0 # no parameters
        rule = rand(0:255) # random rule for three-neighborhood automaton
        automaton!(rule)
    else # all parameters specified
        rule, numNeigh, N, tmax, random = parse.(Int,ARGS)
        automaton!(rule,numNeigh,N,tmax,random)
    end
end