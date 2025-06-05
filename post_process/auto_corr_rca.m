function velocity_doppler = auto_corr_rca(rca, UVD_blocks, N_frame, global_para, scan, wave, lag, M)
% 自相关计算多普勒速度

velocity_doppler.RC = zeros(scan.ori_shape(1), scan.ori_shape(2), wave.N_theta);
velocity_doppler.CR = zeros(scan.ori_shape(1), scan.ori_shape(2), wave.N_theta);
for w = 1:wave.N_theta
    data_RC_1 = zeros(scan.ori_shape(1), scan.ori_shape(2), N_frame-lag);
    data_RC_2 = zeros(scan.ori_shape(1), scan.ori_shape(2), N_frame-lag);
    data_CR_1 = zeros(scan.ori_shape(1), scan.ori_shape(2), N_frame-lag);
    data_CR_2 = zeros(scan.ori_shape(1), scan.ori_shape(2), N_frame-lag);
    % 将数据交错赋予
    for n = 1:N_frame
        if n <= lag
            data_RC_1(:, :, n) = UVD_blocks{n}.RC(:, :, w);
            data_CR_1(:, :, n) = UVD_blocks{n}.CR(:, :, w);
        elseif n <= N_frame - lag
            data_RC_1(:, :, n) = UVD_blocks{n}.RC(:, :, w);
            data_CR_1(:, :, n) = UVD_blocks{n}.CR(:, :, w);
            data_RC_2(:, :, n-lag) = UVD_blocks{n}.RC(:, :, w);
            data_CR_2(:, :, n-lag) = UVD_blocks{n}.CR(:, :, w);
        else
            data_RC_2(:, :, n-lag) = UVD_blocks{n}.RC(:, :, w);
            data_CR_2(:, :, n-lag) = UVD_blocks{n}.CR(:, :, w);
        end
    end
    % 自相关
    AC_RC = sum(data_RC_1.*conj(data_RC_2), 3);
    AC_CR = sum(data_CR_1.*conj(data_CR_2), 3);
    if ~isequal([M(1), M(2)], [1, 1])
        h = hamming(M(1)) * hamming(M(2))';
        AC_RC = imfilter(AC_RC, h, 'replicate');
        AC_CR = imfilter(AC_CR, h, 'replicate');
    end
    % 计算多普勒速度
    PRF_eff = global_para.PRF / (wave.N_theta * 2);
    VN = global_para.c0 * PRF_eff / (4 * rca.f0 * lag);
    velocity_RC = VN * angle(AC_RC) / pi;
    velocity_CR = VN * angle(AC_CR) / pi;
    velocity_doppler.RC(:, :, w) = velocity_RC;
    velocity_doppler.CR(:, :, w) = velocity_CR;

end

end
