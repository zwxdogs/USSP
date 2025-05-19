subplot(122);

t0_2 = simu.delay_t;
t_axis_2 = t0_2 + (0:size(simu.rf_data, 1)-1)'/pulse.fs;
subplot(122);
imagesc(1:rca.N_RC, t_axis_2*1e6, simu.rf_data, [-1, 1]);
hold on;
colorbar;
xlabel('Element number');
ylabel('time [\mus]');

transmit = 15e-3 * cos(deg2rad(-5)) + (-3e-3) * sin(deg2rad(-5));
Rh_y_ele = rca.y(rca.N_RC+1:rca.N_RC*2);
r_p_min = [repmat(-rca.el_height/2, rca.N_RC, 1), Rh_y_ele, zeros(rca.N_RC, 1)];
r_p_max = [repmat(rca.el_height/2, rca.N_RC, 1), Rh_y_ele, zeros(rca.N_RC, 1)];

receive = zeros(32, 1);
for i = 1:32
    receive(i) = p2l_rca([0 0 15e-3], r_p_min(i, :), r_p_max(i, :));
end
ToF = (transmit + receive)/simu.c0;

plot(1:32, ToF*1e6, '-r')
