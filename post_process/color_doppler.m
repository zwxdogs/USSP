function velocity_data = color_doppler(doppler_data, global_para, probe, lag, M)
% iq数据转换为doppler数据
% M窗口越大分辨率越低，信噪比越高。
% lag为自相关滞后值

doppler_1 = doppler_data(:, :, 1:1:end-lag);
doppler_2 = doppler_data(:, :, 1+lag:1:end);
% 自相关算法auto-correlation（论文：Eq. 55 in Loupas et al. (IEEE UFFC 42,4;1995)）
AC = sum(doppler_1.*conj(doppler_2), 3);
% 如果M窗口非[1 1]，则需要进行空间平均
if ~isequal([M(1), M(2)], [1, 1])
    h = hamming(M(1)) * hamming(M(2))';
    AC = imfilter(AC, h, 'replicate');
end
% 多普勒速度计算
VN = global_para.c0 * global_para.PRF / (4 * probe.f0 * lag); % 奈奎斯特速度
velocity_data.velocity = -VN * imag(log(AC)) / pi; % imag(log(AC))为angle(AC)，代表着自相关相位差。
% 多普勒方差计算
P = sum(real(doppler_data).^2+imag(doppler_data).^2, 3);
if ~isequal([M(1), M(2)], [1, 1])
    P = imfilter(P, h, 'replicate');
end
velocity_data.variance = 2 * (global_para.c0 * global_para.PRF / (4 * probe.f0 * lag * pi))^2 ...
    * (1 - abs(AC) ./ P);

% 功率多普勒计算
P_db = 20*log10(P/max(P(:)));
velocity_data.P_db = P_db;

end
