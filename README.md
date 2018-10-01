# Student info
* Name: Truc D Nguyen
* UFID: 9482-7764

# Instructions
The main source code is in **lib/**

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
