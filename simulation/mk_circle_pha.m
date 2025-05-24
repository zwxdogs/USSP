function pha = mk_circle_pha(N_pha, radius, center, v_l, N_frame, global_para)
% 制作圆形流动仿体

rng('default')
% 散点坐标范围
angle_range = deg2rad(360);
x_c = center(1);
y_c = center(2);
z_c = center(3);

r = radius * rand(1, N_pha);
angle = angle_range * rand(1, N_pha);
% 初始坐标
x = r .* cos(angle) + x_c;
y = zeros(1, length(x)) + y_c;
z = r .* sin(angle) + z_c;
% 散点速度
omega = v_l ./ r;
% 散点反射强度
amp = ones(N_pha, 1);

pha = cell(N_frame, 1);
Tprf = 1 / global_para.PRF;
for i = 1:N_frame
    pha{i} = phantom();
    positions = [x; y; z;]';
    pha{i} = pha{i}.pha_pos(positions, amp);

    angle = angle - omega * Tprf;
    x = r .* cos(angle);
    z = r .* sin(angle) + z_c;
end

end

