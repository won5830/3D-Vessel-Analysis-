function node_info_final=DiameterCalculation(stack, node_info, w, l, h, node, link, bifur_node) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% INPUT:
% stack = logical 3d matrix of stacked images
% node_info = node info structure where calculated values will be inserted
% w = width of skeleton
% l = length of skeleton
% h = height of skeleton
% node = skeleton node structure
% link = skeleton link structure
% bifur_node = list of Bifurcation Node indexes
%
% This function searches through the given list of nodes (bifur_node)
% and calculate diameter of each branch of give node.
% In addition, it also gives the information of extracted point, blob, and
% instant gradient vector of the extracted point
% After calculation, values are inserted to info structure 
%
% OUTPUT: node information structure filled with calculated values 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Take out points with 1 of the given 3d matrix 
[x_one,y_one,z_one]=ind2sub([w,l,h],find(stack(:)));

for dia_ind=1:length(bifur_node) %Loop for each bifurcation node
    %point where diameter is extracted
    extract=8; %this should be changed later 
    
    temp_link=node(bifur_node(dia_ind)).links;
    
    %temporary information reservoir (transfer to info structure) 
    temp_point=cell(length(temp_link),1);
    temp_diameter=cell(length(temp_link),1);
    temp_blob=cell(length(temp_link),1);
    temp_grad=cell(length(temp_link),1);
    
    for i=1:length(temp_link) %Loop for each link
    % link diameter extraction
        if link(temp_link(i)).n1==bifur_node(dia_ind)
            points=link(temp_link(i)).point;
        else
            points=flip(link(temp_link(i)).point);
        end
    
        %points(extract)
        [px,py,pz]=ind2sub([w,l,h],points(extract));
        pt=[px,py,pz];
        %gradient vector using 1 step before
        %make gradient vector using 5 points in total
        [reg_x, reg_y, reg_z]=ind2sub([w,l,h],points(extract-2:extract+2));
        ne=Regression3D([reg_x; reg_y; reg_z],1);
        inst_vec=(ne(:,1)-ne(:,2))/norm(ne(:,1)-ne(:,2));
        
        %Insert points near the plane in the store matrix
        store=zeros(size(stack,1)*size(stack,2)*size(stack,3),3);
        for j=1:length(x_one) 
            if PlaneDist(pt,inst_vec, x_one(j),y_one(j),z_one(j)) < 0.45
                %number 1.5 should also be calibrated
                store(j,:)=[x_one(j), y_one(j), z_one(j)]; 
            end
        end
        store=store(any(store,2),:);
        
        %Among the points in store, save points near the extract point
        store2=zeros(size(store,1),3);
        for k=1:size(store,1)
            if abs((store(k,1)-px)^2+(store(k,2)-py)^2+(store(k,3)-pz)^2)< round(length(stack)/2)
                %number 7 should be further modified
                store2(k,:)=[store(k,1), store(k,2), store(k,3)];
            end
        end
        store2=store2(any(store2,2),:); 
        
        temp_null=zeros(size(stack,1),size(stack,2),size(stack,3));
        for ind=1:size(store2, 1)
            temp_null(store2(ind,1),store2(ind,2),store2(ind,3))=1;
        end
        
        %Take out the blob near the extracted point
        connectivity=bwconncomp(temp_null);
        for ind=1:length(connectivity.PixelIdxList)
            if ismember(points(extract), connectivity.PixelIdxList{1,ind})
                blob=connectivity.PixelIdxList{1,ind};
            end
        end
        [xxx,yyy,zzz]=ind2sub([w,l,h],blob);
        final=[xxx,yyy,zzz];
        projected=final-dot(final-repmat([px,py,pz],length(final),1), repmat(inst_vec.',length(final),1),2).*repmat(inst_vec.',length(final),1);
        
%         if rem(dia_ind,10)==0
%             figure()
%             plot3(xxx,yyy,zzz,'*r')
%             hold on 
%             plot3(px,py,pz, '*b')
%             plot3(projected(:,1),projected(:,2),projected(:,3),'*c')
%         end
        
        %Area calculation by projecting to lower dimension 
        [U,S]=svd(bsxfun(@minus,projected,mean(projected)), 0);  
        [~,area]=convhull(U*S(:,1:2));
        
        temp_point{i,1}=pt;
        temp_diameter{i,1}=sqrt(4/pi*area);
        temp_blob{i,1}=projected;
        temp_grad{i,1}=inst_vec;
    end
    
    %information allocation
    node_info(dia_ind).branch1_diameter_point=temp_point{1,1};
    node_info(dia_ind).branch1_diameter_grad=temp_grad{1,1};
    node_info(dia_ind).branch1_diameter_blob=temp_blob{1,1};
    node_info(dia_ind).branch1_diameter=temp_diameter{1,1};
    
    node_info(dia_ind).branch2_diameter_point=temp_point{2,1};
    node_info(dia_ind).branch2_diameter_grad=temp_grad{2,1};
    node_info(dia_ind).branch2_diameter_blob=temp_blob{2,1};
    node_info(dia_ind).branch2_diameter=temp_diameter{2,1};
    
    node_info(dia_ind).branch3_diameter_point=temp_point{3,1};
    node_info(dia_ind).branch3_diameter_grad=temp_grad{3,1};
    node_info(dia_ind).branch3_diameter_blob=temp_blob{3,1};
    node_info(dia_ind).branch3_diameter=temp_diameter{3,1};
end
node_info_final=node_info;

function dist=PlaneDist(pt,norm,x,y,z)
    denom=sqrt(norm(1)^2+norm(2)^2+norm(3)^2);
    numer=abs(norm(1)*(x-pt(1))+norm(2)*(y-pt(2))+norm(3)*(z-pt(3)));
    dist=numer/denom;
end

end



