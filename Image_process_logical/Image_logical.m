function return_value=Image_logical(logic_image,x_val,y_val)
    xlim=size(logic_image,1);
    ylim=size(logic_image,2);
    if ~(1 <= x_val && x_val<=xlim) || ~(1 <= y_val && y_val<=ylim)
        return_value=0; %둘중 하나라도 밖에 있으면 0을 return 
    else
        return_value=logic_image(x_val,y_val);
    end
end 