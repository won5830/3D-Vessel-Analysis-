function specific_link=LinkSearch(link, threshold) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% INPUT:
% link = skeleton link structure
% threshold = find the links which have more pixels than threshold
%
% This function searches through all the links and returns the list of link
% index that satisfy the give condition (have more points than given threshold)
%
% OUTPUT: list of link index
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
temp=zeros(length(link),1);
for i=1:length(link)
    if length(link(i).point) >= threshold
        temp(i)=i;
    end
end
specific_link=nonzeros(temp);
end
