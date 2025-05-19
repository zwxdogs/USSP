function delay = dw_rca_delay(T_x_ele, T_y_ele, source, c)

% 用于计算平面波发射的时间延迟
element = [T_x_ele, T_y_ele, zeros(length(T_x_ele), 1)];
delay = zeros(1, length(T_x_ele));

for i = 1:length(T_x_ele)
    distance = norm(element(i, :)-source, 2);
    delay(i) = distance / c;
end
delay = delay - min(delay(:));

end
