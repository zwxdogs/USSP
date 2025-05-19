function delay = pw_rca_delay(T_x_ele, T_y_ele, is_RC, angle, c)
    % 用于计算平面波发射的时间延迟
    if is_RC
        delay = (T_x_ele * sin(angle)) / c;
    else
        delay = (T_y_ele * sin(angle)) / c;
    end
    % delay = delay - min(delay(:));
end

