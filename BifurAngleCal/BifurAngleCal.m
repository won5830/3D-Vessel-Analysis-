function Angle=BifurAngleCal(node_info_3d,w, l, h, node,link, bifur_node,thr_bifur) 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% INPUT:
% node_info_3d = information structure where calculated values are inserted
% w = width of skeleton
% l = length of skeleton
% h = height of skeleton
% node = skeleton node structure
% link = skeleton link structure
% bifur_node = list of Bifurcation Node indexes
% thr_bifur = Number of pixel for branch angle calculation (or threshold) 
%
% This function searches through the given list of nodes (bifur_node)
% and calculate gradient vector of each branch of give node.
% After calculation, values are inserted to info structure 
%
% OUTPUT: node information structure filled with calculated values 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%3D linear regression using pseudo-inverse 
for angle_ind=1:length(bifur_node) 
% For Given angle_ind calculate bifurcation angle... the small one and big one..
bx=node(bifur_node(angle_ind)).comx;
by=node(bifur_node(angle_ind)).comy;
bz=node(bifur_node(angle_ind)).comz;

temp_link=node(bifur_node(angle_ind)).links;
t_link1=temp_link(1); % link number 
t_link2=temp_link(2);
t_link3=temp_link(3);

[x1,y1,z1]=ind2sub([w,l,h],link(t_link1).point);
[x2,y2,z2]=ind2sub([w,l,h],link(t_link2).point);
[x3,y3,z3]=ind2sub([w,l,h],link(t_link3).point); %branching link allocation 
x1_f=flip(x1); x2_f=flip(x2); x3_f=flip(x3);
y1_f=flip(y1); y2_f=flip(y2); y3_f=flip(y3);
z1_f=flip(z1); z2_f=flip(z2); z3_f=flip(z3);
XYZ={x1,y1,z1; x2,y2,z2; x3,y3,z3};
XYZ_f={x1_f,y1_f,z1_f; x2_f,y2_f,z2_f; x3_f,y3_f,z3_f};

%Starting point search 

temp_branch=cell(3,3);
%figure('Name','Branching Angle Search') 
for j=1:3
    if (link(temp_link(j)).n1==bifur_node(angle_ind))
    %if norm(abs(front(j,:)-standard.'))<norm(abs(back(j,:)-standard.'))
        temp_branch{j,1}=XYZ{j,1}(1:thr_bifur); temp_branch{j,2}=XYZ{j,2}(1:thr_bifur); temp_branch{j,3}=XYZ{j,3}(1:thr_bifur);
    else
        temp_branch{j,1}=XYZ_f{j,1}(1:thr_bifur); temp_branch{j,2}=XYZ_f{j,2}(1:thr_bifur); temp_branch{j,3}=XYZ_f{j,3}(1:thr_bifur);
    end
end

%3D linear regression
branch1=[temp_branch{1,1}; temp_branch{1,2}; temp_branch{1,3}];
branch2=[temp_branch{2,1}; temp_branch{2,2}; temp_branch{2,3}];
branch3=[temp_branch{3,1}; temp_branch{3,2}; temp_branch{3,3}];

branch1_lin=Regression3D(branch1,2);
branch2_lin=Regression3D(branch2,2);
branch3_lin=Regression3D(branch3,2);

%Rsquare & gradient allocation
grad1=branch1_lin(:,1)-branch1_lin(:,2); grad1=grad1/norm(grad1);
grad2=branch2_lin(:,1)-branch2_lin(:,2); grad2=grad2/norm(grad2);
grad3=branch3_lin(:,1)-branch3_lin(:,2); grad3=grad3/norm(grad3);
[~, rmse1]=rsquare(branch1,branch1_lin);
[~, rmse2]=rsquare(branch2,branch2_lin);
[~, rmse3]=rsquare(branch3,branch3_lin);

%Information allocation
node_info_3d(angle_ind).bifurcation_index=bifur_node(angle_ind);
node_info_3d(angle_ind).comx=node(bifur_node(angle_ind)).comx;
node_info_3d(angle_ind).comy=node(bifur_node(angle_ind)).comy;
node_info_3d(angle_ind).comz=node(bifur_node(angle_ind)).comz;

%Point allocation 
node_info_3d(angle_ind).branch1_points=[temp_branch{1,1}; temp_branch{1,2}; temp_branch{1,3}]; 
node_info_3d(angle_ind).branch2_points=[temp_branch{2,1}; temp_branch{2,2}; temp_branch{2,3}]; 
node_info_3d(angle_ind).branch3_points=[temp_branch{3,1}; temp_branch{3,2}; temp_branch{3,3}]; 

node_info_3d(angle_ind).branch1_gradient=grad1; 
node_info_3d(angle_ind).branch2_gradient=grad2; 
node_info_3d(angle_ind).branch3_gradient=grad3; 

node_info_3d(angle_ind).branch1_gradient_rmse=rmse1; 
node_info_3d(angle_ind).branch2_gradient_rmse=rmse2; 
node_info_3d(angle_ind).branch3_gradient_rmse=rmse3; 
end 
Angle=node_info_3d;
end 
