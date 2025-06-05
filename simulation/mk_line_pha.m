function pha = mk_line_pha(N_pha, v_l, N_frame, global_para, wave)
% 制作直线流动仿体

rng('default')
x_ori = -10e-3;
z_ori = 30e-3;
max_d = sqrt(20e-3^2+20e-3^2);
% 初始坐标
d = max_d * rand(1, N_pha);
x = x_ori + d * cosd(45) + 3e-3 * (-1 + 2 * rand(1, N_pha));
y = zeros(1, length(x));
z = z_ori - d * sind(45) + 3e-3 * (-1 + 2 * rand(1, N_pha));
% 散点反射强度
amp = ones(N_pha, 1);

pha = cell(N_frame, 1);
PRF_eff = global_para.PRF / (wave.N_theta * 2);
Tprf = 1 / PRF_eff;
for i = 1:N_frame
    pha{i} = phantom();
    positions = [x', y', z'];
    pha{i} = pha{i}.pha_pos(positions, amp);

    z = z - v_l * sind(45) * Tprf;
    x = x + v_l * cosd(45) * Tprf;
end

end
