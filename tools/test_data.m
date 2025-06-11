function test_data = test_data(data, p_db, min_p_db, scan, v_z_t, v_x_t, v_abs_t)
% 数据测试
idx = p_db > min_p_db;
RC_v_z = data.RC(:, :, 1) .* idx;
RC_v_x = data.RC(:, :, 2) .* idx;
RC_v_abs = sqrt(RC_v_z.^2 + RC_v_x.^2);
test_data.RC_v_z = RC_v_z;
test_data.RC_v_x = RC_v_x;
test_data.RC_v_abs = RC_v_abs;
% RMSE
pow_v_z = 0;
pow_v_x = 0;
pow_v_abs = 0;
sum_v_z = 0;
sum_v_x = 0;
sum_v_abs = 0;
for i = 1:scan.N_pixels
    if RC_v_z(i)~=0
        pow_v_z = pow_v_z + (RC_v_z(i) - v_z_t)^2;
        pow_v_x = pow_v_x + (RC_v_x(i) - v_x_t)^2;
        pow_v_abs = pow_v_abs + (RC_v_abs(i) - v_abs_t)^2;
        sum_v_z = sum_v_z + RC_v_z(i);
        sum_v_x = sum_v_x + RC_v_x(i);
        sum_v_abs = sum_v_abs + RC_v_abs(i);
    end
end
test_data.RMSE_v_z = sqrt(pow_v_z / sum(sum(RC_v_z~=0))) / v_z_t;
test_data.RMSE_v_x = sqrt(pow_v_x / sum(sum(RC_v_x~=0))) / v_x_t;
test_data.RMSE_v_abs = sqrt(pow_v_abs / sum(sum(RC_v_abs~=0))) / v_abs_t;
%B
bia_v_x = 0;
bia_v_z = 0;
bia_v_abs = 0;
for i = 1:scan.N_pixels
    if RC_v_z(i)~=0
        bia_v_z = bia_v_z + (RC_v_z(i) - v_z_t);
        bia_v_x = bia_v_x + (RC_v_x(i) - v_x_t);
        bia_v_abs = bia_v_abs + (RC_v_abs(i) - v_abs_t);
    end
end
test_data.B_v_z = bia_v_z / sum(sum(RC_v_z~=0)) / v_z_t;
test_data.B_v_x = bia_v_x / sum(sum(RC_v_x~=0)) / v_x_t;
test_data.B_v_abs = bia_v_abs / sum(sum(RC_v_abs~=0)) / v_abs_t;
% SD
ave_v_z = sum_v_z / sum(sum(RC_v_z~=0));
ave_v_x = sum_v_x / sum(sum(RC_v_x~=0));
ave_v_abs = sum_v_abs / sum(sum(RC_v_abs~=0));
sd_v_z = 0;
sd_v_x = 0;
sd_v_abs = 0;
for i = 1:scan.N_pixels
    if RC_v_z(i)~=0
        sd_v_z = sd_v_z + (RC_v_z(i) - ave_v_z)^2;
        sd_v_x = sd_v_x + (RC_v_x(i) - ave_v_x)^2;
        sd_v_abs = sd_v_abs + (RC_v_abs(i) - ave_v_abs)^2;
    end
end
test_data.sd_v_z = sqrt(sd_v_z / sum(sum(RC_v_z~=0))) / ave_v_z;
test_data.sd_v_x = sqrt(sd_v_x / sum(sum(RC_v_x~=0))) / ave_v_x;
test_data.sd_v_abs = sqrt(sd_v_abs / sum(sum(RC_v_abs~=0))) / ave_v_abs;

end

