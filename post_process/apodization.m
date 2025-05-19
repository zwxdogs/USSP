classdef apodization
    % 变迹类
    
    % MBeautifierDirective:Format:Off
    % 属性
    properties (Access = public)
        apodization_type                                    % 变迹方式
        num_apo                                             % 变迹数据点数
    end
    properties (GetAccess = public, SetAccess = protected)
        apodization_data                                    % 加权数据
    end
    % MBeautifierDirective:Format:on

    % 构造函数
    methods
        function apo = apodization(num_apo)
            apo.num_apo = num_apo;
        end
    end

    % update
    methods
        function apo = update(apo)
            switch apo.apodization_type
                case apodization_types.hanning
                    apo.apodization_data = hanning(apo.num_apo);
                case apodization_types.tukey25
                    apo.apodization_data = tukey(apo.num_apo, 0.25);
                case apodization_types.tukey50
                    apo.apodization_data = tukey(apo.num_apo, 0.50);
                case apodization_types.tukey75
                    apo.apodization_data = tukey(apo.num_apo, 0.75);
                case apodization_types.none
                    apo.apodization_data = ones(apo.num_apo, 1);
            end
        end
    end

    % set
    methods
        function apo = set.apodization_type(apo, apo_type)
            apo.apodization_type = apo_type;
            apo = apo.update();
        end
    end
end

