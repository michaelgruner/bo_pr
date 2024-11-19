function [failureMode, mat_strength] = failureMech(material, stress_adhesion, stress_glue, noise_material)
%calculation failure mode sample
%   
    if strcmp(material,'PPS')
        mat_strength =140+noise_material*randn(); %MPa - average value of the tensile strength
    elseif strcmp(material,'ABS')
        mat_strength = 45+noise_material*randn(); %MPa - average value of the tensile strength
    elseif strcmp(material,'Aluminum')
        mat_strength = 200+noise_material*randn(); %MPa - average value of the tensile strength
    else mat_strength = 300+noise_material*randn(); %MPa - average value of the tensile strength for GFRE
    end
       %failureMode = 'unknown';
    %else mat_strength = 7+noise_material*randn(); % not corresponding to theoretical value but because of bending forces introduced during testing, this strength is reduced to experimental value; initial value = 0.4
    %end
    if mat_strength < min(stress_adhesion, stress_glue) 
        failureMode = 'substrate failure';
    elseif stress_adhesion < min(stress_glue, mat_strength)
        failureMode = 'adhesive failure';
    else failureMode = 'cohesive failure'; 
        
    end
end

