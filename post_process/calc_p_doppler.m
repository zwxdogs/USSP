function p_doppler_data = calc_p_doppler(rca, global_para, wave, phantom, scan, svd_filt, s_index)
% xdoppler复合功率多普勒

% RC发射和CR发射
rca_RC = rca;
rca_RC.is_RC = true;
rca_CR = rca;
rca_CR.is_RC = false;
% ------------------------------模拟数据------------------------------
% % RC
N_frame = length(phantom);
dt = 1 / global_para.fs;
max_deepth = max(scan.scan_z);
cropat = round(2*max_deepth/global_para.c0/dt);
delay_t_RC = zeros(wave.N_theta, N_frame);
iq_data_RC = zeros(cropat, rca_RC.N_RC, wave.N_theta, N_frame);
disp('计算多角度多帧原始数据 - RC');
disp('---------------------------------------------');
for n = 1:N_frame
    disp(['计算第', num2str(n), '帧的数据（一共', num2str(N_frame), '帧）']);
    pha = phantom{n};
    simu_data = rca_RC.calc_rf(global_para, wave, pha);
    iq_data_RC(1:size(simu_data.data, 1), :, :, n) = simu_data.data;
    delay_t_RC(:, n) = simu_data.delay_t;
    disp('---------------------------------------------');
end
p_doppler_data.iq_data_RC = iq_data_RC;
% CR
delay_t_CR = zeros(wave.N_theta, N_frame);
iq_data_CR = zeros(cropat, rca_CR.N_RC, wave.N_theta, N_frame);
disp('计算多角度多帧原始数据 - CR');
disp('---------------------------------------------');
for n = 1:N_frame
    disp(['计算第', num2str(n), '帧的数据（一共', num2str(N_frame), '帧）']);
    pha = phantom{n};
    simu_data = rca_CR.calc_rf(global_para, wave, pha);
    iq_data_CR(1:size(simu_data.data, 1), :, :, n) = simu_data.data;
    delay_t_CR(:, n) = simu_data.delay_t;
    disp('---------------------------------------------');
end
p_doppler_data.iq_data_CR = iq_data_CR;
% ------------------------------SVD滤波------------------------------
if svd_filt
    % RC
    disp('SVD滤波 - RC');
    disp('---------------------------------------------');
    iq_data_filt_RC = zeros(cropat, rca_RC.N_RC, wave.N_theta, N_frame);
    for w = 1:wave.N_theta
        disp(['滤波第', num2str(w), '个角度（一共', num2str(wave.N_theta), '个）']);
        data = iq_data_RC(:, :, w, :);
        casorati_M = reshape(data, [cropat * rca_RC.N_RC, N_frame]);
        [U, S, V] = svd(casorati_M);
        singular = diag(S);
        selected_s = singular > singular(s_index+1);
        S_filt = S;
        S_filt(selected_s, selected_s) = 0;
        filt_data = U * S_filt * V';
        iq_data_filt_RC(:, :, w, :) = reshape(filt_data, size(data));
        disp('---------------------------------------------');
    end
    p_doppler_data.iq_data_filt_RC = iq_data_filt_RC;
    % CR
    disp('SVD滤波 - CR');
    disp('---------------------------------------------');
    iq_data_filt_CR = zeros(cropat, rca_CR.N_RC, wave.N_theta, N_frame);
    for w = 1:wave.N_theta
        disp(['滤波第', num2str(w), '个角度（一共', num2str(wave.N_theta), '个）']);
        data = iq_data_CR(:, :, w, :);
        casorati_M = reshape(data, [cropat * rca_CR.N_RC, N_frame]);
        [U, S, V] = svd(casorati_M);
        singular = diag(S);
        selected_s = singular > singular(s_index+1);
        S_filt = S;
        S_filt(selected_s, selected_s) = 0;
        filt_data = U * S_filt * V';
        iq_data_filt_CR(:, :, w, :) = reshape(filt_data, size(data));
        disp('---------------------------------------------');
    end
    p_doppler_data.iq_data_filt_CR = iq_data_filt_CR;
else
    iq_data_filt_RC = iq_data_RC;
    iq_data_filt_CR = iq_data_CR;
end
% ------------------------------波束成形------------------------------
% RC
disp('波束成形 - RC');
disp('---------------------------------------------');
iq_b_data_RC = zeros(scan.ori_shape(1), scan.ori_shape(2), N_frame);
for n = 1:N_frame
    disp(['波束成形第', num2str(n), '帧的数据（一共', num2str(N_frame), '帧）']);
    filt_data_RC.data = iq_data_filt_RC(:, :, :, n);
    if (~exist('ToF_tr_RC', 'var'))
        ToF_tr_RC = calc_ToF_rca(wave, rca_RC, delay_t_RC(:, n), scan, global_para.c0);
        for i = 1:wave.N_theta
            ToF_tr_RC(:, :, i) = ToF_tr_RC(:, :, i) + delay_t_RC(i, n);
        end
    end
    ToF_RC = zeros(size(ToF_tr_RC));
    for i = 1:wave.N_theta
        ToF_RC(:, :, i) = ToF_tr_RC(:, :, i) - delay_t_RC(i, n);
    end
    beamformed_data_RC = das_rca(filt_data_RC, rca_RC, global_para, wave, scan, ToF_RC);
    comp_data_RC = wave_compounded(beamformed_data_RC, scan);
    iq_b_data_RC(:, :, n) = comp_data_RC;
    disp('---------------------------------------------');
end
p_doppler_data.iq_b_data_RC = iq_b_data_RC;
% CR
disp('波束成形 - CR');
disp('---------------------------------------------');
iq_b_data_CR = zeros(scan.ori_shape(1), scan.ori_shape(2), N_frame);
for n = 1:N_frame
    disp(['波束成形第', num2str(n), '帧的数据（一共', num2str(N_frame), '帧）']);
    filt_data_CR.data = iq_data_filt_CR(:, :, :, n);
    if (~exist('ToF_tr_CR', 'var'))
        ToF_tr_CR = calc_ToF_rca(wave, rca_CR, delay_t_CR(:, n), scan, global_para.c0);
        for i = 1:wave.N_theta
            ToF_tr_CR(:, :, i) = ToF_tr_CR(:, :, i) + delay_t_CR(i, n);
        end
    end
    ToF_CR = zeros(size(ToF_tr_CR));
    for i = 1:wave.N_theta
        ToF_CR(:, :, i) = ToF_tr_CR(:, :, i) - delay_t_CR(i, n);
    end
    beamformed_data_CR = das_rca(filt_data_CR, rca_CR, global_para, wave, scan, ToF_CR);
    comp_data_CR = wave_compounded(beamformed_data_CR, scan);
    iq_b_data_CR(:, :, n) = comp_data_CR;
    disp('---------------------------------------------');
end
p_doppler_data.iq_b_data_CR = iq_b_data_CR;
% ------------------------------功率多普勒------------------------------
% xdoppler方法（论文：）
% p_doppler = sum(iq_b_data_RC.*conj(iq_b_data_CR)+conj(iq_b_data_RC).*iq_b_data_CR, 3) / N_frame;
% p_doppler = abs(p_doppler);
% p_doppler_data.P_db = 20 * log10(p_doppler/max(p_doppler(:)));
% P = sum(real(iq_b_data_CR).^2 + imag(iq_b_data_CR).^2, 3);
% p_doppler_data.P_db = 20*log10(P/max(P(:)));

end
