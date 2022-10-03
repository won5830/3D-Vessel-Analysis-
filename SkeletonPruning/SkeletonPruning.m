function [skel2, node2, link2]=SkeletonPruning(skel,cut) 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% WARNING: images should be ordered strictly!! including the digits!!
% INPUT: SkeletonPruning(skeleton matrix, pruning length)
% You should input pruning length as second variable of the function 
% Pruning length is based on the number of pixel of each links 
% Links lower than the threshold(or cut) will be eliminated
% OUTPUT: [pruned skeleton, pruned node information, pruned link information]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

w=size(skel,1);
l=size(skel,2);
h=size(skel,3);

% initial step: condense, convert to voxels and back, detect cells
[~,node,link] = Skel2Graph3D(skel,0);

% total length of network
wl = sum(cellfun('length',{node.links}));

% PRUNING CONTROL 
skel2 = Graph2Skel3D(node,link,w,l,h); %pruning된 그래프를 이용하여 다시 skeletalize
[~,node2,link2] = Skel2Graph3D(skel2,cut);

% calculate new total length of network 
wl_new = sum(cellfun('length',{node2.links})); %한번 prune된 거의 각 node에 연결된 link들의 수를 합한거 

% iterate the same steps until network length changed by less than 0.5%
while(wl_new~=wl)
    wl = wl_new;   
     skel2 = Graph2Skel3D(node2,link2,w,l,h);
     [~,node2,link2] = Skel2Graph3D(skel2,cut);
     wl_new = sum(cellfun('length',{node2.links}));
end
end 
