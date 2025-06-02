clear;clc;close all;

para = global_para(100e6, 1500, 1.45e6, 3e3);
% 探头
rca = rca_array(para, 128, 0.3e-3, 0.03e-3, 5e6);
rca.bw = 0.6;
% 流动散射体
pha = mk_line_pha(500, 0.1, 8, para);
% figure_1 = figure(1);
% pha{1}.plot_pha(figure_1);
% 波角度
wave = rca_pw(-5, 5, 11);
% 扫描区域
sca = linear_3d_scan(linspace(-10e-3, 10e-3, 200), linspace(0e-3, 40e-3, 200), 0);
% sca = linear_xy_scan(linspace(-10e-3, 10e-3, 600), linspace(-10e-3, 10e-3, 600), 15e-3);
% 模拟
velocity_data = rca.calc_velocity(para, wave, pha, sca, 1, [1, 1], -30);
% 绘制
% figure_1 = figure(1);

sample = 10;
[lateral, axial] = meshgrid(sca.lateral_grid(1:sample:end), sca.axial_grid(1:sample:end));
subplot(121);
plot_quiver(lateral*1000, axial*1000, velocity_data.V_data_mbp.v_x((1:sample:end), (1:sample:end)), ...
    velocity_data.V_data_mbp.v_z_RC((1:sample:end), (1:sample:end)));
% quiver(lateral*1000, axial*1000, velocity_data.V_data.RC((1:sample:end), (1:sample:end), 2), ...
%     velocity_data.V_data.RC((1:sample:end), (1:sample:end), 1), 2)
% axis equal ij tight
% xlabel('lateral (mm)');
% ylabel('depth (mm)');
subplot(122);
plot_quiver(lateral*1000, axial*1000, velocity_data.V_data_mbp.v_y((1:sample:end), (1:sample:end)), ...
    velocity_data.V_data_mbp.v_z_CR((1:sample:end), (1:sample:end)));
% quiver(lateral*1000, axial*1000, velocity_data.V_data.CR((1:sample:end), (1:sample:end), 2), ...
%     velocity_data.V_data.CR((1:sample:end), (1:sample:end), 1), 2)
% axis equal ij tight
% xlabel('lateral (mm)');
% ylabel('depth (mm)');

A = velocity_data.velocity_doppler.RC(:, :, 1);
B = velocity_data.velocity_doppler.CR(:, :, 1);
C = velocity_data.V_data.RC(:, :, 1);
D = velocity_data.V_data.RC(:, :, 2);
E = velocity_data.V_data.CR(:, :, 1);
F = velocity_data.V_data.CR(:, :, 2);
G = velocity_data.V_data_mbp.v_x;
H = velocity_data.V_data_mbp.v_y;
I = velocity_data.V_data_mbp.v_z_RC;
J = velocity_data.V_data_mbp.v_z_CR;