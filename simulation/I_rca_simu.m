function I_field = I_rca_simu(rca_probe, wave, global_para, scan)

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

    focus = [0, 0, Inf];
    enabled = ones(rca_probe.N_RC, 1);
    Th = xdc_2d_array(rca_probe.N_RC, 1, rca_probe.el_width, rca_probe.el_height, ...
        rca_probe.kerf, rca_probe.kerf, enabled, N_sub_x, N_sub_y, focus);
else
    Th_x_ele = rca_probe.x(rca_probe.N_RC+1:rca_probe.N_RC*2);
    Th_y_ele = rca_probe.y(rca_probe.N_RC+1:rca_probe.N_RC*2);

    focus = [0, 0, Inf];
    enabled = ones(1, rca_probe.N_RC);
    Th = xdc_2d_array(1, rca_probe.N_RC, rca_probe.el_height, rca_probe.el_width, ...
        rca_probe.kerf, rca_probe.kerf, enabled, N_sub_y, N_sub_x, focus);
end
xdc_excitation(Th, rca_probe.excitation);
xdc_impulse(Th, rca_probe.impulse_respond);
xdc_baffle(Th, 0);
xdc_center_focus(Th, [0, 0, 0]);

% 发射变迹
apo = hanning(rca_probe.N_RC)';
xdc_apodization(Th, 0, apo);
% 声压场计算
xdc_center_focus(Th, [0, 0, 0]); % 发射聚焦
emit_delay = delay_calc_rca(Th_x_ele, Th_y_ele, wave, global_para.c0, 1, rca_probe);
xdc_times_focus(Th, 0, emit_delay);
emit_field = calc_hp(Th, [scan.scan_x, scan.scan_y, scan.scan_z]);
% 声强场处理
I = sum(emit_field.^2) * dt / global_para.Z;
I_norm = I / max(I(:));
I_db = 10 * log10(I_norm);
I_db = reshape(I_db, scan.ori_shape);
I_field = I_db;

field_end();

end
