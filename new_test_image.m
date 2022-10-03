clear all 
close all 
clc 

%% Image Stack 
temp1=zeros(1024,1024,116);
temp2=zeros(1024,1024,116*2);

for i=21:116
    path='D:\Study\MBEL\VMTK\Binary2\';
    name=strcat(int2str(i-1),'.jpg');
    t_image=imread(strcat(path,name));
    tt_image=imbinarize(t_image);
    temp1(:,:,i)=t_image(:,:,1);  %double
    
    temp2(:,:,2*(i-1)+1)=tt_image(:,:,1); %logical
    temp2(:,:,2*i)=tt_image(:,:,1); %logical
end
temp2_logic=logical(temp2);

%volumeViewer(temp1)

%% Skeletonization 

skel = Skeleton3D(temp2_logic);

figure('Name','Original Skeleton');
col=[.9 .9 .9];
hiso = patch(isosurface(temp2_logic,0),'FaceColor',col,'EdgeColor','none');
hiso2 = patch(isocaps(temp2_logic,0),'FaceColor',col,'EdgeColor','none');
axis equal; axis off;
lighting phong;
isonormals(temp2_logic,hiso);
alpha(0.5);
set(gca,'DataAspectRatio',[1 1 1])
camlight;
hold on;
w=size(skel,1);
l=size(skel,2);
h=size(skel,3);
[x,y,z]=ind2sub([w,l,h],find(skel(:)));
plot3(y,x,z,'square','Markersize',1,'MarkerFaceColor','r','Color','r');            
set(gcf,'Color','white');
view(140,80)
disp('skel showed')
%% Pruning & Graph 

% initial step: condense, convert to voxels and back, detect cells
[~,node,link] = Skel2Graph3D(skel,0);
%THM은 pixel단위로 prune

% total length of network
wl = sum(cellfun('length',{node.links}));
%각 노드 별로 링크들의 갯수를 length로 구한뒤에 다 더한것 같다. 
%cellfun(함수, cell struct) 의 형식인데 string형태로 함수를 적용해줄 수 있다 : length는 cell의 길이
%계산 

% PRUNING CONTROL %
skel2 = Graph2Skel3D(node,link,w,l,h); %pruning된 그래프를 이용하여 다시 skeletalize
[~,node2,link2] = Skel2Graph3D(skel2,50);

% calculate new total length of network 
wl_new = sum(cellfun('length',{node2.links})); %한번 prune된 거의 각 node에 연결된 link들의 수를 합한거 

% iterate the same steps until network length changed by less than 0.5%
%지금은 아예 reduction이 0이니까 while 구문이 안돌아가지 
while(wl_new~=wl) %~= : not equal... , 0.5%이상 바뀌지 않는 동안...,

    wl = wl_new;   
    
     skel2 = Graph2Skel3D(node2,link2,w,l,h);
     [A2,node2,link2] = Skel2Graph3D(skel2,50);

     wl_new = sum(cellfun('length',{node2.links}));

end
disp('Pruning Done')

% display result
figure('Name','Pruned Graph');
hold on;
% for i=1:length(node2)
%     %노드들 그리기
%     x1 = node2(i).comx;
%     y1 = node2(i).comy;
%     z1 = node2(i).comz;
%     
%     if(node2(i).ep==1)
%         ncol = 'c'; %끝점이면 cyan 색으로 표시
%     else
%         ncol = 'y'; %중간노드면 노란색으로 !
%     end
%     
%     %노드간 connection그리기 
%     for j=1:length(node2(i).links)    % draw all connections of each node, 각 노드에 부착된 링크들을 j로 받아서 하나씩
%         if(node2(node2(i).conn(j)).ep==1) %만일 해당 링크가 endpoint에 연결돼있다? 
%             col='k'; % branches are black
%         else %만일 해당 노드가 end point가 아니다!
%             col='r'; % links are red
%         end
%         if(node2(i).ep==1) %만약에 i로 받아지는 노드 자체가 ep면 중간점으로 가더라도 black이니까 
%             col='k';
%         end
% 
%         
%         % draw edges as lines using voxel positions
%         %ind2sub은 특정 숫자가 해당 행렬의 몇행 몇열에 있는지를 보는거야 
%         for k=1:length(link2(node2(i).links(j)).point)-1  %각 link를 구성하는 voxel 꺼내주기
%             %1을 빼주는 것은 어차피 선을 그리는 거니까... 그래서 k랑 k+1인거지
%             %각 링크의 point정보를 접속해서 point의 index를 subscript로 바꿔주는 것 
%             [x3,y3,z3]=ind2sub([w,l,h],link2(node2(i).links(j)).point(k)); %[w,l,h]는 행렬 크기 
%             [x2,y2,z2]=ind2sub([w,l,h],link2(node2(i).links(j)).point(k+1)); %link2는 숫자에 해당하는거지 
%             line([y3 y2],[x3 x2],[z3 z2],'Color',col,'LineWidth',2);
%         end
%     end
%     
%     % draw all nodes as yellow circles
%     plot3(y1,x1,z1,'o','Markersize',9,...
%         'MarkerFaceColor',ncol,...
%         'Color','k');
% end
axis image;axis off;
set(gcf,'Color','white');
drawnow;
view(-17,46);
disp('graph drawn')
%% Pruned Skeleton
figure('Name','Pruned Skeleton');
col=[.9 .9 .9];
hiso = patch(isosurface(temp2_logic,0),'FaceColor',col,'EdgeColor','none');
hiso2 = patch(isocaps(temp2_logic,0),'FaceColor',col,'EdgeColor','none');
axis equal; axis off;
lighting phong;
isonormals(temp2_logic,hiso);
alpha(0.5);
set(gca,'DataAspectRatio',[1 1 1])
camlight;
hold on;
[x,y,z]=ind2sub([w,l,h],find(skel2(:)));
plot3(y,x,z,'square','Markersize',1,'MarkerFaceColor','r','Color','r');            
set(gcf,'Color','white');
view(140,80)

disp('final showed')