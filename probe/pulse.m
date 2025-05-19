classdef pulse
    % 换能器脉冲响应与激励信号
    
    % 脉冲参数
    properties (Access = public)
        probe                                       % 换能器对象
        fs = 100e6                                  % 采样频率
        excitation_type = excitation_types.square   % 激励类型
        excitation_apo = false                      % 激励是否变迹
        excitation_duration = 2                     % 激励周期数
    end
    % 探头相关参数
    properties (Access = private)
        f0              % 中心频率
        bw              % 带宽
        pulse_duration  % 脉冲响应周期数
    end
    % 脉冲
    properties (SetAccess = private, GetAccess = public)
        impulse_respond             % 脉冲响应
        excitation                  % 激励脉冲
        lag                         % 延迟修正
    end

    % consturctor
    methods
        function pul = pulse(probe)
            pul.probe = probe;
            pul.f0 = probe.f0;
            pul.bw = probe.bw;
            pul.pulse_duration = probe.pulse_duration;
            pul = pul.calc_pulse();
        end
    end

    % update
    methods
        function pul = calc_pulse(pul)
            dt = 1 / pul.fs;
            % 计算脉冲响应
            switch pul.probe.impulse_type
                case impulse_types.gauspuls
                    t0 = (-(pul.pulse_duration/2) / (pul.bw*pul.f0)) : dt : ((pul.pulse_duration/2) / (pul.bw*pul.f0));
                    impul_res = gauspuls(t0, pul.f0, pul.bw);
                    impul_res = impul_res - mean(impul_res);
                    pul.impulse_respond = impul_res;
                case impulse_types.sin
                    disp('暂时不明白正弦脉冲响应的代码是否正确！');
                    % t0 = (-(pul.pulse_duration/2)/pul.f0) : dt : ((pul.pulse_duration/2)/pul.f0);
                    % impul_res = sin(2*pi*pul.f0*t0);
                    % impul_res = impul_res .* hanning(max(size(impul_res)))';
                    % pul.impulse_respond = impul_res;
            end

            % 计算激励脉冲
            switch pul.excitation_type
                case excitation_types.square
                    te = (-(pul.excitation_duration/2)/pul.f0) : dt : ((pul.excitation_duration/2)/pul.f0);
                    excit = square(2*pi*pul.f0*te + pi/2);
                    if pul.excitation_apo == true
                        excit = excit .* hanning(max(size(excit)))';
                    end
                    pul.excitation = excit;
                case excitation_types.sin
                    te = (-(pul.excitation_duration/2)/pul.f0) : dt : ((pul.excitation_duration/2)/pul.f0);
                    excit = sin(2*pi*pul.f0*te + pi/2);
                    if pul.excitation_apo == true
                        excit = excit .* hanning(max(size(excit)))';
                    end
                    pul.excitation = excit;
            end

            % 计算延迟修正
            one_way_ir = conv(impul_res, excit);
            two_way_ir = conv(one_way_ir, impul_res);
            [~, lag_tmp] = max(abs(hilbert(two_way_ir)));
            pul.lag = lag_tmp;
        end
    end

    % set
    methods
        function pul = set.fs(pul, fs)
            pul.fs = fs;
            pul = pul.calc_pulse();
        end
        function pul = set.excitation_type(pul, excitation_type)
            pul.excitation_type = excitation_type;
            pul = pul.calc_pulse();
        end
        function pul = set.excitation_duration(pul, excitation_duration)
            pul.excitation_duration = excitation_duration;
            pul = pul.calc_pulse();
        end
        function pul = set.excitation_apo(pul, excitation_apo)
            pul.excitation_apo = excitation_apo;
            pul = pul.calc_pulse();
        end
    end
end

