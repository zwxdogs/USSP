function distance = p2l_rca(point, line_p_min, line_p_max)

% 计算点到线段的距离，需要提供点的坐标和线的矢量、线段两端的坐标
proj = dot(point-line_p_min, line_p_max-line_p_min) / ...
    norm(line_p_max-line_p_min);
proj_norm = proj / norm(line_p_max-line_p_min);

if proj_norm < 0
    distance = norm(point - line_p_min);
elseif proj_norm > 1
    distance = norm(point - line_p_max);
else
    distance = norm(cross(line_p_max-line_p_min, point-line_p_min)) / ...
        norm(line_p_max-line_p_min);
end

end
