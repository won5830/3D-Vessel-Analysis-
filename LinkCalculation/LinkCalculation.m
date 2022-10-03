function link_info=LinkCalculation(link_info, w,l,h,node,link, specific_link) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% INPUT:
% link_info = information structure of links where calculated values will
% be inserted
% w,l,h = size of binary 3d matrix of stacked images
% node= information structure of node
% link = skeleton link structure
% specific_link=list of indexes of investigated link
%
% This function calculate the information of given node (length, tortuosity and etcetera)
% and returns the final information structure about link by inserting
% calculated values to designated cell. 
%
% OUTPUT: structure with link information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i=1:length(specific_link)
    temp_link_ind=specific_link(i);
    temp_start=[node(link(temp_link_ind).n1).comx, node(link(temp_link_ind).n1).comy, node(link(temp_link_ind).n1).comz];
    temp_end=[node(link(temp_link_ind).n2).comx, node(link(temp_link_ind).n2).comy, node(link(temp_link_ind).n2).comz];
    [x_temp,y_temp,z_temp]=ind2sub([w,l,h],link(temp_link_ind).point);
    temp_points=[x_temp.',y_temp.',z_temp.'];
    [temp_length, temp_displacement]=CurveLength(x_temp,y_temp,z_temp);
    temp_tortuosity=temp_length/temp_displacement*100;
    %information allocation 
    link_info(i).link_index=temp_link_ind;
    link_info(i).start=temp_start;
    link_info(i).end=temp_end;
    link_info(i).points=temp_points;
    link_info(i).length=temp_length;
    link_info(i).tortuosity=temp_tortuosity;

end

function [len,dist_end_start]=CurveLength(x,y,z)
    dx=abs(diff(x));
    dy=abs(diff(y));
    dz=abs(diff(z));
    len = sum(sqrt(dx.^2 + dy.^2+dz.^2));
    dist_end_start=sqrt((x(1)-x(end))^2+(y(1)-y(end))^2+(z(1)-z(end))^2);
end

end
