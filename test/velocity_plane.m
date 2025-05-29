clear;clc;close all;

para = global_para(100e6, 1500, 1.45e6, 20e3);
% 探头
rca = rca_array(para, 64, 0.2e-3, 0.02e-3, 6.25e6);
% rca.is_RC = false;
rca.bw = 0.6;
% 流动散射体
pha = mk_circle_pha_xy(100, 8e-3, [0, 0, 15e-3], 0.1, 8, para);
figure_1 = figure(1);
pha{1}.plot_pha(figure_1);
% 波角度
wave = rca_pw(-10, 10, 21);
% 扫描区域
% sca = linear_3d_scan(linspace(-10e-3, 10e-3, 600), linspace(0, 40e-3, 600), 0);
sca = linear_xy_scan(linspace(-10e-3, 10e-3, 600), linspace(-10e-3, 10e-3, 600), 15e-3);
% 模拟
p_doppler_data = calc_p_doppler(rca, para, wave, pha, sca, 0, 10);
% 绘制
% figure_1 = figure(1);
% sca.plot_doppler(figure_1, velocity_data, -80);

subplot(131);
p_doppler = sum(p_doppler_data.iq_b_data_RC .* conj(p_doppler_data.iq_b_data_CR) + conj(p_doppler_data.iq_b_data_RC) .* p_doppler_data.iq_b_data_CR, 3) / 8;
p_doppler = abs(p_doppler);
p_doppler_data.P_db = 20*log10(p_doppler/max(p_doppler(:)));
imagesc(sca.x_grid*1000, sca.y_grid*1000, p_doppler_data.P_db);
clim([-80, 0])
colorbar;
colormap('hot');
axis equal ij tight
title('XDoppler');
xlabel('lateral (mm)');
ylabel('depth (mm)');

subplot(132);
p_doppler = sum(abs(p_doppler_data.iq_b_data_RC  + p_doppler_data.iq_b_data_CR).^2, 3) / 8;
p_doppler = abs(p_doppler);
p_doppler_data.P_db = 20*log10(p_doppler/max(p_doppler(:)));
imagesc(sca.x_grid*1000, sca.y_grid*1000, p_doppler_data.P_db);
clim([-80, 0])
colorbar;
colormap('hot');
axis equal ij tight
title('OPW');
xlabel('lateral (mm)');
ylabel('depth (mm)');

subplot(133);
p_doppler_2 = sum(abs(p_doppler_data.iq_b_data_CR).^2, 3) / 8;
p_doppler_2 = abs(p_doppler_2);
p_doppler_data.P_db_2 = 20*log10(p_doppler_2/max(p_doppler_2(:)));
imagesc(sca.x_grid*1000, sca.y_grid*1000, p_doppler_data.P_db_2);
clim([-80, 0])
colorbar;
colormap('hot');
axis equal ij tight
title('CR');
xlabel('lateral (mm)');
ylabel('depth (mm)');