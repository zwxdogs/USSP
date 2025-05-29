function distance = p2l_rca(point, line_p_min, line_p_max)
% rca计算点到线段的距离，需要提供点的坐标和线的矢量、线段两端的坐标

% 计算源线长度
length_line = norm(line_p_max(1, :)-line_p_min(1, :));
% 计算投影
point_mat = repmat(point, size(line_p_min, 1), 1);
proj = dot(point_mat-line_p_min, line_p_max-line_p_min, 2) / length_line;
proj_norm = proj / length_line;

distance = zeros(length(proj_norm), 1);
for i = 1:length(proj_norm)
    if proj_norm(i) < 0
        distance(i) = norm(point_mat(i, :)-line_p_min(i, :));
    elseif proj_norm(i) > 1
        distance(i) = norm(point_mat(i, :)-line_p_max(i, :));
    else
        distance(i) = norm(cross(line_p_max(i, :)-line_p_min(i, :), point_mat(i, :)-line_p_min(i, :))) ./ ...
            norm(line_p_max(i, :)-line_p_min(i, :));
    end
end

distance = distance';
end
