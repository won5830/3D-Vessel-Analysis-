 
function linear_regression=Regression3D(arr,type)
if isempty(type)  %default value set 
    type = 1;
end

if type==1 %Regression using mean point of given datas 
    arr0 = mean(arr,2); %arr= 3*n size of matrix filled with points 
    A = arr-arr0;
    [U,S,~] = svd(A);
    d = U(:,1);
    t = d'*A;
    arr_lin = arr0 + t.*d; % size 3xn / regressed matrix corresponding to original datas
    linear_regression=arr_lin; %return start point and end point in one matrix
elseif type==2
    arr0 = arr(:,1); %arr= 3*n size of matrix filled with points 
    A = arr-arr0;
    [U,S,~] = svd(A);
    d = U(:,1);
    t = d'*A;
    arr_lin = arr0 + t.*d; % size 3xn / regressed matrix corresponding to original datas
    linear_regression=arr_lin; %return start point and end point in one matrix

end

end 