function [Q] = MaxSampleTemperature(material, plasma_speed, Width_plasma, plasma_power, plasma_distance)
%Temperature rise in time
exp_time = (Width_plasma)/(plasma_speed);

% Calculate C0, c1 & C2
x = plasma_power;
y = plasma_distance/10;
c0 = (4.14694232e-08)*(x^3.31780113e+00)*(y^-2)+(4.69548065e+01)/y+2.45352045e+00;
c1 = -0.00728638*x+3.11811122*y+2.291634;
c2 = -1.04713645e-01*x+1.97237962e-07*(y^-3.94140029e+01)-2.09242689e+00*y+(-2.50777618e+03+2.57739004e+03);

% Calculate sample temperature
T_sample = c0*log(c1+c2*exp_time)+(2.5*randn()); % assumption is that temperature can randomly vary +- 5°C

if material =="PPS"
    T_max = 260; % 260°C for PPS based on https://www.solvay.com/en/brands/ryton-pps/properties
elseif material =="ABS"
    T_max = 180;
elseif material =="GFRE"
    T_max = 140;
elseif material == "Aluminum"
    T_max = 700;
end

if T_sample > T_max
    Q = 'NOK';
else Q = 'OK';
end

end

