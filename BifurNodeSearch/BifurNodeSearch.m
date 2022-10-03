function BifurNode=BifurNodeSearch(node,link,thres) 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% INPUT: BifurNodeSearch(node, link,threshold)
% This function search through all nodes and collect the node index that satisfy
% the given condition  
%  Condition1: number of links connected to a node should be 3
%  Condition2: each links should be longer than (thres) pixel
% OUTPUT: list of node indexes that satisfy the condition above
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

k=1; %Checked Node
BifurNode=[];
while k<length(node)+1
%Look only for bifurcation point of 3 
    if (length(node(k).links)==3)
        if (length(link(node(k).links(1)).point)>=thres) && (length(link(node(k).links(2)).point)>=thres) && (length(link(node(k).links(3)).point)>=thres)
            BifurNode=[BifurNode k];
        end    
    end
    k=k+1;
end 
end 