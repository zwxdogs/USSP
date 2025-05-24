classdef global_para
    % 全局参数
    
    % 参数
    properties (Access = public)
        fs              % 采样频率
        c0              % 声速
        Z               % 声阻抗
        PRF             % 脉冲重复频率
    end

    % constructor
    methods
        function para = global_para(fs, c0, Z, PRF)
            para.fs = fs;
            para.c0 = c0;
            para.Z = Z;
            para.PRF = PRF;
        end
    end
end

