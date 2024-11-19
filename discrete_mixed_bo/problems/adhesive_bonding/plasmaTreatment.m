function [reductionContactAngle] = plasmaTreatment(sample_size, plasma_power, plasma_distance, plasma_passes, plasma_speed)
    % procentuele vermindering in contacthoek
    time_per_pass = sample_size/plasma_speed;
    total_time = time_per_pass*plasma_passes;
    total_power = total_time*plasma_power;
    %disp(("............."))
    
    % 1. Influence of total applied power: (value between 0 and 1, 1
    % resulting in a large reduction)
    scale = 0.005; offset = 125;
    reductionContactAngle = 1-((((70*(scale*(total_power-offset)).^2-(scale.*(total_power-offset))+1000)./(20*scale.*(total_power-offset)+24))./79.9)-2*0.2376.*sigmoid(total_power,0,-0.17));
    
    % 2. Correction for distance from plasma nozzle to part: (value between 0 and 1)
    %reductionContactAngle = reductionContactAngle*1.15*exp(-0.083*plasma_distance);
    reductionContactAngle = reductionContactAngle*(1-sigmoid(plasma_distance, 1.1, 11));
    
    % 3. Correction for total power consumption:
    scale = 1.12;
    reductionContactAngle = reductionContactAngle*scale*(sigmoid(plasma_power, 300, 0.014)+sigmoid(plasma_power, 560, -0.040)-1);
    %disp(reductionContactAngle)
    
    % 1. Influence of total applied power: (value between 0 and 1, 1
    % resulting in a large reduction)
    %reductionContactAngle = 1-(1.2244*(total_power/10^6)^2-1.3814*(total_power/10^6)+0.4025);
    %reductionContactAngle = 1
    %disp(1-(1.2244*(total_power/10^6)^2-1.3814*(total_power/10^6)+0.4025))
    %reductionContactAngle = reductionContactAngle*max(0,(-2e-05)*plasma_power^2 + 0.016*plasma_power - 2.2);
    %disp(max(0,(-2e-05)*plasma_power^2 + 0.016*plasma_power - 2.2))
    reductionContactAngle = 1-reductionContactAngle;
end
