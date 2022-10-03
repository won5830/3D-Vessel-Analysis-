function logic_image_stack=Bin_image_build(path,pix_ratio) 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% WARNING: images should be ordered strictly!! including the digits!!
% OUTPUT: Bin_image_build(route of image files, pixel ratio)
% pixel ratio means overall length ratio between xy pixel and z pixel 
% pixel ratio should be integer, you should round your number to
% skeletonize the target image 
% OUTPUT: logical 3d matrix of stacked images 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

assert(~logical(rem(pix_ratio,1)),'Pixel Ratio should be integer number')
temp=dir(strcat(path,'*jpg'));
temp_size=size(imread(strcat(path,temp(1).name)));
image_num=length(temp);
temp1=zeros(temp_size(1),temp_size(2),image_num);
temp2=zeros(temp_size(1),temp_size(2),image_num*pix_ratio); 

for i=1:image_num
    t_image=imread(strcat(path,temp(i).name));
    tt_image=imbinarize(t_image);
    temp1(:,:,i)=t_image(:,:,1);  %double
    for j=1:pix_ratio
        temp2(:,:,pix_ratio*(i-1)+j)=tt_image(:,:,1); 
    end
end
logic_image_stack=logical(temp2);
end 





