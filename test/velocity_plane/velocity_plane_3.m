clear;clc;close all;

para = global_para(100e6, 1500, 1.45e6, 40e3);
% 探头
rca = rca_array(para, 64, 0.3e-3, 0.03e-3, 6e6);
rca.bw = 0.6;
% 波角度
wave = rca_pw(-3, 3, 7);
V_N = para.PRF/(wave.N_theta*2) * para.c0 / (4 * rca.f0);
% 流动散射体
pha = mk_circle_pha(3000, 3e-3, [0, 0, 20e-3], 0.05, 10, para, wave);
% figure_1 = figure(1);
% pha{1}.plot_pha(figure_1);
% 扫描区域
sca = linear_3d_scan(linspace(-6e-3, 6e-3, 150), linspace(10e-3, 30e-3, 100), 0);
% sca = linear_xy_scan(linspace(-10e-3, 10e-3, 600), linspace(-10e-3, 10e-3, 600), 15e-3);
% 模拟
velocity_data = rca.calc_velocity(para, wave, pha, sca, 1, [1, 1], -30);
% 绘制
min_p_db = -50;
figure_1 = figure(1);
sca.plot_velocity(figure_1, velocity_data, min_p_db, 0.1, 2, cool);
% 数据测试
idx = velocity_data.P_db > min_p_db;
RC_v_z = velocity_data.V_data.RC(:, :, 1) .* idx;
RC_v_x = velocity_data.V_data.RC(:, :, 2) .* idx;
RC_v_abs = sqrt(RC_v_z.^2 + RC_v_x.^2);
pow_v_z = 0;
pow_v_x = 0;
pow_v_abs = 0;
sum_v_z = 0;
sum_v_x = 0;
sum_v_abs = 0;
v_z_test = zeros(size(RC_v_z));
for i = 1:sca.N_pixels
    if RC_v_z(i)~=0
        r = sqrt((sca.scan_x(i) - 0)^2 + (sca.scan_z(i) - 20e-3)^2);
        v = 10 * r;
        angle = atan((sca.scan_z(i) - 20e-3) / (sca.scan_x(i) - 0));
        v_z_test(i) = v * cos(angle);
        pow_v_z = pow_v_z + (RC_v_z(i) - (v * cos(angle)))^2;
        pow_v_x = pow_v_x + (RC_v_x(i) - (v * sin(angle)))^2;
        pow_v_abs = pow_v_abs + (RC_v_abs(i) - v)^2;
        sum_v_z = sum_v_z + RC_v_z(i);
        sum_v_x = sum_v_x + RC_v_x(i);
        sum_v_abs = sum_v_abs + RC_v_abs(i);
    end
end
RMSE_v_z = sqrt(pow_v_z / sum(sum(RC_v_z~=0)));
RMSE_v_x = sqrt(pow_v_x / sum(sum(RC_v_x~=0)));
RMSE_v_abs = sqrt(pow_v_abs / sum(sum(RC_v_abs~=0)));

ave_v_z = sum_v_z / sum(sum(RC_v_z~=0));
ave_v_x = sum_v_x / sum(sum(RC_v_x~=0));
ave_v_abs = sum_v_abs / sum(sum(RC_v_abs~=0));
sd_v_z = 0;
sd_v_x = 0;
sd_v_abs = 0;
for i = 1:sca.N_pixels
    if RC_v_z(i)~=0
        sd_v_z = sd_v_z + (RC_v_z(i) - ave_v_z)^2;
        sd_v_x = sd_v_x + (RC_v_x(i) - ave_v_x)^2;
        sd_v_abs = sd_v_abs + (RC_v_abs(i) - ave_v_abs)^2;
    end
end
sd_v_z = sqrt(sd_v_z / sum(sum(RC_v_z~=0)));
sd_v_x = sqrt(sd_v_x / sum(sum(RC_v_x~=0)));
sd_v_abs = sqrt(sd_v_abs / sum(sum(RC_v_abs~=0)));
% 保存数据
file = "rca"+ num2str(rca.N_RC) + "_" + num2str(wave.N_theta) + "A_" + num2str(size(pha, 1)) + "F_PRF" + num2str(para.PRF/1000) + ".mat";
file = "data\" + file;
save(file, "para", "pha", "RC_v_x", "RC_v_z", "rca", "RMSE_v_x", "RMSE_v_z", "RMSE_v_abs", "sca", "sd_v_x", "sd_v_z", "sd_v_abs", "V_N", "velocity_data", "wave");