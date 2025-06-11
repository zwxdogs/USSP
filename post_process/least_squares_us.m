function V_data = least_squares_US(data, wave, scan)
% 最小二乘法矢量多普勒
disp('最小二乘法求速度矢量');
% RC
theta_mat = [cos(wave.theta') + 1, sin(wave.theta')];
temp_V_data.RC = zeros(scan.ori_shape(1), scan.ori_shape(2), 2);
for i = 1:scan.ori_shape(1)
    for j = 1:scan.ori_shape(2)
        d_v_mat_RC = reshape(data.RC(i, j, :), [wave.N_theta, 1]) * 2;
        % V_RC = lsqnonneg(theta_mat, d_v_mat_RC); % 最小二乘求解
        V_RC = pinv(theta_mat) * d_v_mat_RC; % 伪逆法求解
        temp_V_data.RC(i, j, :) = V_RC;
    end
end
% CR
theta_mat = [cos(wave.theta') + 1, sin(wave.theta')];
temp_V_data.CR = zeros(scan.ori_shape(1), scan.ori_shape(2), 2);
for i = 1:scan.ori_shape(1)
    for j = 1:scan.ori_shape(2)
        d_v_mat_CR = reshape(data.CR(i, j, :), [wave.N_theta, 1]) * 2;
        % V_CR = lsqnonneg(theta_mat, d_v_mat_CR); % 最小二乘求解
        V_CR = pinv(theta_mat) * d_v_mat_CR; % 伪逆法求解
        temp_V_data.CR(i, j, :) = V_CR;
    end
end
V_data = temp_V_data;

end

