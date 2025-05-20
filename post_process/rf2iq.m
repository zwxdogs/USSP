function iq_data = rf2iq(simu_data, probe, global_para)
% 进行iq解调

rf_data = simu_data.rf_data;
rf_data_norm = rf_data ./ max(rf_data(:));
% 时间向量
t_v = (0:size(rf_data_norm, 1)-1)' / global_para.fs;
% 下混频
iq_temp = rf_data_norm .* exp(-1i*2*pi*probe.f0*t_v);
% Wn为归一化截止频率，为截止频率*2/采样频率
Wn = (probe.bw * probe.f0) / (global_para.fs / 2);
% 低通滤波
[b, a] = butter(5, Wn);
iq_temp = filtfilt(b, a, iq_temp)*2;

iq_data.iq_data = iq_temp;
iq_data.delay_t = simu_data.delay_t;

end

