classdef simu_us
    % field_ii模拟类

    % MBeautifierDirective:Format:Off
    % 模拟参数
    properties (SetAccess = private, GetAccess = public)
        pulse                               % 脉冲
        probe                               % 换能器
        wave                                % 波束
        aperture_center = [0, 0, 0]         % 孔径中心
    end
    properties (Access = public)
        c0                                  % 声速
        Z                                   % 声阻抗
        N_sub_az                                % 阵元主扫描方向子阵元数量
        N_sub_el                            % 阵元仰角方向子阵元数量
    end
    % MBeautifierDirective:Format:On

    % 模拟结果数据
    properties (SetAccess = private, GetAccess = public)
        I_data                              % 声强数据
        rf_data                             % RF原始数据
        rf_data_norm                        % RF原始数据归一化
        delay_t                             % Field-ii模拟通道时间延迟
        iq_data                             % IQ数据
    end

    % constructor
    methods
        function simu = simu_us(probe, pulse, wave, c0, Z)
            simu.probe = probe;
            simu.pulse = pulse;
            simu.wave = wave;
            simu.c0 = c0;
            simu.Z = Z;

            lambda = c0 / probe.f0;
            simu.N_sub_az = round(probe.el_width/(lambda / 8));
            simu.N_sub_el = round(probe.el_height/(lambda / 8));

            % field_ii初始化
            simu.field_ii_init();
        end
    end

    % 模拟计算
    methods
        function simu = calc_I(simu, scan)
            switch simu.probe.probe_type
                case probe_types.rca_array
                    simu.I_data = simu.calc_I_rca(scan);
            end
        end
        function simu = calc_rf(simu, phantom)
            switch simu.probe.probe_type
                case probe_types.rca_array
                    [simu.rf_data, simu.delay_t] = simu.calc_rf_rca(phantom);
            end
        end
        function field_ii_init(simu)
            % addpath('../m_field_ii');
            field_init(0);
            set_field('c', simu.c0);
            set_field('fs', simu.pulse.fs);
        end
    end

    % 声压计算 - rca
    methods
        function I_data = calc_I_rca(simu, scan)
            dt = 1 / simu.pulse.fs;
            % 确定发射探头
            if simu.probe.is_RC
                Th_x_ele = simu.probe.x(1:simu.probe.N_RC);
                Th_y_ele = simu.probe.y(1:simu.probe.N_RC);

                focus = [0, 0, Inf];
                enabled = ones(simu.probe.N_RC, 1);
                Th = xdc_2d_array(simu.probe.N_RC, 1, simu.probe.el_width, simu.probe.el_height, ...
                    simu.probe.kerf, simu.probe.kerf, enabled, simu.N_sub_az, simu.N_sub_el, focus);
            else
                Th_x_ele = simu.probe.x(simu.probe.N_RC+1:simu.probe.N_RC*2);
                Th_y_ele = simu.probe.y(simu.probe.N_RC+1:simu.probe.N_RC*2);

                focus = [0, 0, Inf];
                enabled = ones(1, simu.probe.N_RC);
                Th = xdc_2d_array(1, simu.probe.N_RC, simu.probe.el_height, simu.probe.el_width, ...
                    simu.probe.kerf, simu.probe.kerf, enabled, simu.N_sub_el, simu.N_sub_az, focus);
            end
            xdc_excitation(Th, simu.pulse.excitation);
            xdc_impulse(Th, simu.pulse.impulse_respond);
            xdc_baffle(Th, 0);
            xdc_center_focus(Th, [0, 0, 0]);

            % 发射变迹
            apo = hanning(simu.probe.N_RC)';
            xdc_apodization(Th, 0, apo);
            % 声压场计算
            xdc_center_focus(Th, [0, 0, 0]); % 发射聚焦
            emit_delay = simu.delay_calc(Th_x_ele, Th_y_ele, simu.c0, 1);
            xdc_times_focus(Th, 0, emit_delay);
            emit_field = calc_hp(Th, [scan.scan_x, scan.scan_y, scan.scan_z]);
            % 声强场处理
            I = sum(emit_field.^2) * dt / simu.Z;
            I_norm = I / max(I(:));
            I_db = 10 * log10(I_norm);
            I_db = reshape(I_db, scan.ori_shape);
            I_data = I_db;

            field_end();
        end
    end

    % RF数据计算 - rca
    methods
        function [rf_data, delay] = calc_rf_rca(simu, phantom)
            dt = 1 / simu.pulse.fs;
            % 确定发射探头
            if simu.probe.is_RC
                Th_x_ele = simu.probe.x(1:simu.probe.N_RC);
                Th_y_ele = simu.probe.y(1:simu.probe.N_RC);
                Th_sub_x = simu.N_sub_az;
                Th_sub_y = simu.N_sub_el;
                Th_width = simu.probe.el_width;
                Th_height = simu.probe.el_height;

                % Rh_x_ele = simu.probe.x(simu.probe.N_RC+1 : simu.probe.N_RC*2);
                % Rh_y_ele = simu.probe.y(simu.probe.N_RC+1 : simu.probe.N_RC*2);
                Rh_sub_x = simu.N_sub_el;
                Rh_sub_y = simu.N_sub_az;
                Rh_width = simu.probe.el_height;
                Rh_height = simu.probe.el_width;

                focus = [0, 0, Inf];
                enabled = ones(simu.probe.N_RC, 1);
                Th = xdc_2d_array(simu.probe.N_RC, 1, Th_width, Th_height, ...
                    simu.probe.kerf, simu.probe.kerf, enabled, Th_sub_x, Th_sub_y, focus);
                Rh = xdc_2d_array(1, simu.probe.N_RC, Rh_width, Rh_height, ...
                    simu.probe.kerf, simu.probe.kerf, enabled', Rh_sub_x, Rh_sub_y, focus);

                % 沿线元长度方向的换能器内变迹
                t_ele_no = (1:simu.probe.N_RC)';
                t_vec = tukeywin(Th_sub_y, 0.25)';
                t_apo = ones(simu.probe.N_RC, 1) * ...
                    reshape(ones(Th_sub_x, 1)*t_vec, 1, Th_sub_x*Th_sub_y);
                ele_apodization(Th, t_ele_no, t_apo);

                r_ele_no = (1:simu.probe.N_RC)';
                r_vec = tukeywin(Rh_sub_x, 0.25)';
                r_apo = ones(simu.probe.N_RC, 1) * ...
                    reshape((ones(Rh_sub_y, 1) * r_vec)', 1, Rh_sub_x*Rh_sub_y);
                ele_apodization(Rh, r_ele_no, r_apo);
            else
                % Rh_x_ele = simu.probe.x(1 : simu.probe.N_RC);
                % Rh_y_ele = simu.probe.y(1 : simu.probe.N_RC);
                Rh_sub_x = simu.N_sub_az;
                Rh_sub_y = simu.N_sub_el;
                Rh_width = simu.probe.el_width;
                Rh_height = simu.probe.el_height;

                Th_x_ele = simu.probe.x(simu.probe.N_RC+1:simu.probe.N_RC*2);
                Th_y_ele = simu.probe.y(simu.probe.N_RC+1:simu.probe.N_RC*2);
                Th_sub_x = simu.N_sub_el;
                Th_sub_y = simu.N_sub_az;
                Th_width = simu.probe.el_height;
                Th_height = simu.probe.el_width;


                focus = [0, 0, Inf];
                enabled = ones(simu.probe.N_RC, 1);
                Rh = xdc_2d_array(simu.probe.N_RC, 1, Rh_width, Rh_height, ...
                    simu.probe.kerf, simu.probe.kerf, enabled, Rh_sub_x, Rh_sub_y, focus);
                Th = xdc_2d_array(1, simu.probe.N_RC, Th_width, Th_height, ...
                    simu.probe.kerf, simu.probe.kerf, enabled', Th_sub_x, Th_sub_y, focus);

                % 沿线元长度方向的换能器内变迹
                r_ele_no = (1:simu.probe.N_RC)';
                r_vec = tukeywin(Rh_sub_y, 0.25)';
                r_apo = ones(simu.probe.N_RC, 1) * ...
                    reshape(ones(Rh_sub_x, 1)*r_vec, 1, Rh_sub_x*Rh_sub_y);
                ele_apodization(Rh, r_ele_no, r_apo);

                t_ele_no = (1:simu.probe.N_RC)';
                t_vec = tukeywin(Th_sub_x, 0.25)';
                t_apo = ones(simu.probe.N_RC, 1) * ...
                    reshape((ones(Th_sub_y, 1) * t_vec)', 1, Th_sub_x*Th_sub_y);
                ele_apodization(Th, t_ele_no, t_apo);
            end

            xdc_excitation(Th, simu.pulse.excitation);
            xdc_impulse(Th, simu.pulse.impulse_respond);
            xdc_baffle(Th, 0);
            xdc_center_focus(Th, [0, 0, 0]);

            xdc_impulse(Rh, simu.pulse.impulse_respond);
            xdc_baffle(Rh, 0);
            xdc_center_focus(Rh, [0, 0, 0]);

            % 定义最大深度
            max_deepth = max(phantom.positions(:, 3)) + 3e-3;
            cropat = round(2*max_deepth/simu.c0/dt); % 最大时间采样点数，超过的会被舍去掉。
            rf_temp = zeros(cropat, simu.probe.N_RC, simu.wave.N_theta); % 数据预分配空间（数据、通道、波）
            delay_times = zeros(simu.wave.N_theta, 1);

            % 计算
            disp('计算rf_temp原始数据');
            wb = waitbar(0, '计算rf_temp原始数据');
            for n = 1:simu.wave.N_theta
                waitbar(n / simu.wave.N_theta, wb);
                disp(['计算第', num2str(n), '个角度（一共', num2str(simu.wave.N_theta), '个）']);

                % 发射孔径
                emit_delay = simu.delay_calc(Th_x_ele, Th_y_ele, simu.c0, n);
                xdc_apodization(Th, 0, ones(1, simu.probe.N_RC)); % 发射不变迹
                xdc_times_focus(Th, 0, emit_delay);

                % 接收孔径
                xdc_apodization(Rh, 0, ones(1, simu.probe.N_RC)); % 接收不变迹
                xdc_focus_times(Rh, 0, zeros(1, simu.probe.N_RC));

                [v, t] = calc_scat_multi(Th, Rh, phantom.positions, phantom.amplitudes);
                rf_temp(1:size(v, 1), :, n) = v;
                delay_times(n) = -simu.pulse.lag * dt + t;
            end
            % rf_temp = rf_temp ./ max(rf_temp(:));
            rf_data = rf_temp;
            delay = delay_times;
            close(wb);

            field_end();
        end
        function emit_delay = delay_calc(simu, Th_x_ele, Th_y_ele, c0, w)
            switch simu.wave.wave_type
                case wave_types.diverge_wave
                    emit_delay = dw_rca_delay(Th_x_ele, Th_y_ele, simu.wave.source(w, :), c0);
                case wave_types.plane_wave
                    emit_delay = pw_rca_delay(Th_x_ele, Th_y_ele, simu.probe.is_RC, simu.wave.theta_az(w), c0)';
            end
        end
        function simu = rf2iq(simu)
            % 计算出的IQ数据已进行了归一化。
            simu.rf_data_norm = simu.rf_data ./ max(simu.rf_data(:));
            t_v = (0:size(simu.rf_data_norm, 1)-1)' / simu.pulse.fs;
            % 下混频
            iq_temp = simu.rf_data_norm .* exp(-1i*2*pi*simu.probe.f0*t_v);
            % Wn为归一化截止频率，为截止频率*2/采样频率
            Wn = (simu.probe.bw * simu.probe.f0) / (simu.pulse.fs / 2);
            % 低通滤波
            [b, a] = butter(5, Wn);
            iq_temp = filtfilt(b, a, iq_temp)*2;
            
            simu.iq_data = iq_temp;
        end
    end

    % set
    methods
        function simu = set.c0(simu, c0)
            simu.c0 = c0;
        end
        function simu = set.Z(simu, Z)
            simu.Z = Z;
        end
        function simu = set.N_sub_az(simu, N_sub_az)
            simu.N_sub_az = N_sub_az;
        end
        function simu = set.N_sub_el(simu, N_sub_el)
            simu.N_sub_el = N_sub_el;
        end
    end

    % plot
    methods

    end
end
