function [debonding_stress] = DebondingStress(wt_particles, ind_current, ind_time, cooling_time, T_room, max_stress, noise_temp)




% debonding temperature is:
[heating_temp,T_debond] = InductionTemperature(wt_particles, ind_current, ind_time, cooling_time,T_room, noise_temp);

heating_temp;
% percentage of stress left by induction heating

pct=94.738*T_debond^-1.508;      % old equation: pct=-0.8738+3.9369*exp(-0.07169*T_debond)

%debonding stress:
stress_debonding=pct*max_stress;
%if stress_debonding<0 
%    debonding_stress=0;
%else debonding_stress =stress_debonding;
debonding_stress=stress_debonding;
end