function simu_data = rf_rca_simu(rca_probe, global_para, wave, phantom)

field_init(0);
set_field('c', global_para.c0);
set_field('fs', global_para.fs);
% 采用Field_ii进行模拟
dt = 1 / global_para.fs;
lambda = global_para.c0 / rca_probe.f0;
% 模拟子阵元
N_sub_x = round(rca_probe.el_width/(lambda / 8));
N_sub_y = round(rca_probe.el_height/(lambda / 8));
% 确定发射探头
if rca_probe.is_RC
    Th_x_ele = rca_probe.x(1:rca_probe.N_RC);
    Th_y_ele = rca_probe.y(1:rca_probe.N_RC);
    Th_sub_x = N_sub_x;
    Th_sub_y = N_sub_y;
    Th_width = rca_probe.el_width;
    Th_height = rca_probe.el_height;

    % Rh_x_ele = rca_probe.x(rca_probe.N_RC+1 : rca_probe.N_RC*2);
    % Rh_y_ele = rca_probe.y(rca_probe.N_RC+1 : rca_probe.N_RC*2);
    Rh_sub_x = N_sub_y;
    Rh_sub_y = N_sub_x;
    Rh_width = rca_probe.el_height;
    Rh_height = rca_probe.el_width;

    focus = [0, 0, Inf];
    enabled = ones(rca_probe.N_RC, 1);
    Th = xdc_2d_array(rca_probe.N_RC, 1, Th_width, Th_height, ...
        rca_probe.kerf, rca_probe.kerf, enabled, Th_sub_x, Th_sub_y, focus);
    Rh = xdc_2d_array(1, rca_probe.N_RC, Rh_width, Rh_height, ...
        rca_probe.kerf, rca_probe.kerf, enabled', Rh_sub_x, Rh_sub_y, focus);

    % 沿线元长度方向的换能器内变迹
    t_ele_no = (1:rca_probe.N_RC)';
    t_vec = tukeywin(Th_sub_y, 0.25)';
    t_apo = ones(rca_probe.N_RC, 1) * ...
        reshape(ones(Th_sub_x, 1)*t_vec, 1, Th_sub_x*Th_sub_y);
    ele_apodization(Th, t_ele_no, t_apo);

    r_ele_no = (1:rca_probe.N_RC)';
    r_vec = tukeywin(Rh_sub_x, 0.25)';
    r_apo = ones(rca_probe.N_RC, 1) * ...
        reshape((ones(Rh_sub_y, 1) * r_vec)', 1, Rh_sub_x*Rh_sub_y);
    ele_apodization(Rh, r_ele_no, r_apo);
else
    % Rh_x_ele = rca_probe.x(1 : rca_probe.N_RC);
    % Rh_y_ele = rca_probe.y(1 : rca_probe.N_RC);
    Rh_sub_x = N_sub_x;
    Rh_sub_y = N_sub_y;
    Rh_width = rca_probe.el_width;
    Rh_height = rca_probe.el_height;

    Th_x_ele = rca_probe.x(rca_probe.N_RC+1:rca_probe.N_RC*2);
    Th_y_ele = rca_probe.y(rca_probe.N_RC+1:rca_probe.N_RC*2);
    Th_sub_x = N_sub_y;
    Th_sub_y = N_sub_x;
    Th_width = rca_probe.el_height;
    Th_height = rca_probe.el_width;


    focus = [0, 0, Inf];
    enabled = ones(rca_probe.N_RC, 1);
    Rh = xdc_2d_array(rca_probe.N_RC, 1, Rh_width, Rh_height, ...
        rca_probe.kerf, rca_probe.kerf, enabled, Rh_sub_x, Rh_sub_y, focus);
    Th = xdc_2d_array(1, rca_probe.N_RC, Th_width, Th_height, ...
        rca_probe.kerf, rca_probe.kerf, enabled', Th_sub_x, Th_sub_y, focus);

    % 沿线元长度方向的换能器内变迹
    r_ele_no = (1:rca_probe.N_RC)';
    r_vec = tukeywin(Rh_sub_y, 0.25)';
    r_apo = ones(rca_probe.N_RC, 1) * ...
        reshape(ones(Rh_sub_x, 1)*r_vec, 1, Rh_sub_x*Rh_sub_y);
    ele_apodization(Rh, r_ele_no, r_apo);

    t_ele_no = (1:rca_probe.N_RC)';
    t_vec = tukeywin(Th_sub_x, 0.25)';
    t_apo = ones(rca_probe.N_RC, 1) * ...
        reshape((ones(Th_sub_y, 1) * t_vec)', 1, Th_sub_x*Th_sub_y);
    ele_apodization(Th, t_ele_no, t_apo);
end

xdc_excitation(Th, rca_probe.excitation);
xdc_impulse(Th, rca_probe.impulse_respond);
xdc_baffle(Th, 0);
xdc_center_focus(Th, [0, 0, 0]);

xdc_impulse(Rh, rca_probe.impulse_respond);
xdc_baffle(Rh, 0);
xdc_center_focus(Rh, [0, 0, 0]);

% 定义最大深度
max_deepth = max(phantom.positions(:, 3)) + 3e-3;
cropat = round(2*max_deepth/global_para.c0/dt); % 最大时间采样点数，超过的会被舍去掉。
rf_temp = zeros(cropat, rca_probe.N_RC, wave.N_theta); % 数据预分配空间（数据、通道、波）
delay_times = zeros(wave.N_theta, 1);

% 计算
disp('计算rf_temp原始数据');
for n = 1:wave.N_theta
    disp(['计算第', num2str(n), '个角度（一共', num2str(wave.N_theta), '个）']);

    % 发射孔径
    emit_delay = delay_calc_rca(Th_x_ele, Th_y_ele, wave, global_para.c0, n, rca_probe);
    xdc_apodization(Th, 0, ones(1, rca_probe.N_RC)); % 发射不变迹
    xdc_times_focus(Th, 0, emit_delay);
    % 接收孔径
    xdc_apodization(Rh, 0, ones(1, rca_probe.N_RC)); % 接收不变迹
    xdc_focus_times(Rh, 0, zeros(1, rca_probe.N_RC));

    [v, t] = calc_scat_multi(Th, Rh, phantom.positions, phantom.amplitudes);
    rf_temp(1:size(v, 1), :, n) = v;
    delay_times(n) = -rca_probe.lag * dt + t;
end
% rf_temp = rf_temp ./ max(rf_temp(:));
simu_data.data = rf_temp;
simu_data.delay_t = delay_times;

field_end();

end
