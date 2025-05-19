classdef compounded
    % 复合类

    % MBeautifierDirective:Format:Off
    % 属性
    properties (GetAccess = public, SetAccess = protected)
        origin_data             % 波束成形数据
        compounded_data             % 复合数据
    end
    % MBeautifierDirective:Format:On

    % 构造函数
    methods
        function comp = compounded()
        end
    end

    % 复合方法
    methods
        % 波束复合
        function comp = wave_compounded(comp, origin_data, scan)
            comp.origin_data = origin_data;
            apo_wave = apodization(size(comp.origin_data, 2));
            apo_wave.apodization_type = 'hanning';
            apo_data = apo_wave.apodization_data';
            apo_data = repmat(apo_data, size(comp.origin_data, 1), 1);
            comp.origin_data = apo_data .* comp.origin_data;
            comp.compounded_data = reshape(sum(comp.origin_data, 2), scan.ori_shape);
        end
    end
end
