classdef global_para
    % 全局参数
    
    % 参数
    properties (Access = public)
        fs              % 采样频率
        c0              % 声速
    end

    % constructor
    methods
        function para = global_para(fs, c0)
            para.fs = fs;
            para.c0 = c0;
        end
    end
end

