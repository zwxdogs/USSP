clear;clc;close all;

para = global_para(100e6, 1500, 1.45e6, 40e3);
% 探头
rca = rca_array(para, 64, 0.3e-3, 0.03e-3, 6e6);
rca.bw = 0.6;
% 波角度
wave = rca_pw(-7.5, 7.5, 15);
V_N = para.PRF/(wave.N_theta*2) * para.c0 / (4 * rca.f0);
%% 流动散射体
N_pha = 2000;
v_l = 0.01;
N_frame = 8;
x_positions = 100;
x_min = -10e-3;
x_max = 10e-3;
z_move = 20e-3;
angle_flow = 20;
radius = 0.5e-3;
% 制作二维直线流动仿体
rng('default');
% 确定多少个x位置
x_c = linspace(x_min, x_max, x_positions);
z_c = (x_c + x_max) * sind(angle_flow) + z_move;
N_xp = N_pha / x_positions;
x_all = zeros(N_pha, 1);
y_all = zeros(N_pha, 1);
z_all = zeros(N_pha, 1);
index = 1;
for n = 1:length(x_c)
    r = radius * (rand(1, N_xp)*2 - 1);
    x_this = x_c(n);
    z_this = r + z_c(n);
    x_all(index:index+N_xp-1) = x_this;
    z_all(index:index+N_xp-1) = z_this;
    index = index + N_xp;
end
% 散点反射强度
amp = ones(N_pha, 1);
% 定义散射体
pha = cell(N_frame, 1);
PRF_eff = para.PRF / (wave.N_theta * 2);
Tprf = 1 / PRF_eff;
for i = 1:N_frame
    pha{i} = phantom();
    positions = [x_all, y_all, z_all];
    pha{i} = pha{i}.pha_pos(positions, amp);

    z_all = z_all + v_l * sind(20) * Tprf;
    x_all = x_all + v_l * cosd(20) * Tprf;
end
% figure_1 = figure(1);
% pha{1}.plot_pha(figure_1);
%% 
% 扫描区域
sca = linear_3d_scan(linspace(x_min, x_max, 200), linspace(10e-3, 30e-3, 200), 0);
% 模拟和波束成形
velocity_data = rca.calc_velocity(para, wave, pha, sca, 1, [1, 1], -30);
% 自相关算法
lag = 1;
M = [1, 1];
velocity_doppler = auto_corr_rca(rca, velocity_data.UVD_blocks, N_frame, para, sca, wave, lag, M);
% 最小二乘法
V_data = least_squares_us(velocity_doppler, wave, sca);
%% 几何掩码
geo_mask = zeros(sca.ori_shape);
geo_x = reshape(sca.scan_x, sca.ori_shape);
geo_z = reshape(sca.scan_z, sca.ori_shape);
x_c_sca = geo_x(1, :);
z_c_sca_value = (x_c_sca + x_max) * sind(angle_flow) + z_move;
for i = 1:size(geo_x, 2)
   [~, z_c_sca_index] = min(abs(geo_z(:, i) - z_c_sca_value(i)));
   z_c_sca = geo_z(z_c_sca_index, i);
   for j = 1:size(geo_z, 1)
       if(abs(geo_z(j, i) - z_c_sca) <= radius)
           geo_mask(j, i) = 1;
       end
   end
end
V_data_geo_mask = V_data;
V_data_geo_mask.RC(:, :, 1) = V_data_geo_mask.RC(:, :, 1) .* geo_mask;
V_data_geo_mask.RC(:, :, 2) = V_data_geo_mask.RC(:, :, 2) .* geo_mask;
%%
% 绘制
min_p_db = -50;
figure_1 = figure(1);
sca.plot_velocity(figure_1, V_data_geo_mask, velocity_data.P_db, min_p_db, 3, 2, cool);
% 数据测试
data_test = test_data(V_data_geo_mask, velocity_data.P_db, min_p_db, sca, v_l*sind(angle_flow), v_l*cosd(angle_flow), v_l);
% 保存数据
file = "line20Down"+ num2str(rca.N_RC) + "_" + num2str(wave.N_theta) + "A_" + num2str(size(pha, 1)) + "F_PRF" + num2str(para.PRF/1000) + ".mat";
file = "data\" + file;
save(file, "para", "pha", "rca", "sca", "V_N", "velocity_data", "V_data", "V_data_geo_mask", "wave", "data_test");