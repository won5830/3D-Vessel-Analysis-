clear all;
close all;

% load example binary skeleton image
load skel

w = size(skel,1); %x index
l = size(skel,2); %y index
h = size(skel,3); %z index

% initial step: condense, convert to voxels and back, detect cells
[~,node,link] = Skel2Graph3D(skel,0);
%0외에 수치 기입으로 prune, THM은 pixel단위로 pruning하는것 같은데 근데 

% total length of network
wl = sum(cellfun('length',{node.links}));
%각 노드 별로 링크들의 갯수를 length로 구한뒤에 다 더한것 같다. 
%cellfun(함수, cell struct) 의 형식인데 string형태로 함수를 적용해줄 수 있다 : length는 cell의 길이
%계산 

skel2 = Graph2Skel3D(node,link,w,l,h); %pruning된 그래프를 이용하여 다시 skeletalize
[~,node2,link2] = Skel2Graph3D(skel2,10);

% calculate new total length of network 
wl_new = sum(cellfun('length',{node2.links})); %한번 prune된 거의 각 node에 연결된 link들의 수를 합한거 

% iterate the same steps until network length changed by less than 0.5%
%지금은 아예 reduction이 0이니까 while 구문이 안돌아가지 
while(wl_new~=wl) %~= : not equal... , 0.5%이상 바뀌지 않는 동안...,

    wl = wl_new;   
    
     skel2 = Graph2Skel3D(node2,link2,w,l,h);
     [A2,node2,link2] = Skel2Graph3D(skel2,10);

     wl_new = sum(cellfun('length',{node2.links}));

end


% display result
figure();
hold on;
for i=1:length(node2)
    %노드들 그리기
    x1 = node2(i).comx;
    y1 = node2(i).comy;
    z1 = node2(i).comz;
    
    if(node2(i).ep==1)
        ncol = 'c'; %끝점이면 cyan 색으로 표시
    else
        ncol = 'y'; %중간노드면 노란색으로 !
    end
    
    %노드간 connection그리기 
    for j=1:length(node2(i).links)    % draw all connections of each node, 각 노드에 부착된 링크들을 j로 받아서 하나씩
        if(node2(node2(i).conn(j)).ep==1) %만일 해당 링크가 endpoint에 연결돼있다? 
            col='k'; % branches are black
        else %만일 해당 노드가 end point가 아니다!
            col='r'; % links are red
        end
        if(node2(i).ep==1) %만약에 i로 받아지는 노드 자체가 ep면 중간점으로 가더라도 black이니까 
            col='k';
        end

        
        % draw edges as lines using voxel positions
        %ind2sub은 특정 숫자가 해당 행렬의 몇행 몇열에 있는지를 보는거야 
        for k=1:length(link2(node2(i).links(j)).point)-1  %각 link를 구성하는 voxel 꺼내주기
            %1을 빼주는 것은 어차피 선을 그리는 거니까... 그래서 k랑 k+1인거지
            %각 링크의 point정보를 접속해서 point의 index를 subscript로 바꿔주는 것 
            [x3,y3,z3]=ind2sub([w,l,h],link2(node2(i).links(j)).point(k)); %[w,l,h]는 행렬 크기 
            [x2,y2,z2]=ind2sub([w,l,h],link2(node2(i).links(j)).point(k+1)); %link2는 숫자에 해당하는거지 
            line([y3 y2],[x3 x2],[z3 z2],'Color',col,'LineWidth',2);
        end
    end
    
    % draw all nodes as yellow circles
    plot3(y1,x1,z1,'o','Markersize',9,...
        'MarkerFaceColor',ncol,...
        'Color','k');
end
axis image;axis off;
set(gcf,'Color','white');
drawnow;
view(-17,46);

