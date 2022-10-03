# skel2graph3d: calculate the network graph of a 3D skeleton

This function converts a 3D binary voxel skeleton into a network graph described by nodes and edges.

The input is a 3D binary image containing a one-dimensional voxel skeleton, generated e.g. using the "Skeleton3D" thinning function available on MFEX. The output is the adjacency matrix of the graph, and the nodes and links of the network as MATLAB structure.

## Usage:

`[A,node,link] = Skel2Graph(skel,THR)`

where "skel" is the input 3D binary image, and "THR" is a threshold for the minimum length of branches, to filter out skeletonization artifacts.

A is the adjacency matrix with the length of the links as matrix entries, and node/link are the structures describing node and link properties.

>> adjacency행렬은 각 노드들을 축으로 하고, entry에는 각 노드간의 길이가 들어가 있는 거지 행렬 형식으로 

A node has the following properties:

- idx             List of voxel indices of this node
각 pixel(voxel)에 인덱스를 매겼을 때, 특정 노드에 연결되어 있는 voxel들을 나열한 것 


- links           List of links connected to this node
링크들에 인덱싱을 매겼을 경우, 각 노드에 부착된 링크들을 인덱싱

- conn            List of destinations of links of this node
말 그대로 이 노드에 연결된 링크들이 어느 destination node로 연결되는지!!, (connection) 
아 link랑 1대1로 연결되는 거구나 30-1-72 면 links는 1이고 conn은 72(노드)인거지 

- comX,comY,comZ  Center of mass of all voxels of this node
voxel같은 걸로 node의 center of mass를 

- ep              1 if node is endpoint (degree 1), 0 otherwise
말그대로 endpoint인지 여부 확인해주는 거 


A link has the following properties:

- n1      Node where link starts
- n2      Node where link ends
- point   List of voxel indices of this link
#링크사이에 있는 voxel들의 index 

A second function, "Graph2Skel3D.m", converts the network graph back into a cleaned-up voxel skeleton image.

An example of how to use these functions is given in the script "Test_Skel2Graph3D.m", including a test image. In this example, it is also demonstrated how to iteratively combine both conversion functions in order to obtain a completely cleaned skeleton graph.

Any comments, corrections or suggestions are highly welcome. If you include this in your own work, please cite our publicaton [1].

Philip Kollmannsberger 09/2013, 01/2016
philipk@gmx.net

[1] Kollmannsberger, Kerschnitzki et al.,
"The small world of osteocytes: connectomics of the lacuno-canalicular network in bone."
New Journal of Physics 19:073019, 2017.
