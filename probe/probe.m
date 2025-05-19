classdef probe
    % 换能器探头基础类
    % 元素是与x、y轴平行的方形阵元
    % 换能器中心位于原点

    % 探头参数
    properties (SetAccess = protected, GetAccess = public)
        probe_type          % 换能器类型
        el_width            % 阵元宽度
        el_height           % 阵元高度
        N_el                % 阵元个数
        center = [0, 0, 0]  % 探头几何中心坐标
        % 阵元坐标
        x
        y
        z
        xyz
    end
    properties (Access = public)
        f0                  % 中心频率
        bw = 1              % 带宽
    end
    % 探头脉冲响应和激励
    properties (Access = public)
        impulse_type = impulse_types.gauspuls       % 脉冲类型
        pulse_duration = 2                          % 脉冲周期数
        excitation_type = excitation_types.square   % 激励类型
        excitation_apo = false                      % 激励是否变迹
        excitation_duration = 2                     % 激励周期数
    end
    properties (SetAccess = protected, GetAccess = public)
        impulse_respond                             % 脉冲响应
        excitation                                  % 激励
        lag                                         % 延迟修正
    end

    % constructor
    methods
        function probe = probe(N_el, el_width, el_height, f0)
            probe.N_el = N_el;
            probe.el_width = el_width;
            probe.el_height = el_height;
            probe.f0 = f0;
            probe = probe.calc_pulse();
        end
        function probe = calc_pulse(probe)
            dt = 1 / probe.fs;
            % 计算脉冲响应
            switch probe.impulse_type
                case impulse_types.gauspuls
                    t0 = (-(probe.pulse_duration/2) / (probe.bw*probe.f0)) : dt : ((probe.pulse_duration/2) / (probe.bw*probe.f0));
                    impul_res = gauspuls(t0, probe.f0, probe.bw);
                    impul_res = impul_res - mean(impul_res);
                    probe.impulse_respond = impul_res;
                case impulse_types.sin
                    disp('暂时不明白正弦脉冲响应的代码是否正确！');
                    % t0 = (-(pul.pulse_duration/2)/pul.f0) : dt : ((pul.pulse_duration/2)/pul.f0);
                    % impul_res = sin(2*pi*pul.f0*t0);
                    % impul_res = impul_res .* hanning(max(size(impul_res)))';
                    % pul.impulse_respond = impul_res;
            end

            % 计算激励脉冲
            switch probe.excitation_type
                case excitation_types.square
                    te = (-(probe.excitation_duration/2)/probe.f0) : dt : ((probe.excitation_duration/2)/probe.f0);
                    excit = square(2*pi*probe.f0*te + pi/2);
                    if probe.excitation_apo == true
                        excit = excit .* hanning(max(size(excit)))';
                    end
                    probe.excitation = excit;
                case excitation_types.sin
                    te = (-(probe.excitation_duration/2)/probe.f0) : dt : ((probe.excitation_duration/2)/probe.f0);
                    excit = sin(2*pi*probe.f0*te + pi/2);
                    if probe.excitation_apo == true
                        excit = excit .* hanning(max(size(excit)))';
                    end
                    probe.excitation = excit;
            end

            % 计算延迟修正
            one_way_ir = conv(impul_res, excit);
            two_way_ir = conv(one_way_ir, impul_res);
            [~, lag_tmp] = max(abs(hilbert(two_way_ir)));
            probe.lag = lag_tmp;
        end
    end

    % set
    methods
        function probe = set.center(probe, center)
            probe.center = center;
            probe = probe.update;
        end
        function probe = set.f0(probe, f0)
            probe.f0 = f0;
        end
        function probe = set.bw(probe, bw)
            probe.bw = bw;
        end
        function probe = set.impulse_type(probe, impulse_type)
            probe.impulse_type = impulse_type;
        end
        function probe = set.pulse_duration(probe, pulse_duration)
            probe.pulse_duration = pulse_duration;
        end
    end

    % update
    methods (Abstract)
        update(probe)
    end
end