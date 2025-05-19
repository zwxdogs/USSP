classdef phantom
    % 散射体类
    
    % 散射体参数
    properties (SetAccess = protected, GetAccess = public)
        positions
        amplitudes
    end
    
    % constructor
    methods
        function pha = phantom()
        end
    end
    
    % define
    methods
        function pha = pha_pos(pha, positions, amplitudes)
            pha.positions = positions;
            pha.amplitudes = amplitudes;
        end
    end
end

