# Student info
* Name: Truc D Nguyen
* UFID: 9482-7764

# Instructions
The main source code is in **lib/**:
* proj.ex: This file defines main routines and network topology
* gossip_node.ex: The implementation of a node using the Gossip algorithm
* push_sum_node.ex: The implementation of a node using the Push-Sum algorithm

### Configuration and Compilation
To compile:
```
$ mix escript.build
```

### Run syntax
```
$ ./proj2 <numNode> <topology> <alogrithm>
```
- numNode: number of nodes in the network
- topology: one of **full, 3D, rand2D, sphere, line, imp2D**
- algorithm: one of **gossip, push-sum**

### Output 
Time it takes to converge in milliseconds

### Example
```
$ ./proj2 256 imp2D gossip
Elapsed time = 208.081
```

# What is working
- I've implemented all six topologies and two algorithms
- The program can be built using _escript_
- For _3D_ topology, each level of the cube is a 4x4 grid. Therefore, the number of nodes is rounded to the 
nearest integer that is divisible by 16.
- For _Sphere_ topology, each row has 4 nodes. Therefore, the number of nodes is rounded to the 
nearest integer that is divisible by 4.
- The convergence time is measured from the point when the program initiates the first message to the point when the 
network has achieved convergence

# Largest network
### Gossip
- Line: 5000. It takes about 108.62 seconds to achieve convergence
- rand2D: 5000. It takes about 0.721 seconds to achieve convergence
- full: 10000. It takes about 59.284 seconds to achieve convergence
- imp2D: 10000. It takes about 0.517 seconds to achieve convergence
- 3D: 10000. It takes about 16.042 seconds to achieve convergence
- sphere: 10000. It takes about 33.350 seconds to achieve convergence

### Push-sum
- Line: 1000. It takes about 1071.904 seconds (~ 16 minutes) to achieve convergence
- 3D: 1000. It takes about 86.750 seconds to achieve convergence
- sphere: 1000. It takes about 168.727 seconds to achieve convergence
- rand2D: 1000. It takes about 14.367 seconds to achieve convergence
- full: 10000. It takes about 1574.649 seconds (~ 26 minutes) to achieve convergence
- imp2D: 10000. It takes about 160.734 seconds to achieve convergence



