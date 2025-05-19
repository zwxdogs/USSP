function emit_delay = delay_calc_rca(Th_x_ele, Th_y_ele, wave, c0, index_wave, rca_probe)

switch wave.type
    case wave_types.diverge_wave
        source = wave.source(index_wave, :);
        % 用于计算平面波发射的时间延迟
        element = [Th_x_ele, Th_y_ele, zeros(length(Th_x_ele), 1)];
        delay = zeros(1, length(Th_x_ele));  
        for i = 1:length(Th_x_ele)
            distance = norm(element(i, :)-source, 2);
            delay(i) = distance / c0;
        end
        emit_delay = delay - min(delay(:));
    case wave_types.plane_wave
        % 用于计算平面波发射的时间延迟
        if rca_probe.is_RC
            emit_delay = (Th_x_ele * sin(wave.theta(index_wave))) / c0;
            emit_delay = emit_delay';
        else
            emit_delay = (Th_y_ele * sin(wave.theta(index_wave))) / c0;
            emit_delay = emit_delay';
        end
        % delay = delay - min(delay(:));
end

end
