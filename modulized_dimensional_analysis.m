                                                                                                                                                                                                                                                                           clear all 
close all 
clc 

%% PREREQUISITE INPUT

% Length ratio between xy pixel and z pixel  
xy_z_ratio=3;
% To form realistic structure, image stack will be elongated to match the
% x-y-z length ratio as 1:1:1.
% input =(z pixel distance) / (xy pixel distance)
% WARNING: The input must be in integer form!! 

% Prune the branches of raw skeleton 
pruning_length=50;
% branches of skeletons which contain less than x number of pixels will be
% pruned 

% Condition for searching bifurcation node
bifur_link_condition=20;
% Only nodes with all links longer than x pixels will be chosen as
% bifurcation node

% Number of pixels for calculating gradient vector
num_pixel_grad_vec=5;
% Gradient vector of each bifurcated link will be calculated based on
% inputted number. The number counting starts from bifurcation node

% Condition for searching investigated link 
link_search_condition=20;
% Only links longer than x pixels will be chosen and investigated 

%VolumeViewer

%% IMAGE STACK 
%입력 - 경로(바이너리 이미지), 비율
%출력 - 이미지 3차원 배열
path='C:\Users\YOON\Downloads\Binary4_crop\';
%making 3d matrix of stacked images
stack=BinImageBuild(path, xy_z_ratio);
disp('stack done');

%% SKELETONIZATION
%3d skeletonization
skel = bwskel(stack); %내장함수 스켈
w=size(skel,1); %이후의 계산을 위해 w,l,h를 별도로 저장할 것 !!!
l=size(skel,2); %
h=size(skel,3); %
disp('skel done');

%%%%%
gpustack = gpuArray(stack);

%3D plotting 
figure('Name','Inner function Skeleton');
col=[.9 .9 .9];
hiso = patch(isosurface(gpustack,0),'FaceColor',col,'EdgeColor','none');
hiso2 = patch(isocaps(gpustack,0),'FaceColor',col,'EdgeColor','none'); %빼도됨
axis equal; axis off;
lighting phong;
isonormals(gpustack,hiso); %빼도됨
alpha(0.5);
set(gca,'DataAspectRatio',[1 1 1])
camlight;
hold on;
[x,y,z]=ind2sub([w,l,h],find(skel(:)));
plot3(y,x,z,'square','Markersize',1,'MarkerFaceColor','r','Color','r');            
set(gcf,'Color','white');
view(140,80)
disp('plot done');

%% SKELETON PRUNING
%입력 - skel, 자를 기준 길이
%출력 - 정리한 skel, 정리한 노드, 정리한 링크, 
[skel2, node2,link2]=SkeletonPruning(skel,pruning_length);

% display result
figure('Name','Pruned Graph');
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

% Pruned Skeleton
figure('Name','Pruned Skeleton');
col=[.9 .9 .9];
hiso = patch(isosurface(stack,0),'FaceColor',col,'EdgeColor','none');
hiso2 = patch(isocaps(stack,0),'FaceColor',col,'EdgeColor','none');
axis equal; axis off;
lighting phong;
%isonormals(stack,hiso);
alpha(0.5);
set(gca,'DataAspectRatio',[1 1 1])
camlight;
hold on;
[x,y,z]=ind2sub([w,l,h],find(skel2(:)));
plot3(y,x,z,'square','Markersize',1,'MarkerFaceColor','r','Color','r');            
set(gcf,'Color','white');
view(140,80)

%% BIFURCATION POINT SEARCH 
%입력 - 정리한 노드, 정리한 링크, 찾는 노드의 조건(노드에 연결된 링크의 최소 길이)
%출력 - 조건 충족 노드 인덱스
bifur_node=BifurNodeSearch(node2,link2, bifur_link_condition);

%% 3D NODE INFORMATION STRUCTURE CREATION 
%입력 - 인덱스, x, y, z
node_info_3d=struct('bifurcation_index',cell(length(bifur_node),1),'comx',cell(length(bifur_node),1),'comy',cell(length(bifur_node),1), 'comz',cell(length(bifur_node),1),...
'branch1_points',cell(length(bifur_node),1),'branch1_gradient',cell(length(bifur_node),1),'branch1_diameter',cell(length(bifur_node),1),'branch1_gradient_rmse',cell(length(bifur_node),1),'branch1_diameter_merror',cell(length(bifur_node),1),'branch1_diameter_point',cell(length(bifur_node),1),'branch1_diameter_grad',cell(length(bifur_node),1),'branch1_diameter_blob',cell(length(bifur_node),1),...
'branch2_points', cell(length(bifur_node),1),'branch2_gradient',cell(length(bifur_node),1),'branch2_diameter',cell(length(bifur_node),1), 'branch2_gradient_rmse',cell(length(bifur_node),1),'branch2_diameter_merror',cell(length(bifur_node),1),'branch2_diameter_point',cell(length(bifur_node),1),'branch2_diameter_grad',cell(length(bifur_node),1),'branch2_diameter_blob',cell(length(bifur_node),1),...
'branch3_points', cell(length(bifur_node),1),'branch3_gradient',cell(length(bifur_node),1),'branch3_diameter',cell(length(bifur_node),1), 'branch3_gradient_rmse',cell(length(bifur_node),1),'branch3_diameter_merror',cell(length(bifur_node),1), 'branch3_diameter_point',cell(length(bifur_node),1),'branch3_diameter_grad',cell(length(bifur_node),1),'branch3_diameter_blob',cell(length(bifur_node),1));

%% BIFURCATION ANGLE CALCULATION 
%Gradient 채워줌
node_info_3d=BifurAngleCal(node_info_3d,w, l, h, node2,link2, bifur_node, num_pixel_grad_vec);

%% BIFURCATION DIAMETER CALCULATION
% 직경 채워줌
node_info_final=DiameterCalculation(stack, node_info_3d, w, l, h, node2, link2, bifur_node);

%% SPECIFIC LINK SEARCH 
%입력 - 정리된 링크, 길이
%출력 - 조건 충족 링크 인덱스
specific_link=LinkSearch(link2, link_search_condition);

%% 3D LINK INFORMATION STRUCTURE CREATION 
%struct 만들기
%인덱스, 시작점, 끝점, 구성 점 인덱스, 길이, 구불구불한 정도
link_info=struct('link_index',cell(length(specific_link),1),'start',cell(length(specific_link),1),'end',cell(length(specific_link),1), 'points',cell(length(specific_link),1),...
'length',cell(length(specific_link),1),'tortuosity',cell(length(specific_link),1));

%% LINK INFORMATION INSERTION
%채우기
link_info=LinkCalculation(link_info, w,l,h, node2,link2, specific_link);
