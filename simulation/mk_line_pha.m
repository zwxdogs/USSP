function pha = mk_line_pha(N_pha, v_l, N_frame, global_para)
% 制作圆形流动仿体

rng('default')
% 初始坐标 - 右
x_right = 20e-3 * rand(1, N_pha/2) - 10e-3;
y_right = zeros(1, length(x_right));
z_right = 10e-3 * rand(1, N_pha/2) + 10e-3;
% 初始坐标 - 左
x_left = 20e-3 * rand(1, N_pha/2) - 10e-3;
y_left = zeros(1, length(x_left));
z_left = 10e-3 * rand(1, N_pha/2) + 20e-3;
% 散点反射强度
amp = ones(N_pha, 1);

pha = cell(N_frame, 1);
Tprf = 1 / global_para.PRF;
for i = 1:N_frame
    pha{i} = phantom();
    positions = [x_right', y_right', z_right';x_left', y_left', z_left'];
    pha{i} = pha{i}.pha_pos(positions, amp);

    % z = z + v_l * Tprf;
    x_right = x_right + v_l * Tprf;
    x_left = x_left - v_l * Tprf;
end

end
