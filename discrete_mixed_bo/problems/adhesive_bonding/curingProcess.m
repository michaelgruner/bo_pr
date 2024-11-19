function [strength] = curingProcess(curing_temperature, curing_time, noise_curing, wt_particles)

% 1. Maximal achievable strength at specific curing temperature after
% endless time
max_strength = 7.3382*log(curing_temperature) - 6.4901; % for Araldite 2011



% 2. Percentage cured after curing time, at temperature
b = 9e06*(curing_temperature).^(-3.461);
percentage = curing_time/(curing_time+b);

strength = max_strength*percentage;
strength = strength+noise_curing*strength*randn(); % initial value noise_curing = 0.005

% 3. Strength reduction by adding particles
percentage_strength=(-0.3256*(wt_particles/100))+1; % experimentally fitted on reduction of strength for Araldite cured at 100°C + 3 wt% 0 - 30% -50%
strength = percentage_strength*strength;

end