import numpy as np
from copy import deepcopy
from time import sleep
from sys import argv

def getRule(rule,numNeigh):
    """
    Returns a list with all possible outcomes for a given rule.
    Uses a numNeigh + 1 neighborhood.
    The number of possible rules is 2^(2^(numNeigh+1)).
    """
    R = [] # list for saving outcomes
    for i in range(2**(numNeigh+1)):
        R.append(rule%2)
        rule = int(rule/2) # append outcome for a given configuration
    return R

def printState(state):
    """
    Prints the automaton state on the terminal.
    """
    state_str = ['#' if i==1 else ' ' for i in state] # uses # for 1 and whitespace for 0
    sleep(0.025)
    print(*state_str, sep='') # print only array elements


def automaton(rule,numNeigh=2,N=50,tmax=50,random=0):
    """
    Runs an N-cell automaton with numNeighb neighbors for tmax timesteps using a given rule.
    Begins with the middle cell set to 1 and all others set to 0. If random!=0, begins with a random state.
    """

    # Rule
    R = getRule(rule,numNeigh) # list for outcomes
    # Initial state
    if int(random) == 0:
        state = np.zeros(N, dtype=int)
        state[N//2] = 1 # middle cell set to 1
    else:
        state = np.random.randint(0,2,N) # initial random state
    # Print initial state
    printState(state) # prints initial state
    
    # Initialization
    ## Counter
    t = 0 # timestep
    ## Variable for loop on neighbors
    lim = int(numNeigh/2) # limit for neighborhood -> boundary conditions treated differently
    ## Auxiliary state
    newstate = np.zeros(N, dtype=int) # auxiliary state for simultaneous update
    ## Exponent for decimal decomposition of rule
    exp = [e for e in range(0, numNeigh+1)] # rule exponent
    exp.reverse() # reverse order
    
    # Loop
    while t <= tmax:
        t+=1 # update counter
        
        # Loop on automaton -> from left to right
        # Using periodic boundary conditions
        for i in range(N): # site i
            d = 0 # decimal number to associate to rule
            for j in range(lim+2): # loop on neighbors and exponents
                index = i+j-lim # index for neighbor
                #print(index)
                if index >= N: # PBC
                    index -= N # reverse index
                d += 2**exp[j]*state[index] # decimal decomposition of neighbors
            newstate[i] = R[d] # get result from rule

        state = deepcopy(newstate) # update state
        printState(state) # print state
    return

if __name__ == '__main__':
    if len(argv) == 1: # no parameters
        rule = np.random.randint(0,256) # random rule for three-neighborhood automaton
        automaton(rule)
    else:
        rule = int(argv[1])
        numNeigh = int(argv[2])
        N = int(argv[3])
        tmax = int(argv[4])
        random = argv[5]
        automaton(rule,numNeigh,N,tmax,random)