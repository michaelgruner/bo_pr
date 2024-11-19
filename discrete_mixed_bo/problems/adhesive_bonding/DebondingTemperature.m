function [heating_temp,final_temp] = InductionTemperature(wt_particles, ind_current, ind_time, cooling_time, T_room)
%Temperature rise in time
c0=(0.01154735*wt_particles.^2+0.64333766*wt_particles-0.07553875*ind_current.^2+4.77484112*ind_current-2.68177434);
c1=(0.00127680929* ind_current.^2 +0.0718775426*ind_current + 0.00972668861*wt_particles.^2 - 0.339655898 *wt_particles +48.9205624);
c2=(-0.000018083791*ind_current^2 +0.00111871093*ind_current -0.000000542074526*wt_particles.^2+0.000225841690*wt_particles - 0.0110340346);

r=0.00525374; % if min T = 50°C r=0.0128135 / if min T = 23°C (room T) r=0.005253743


noise_temp = (10*rand()-5);

heating_temp = c0+(c1-c0)*exp(-c2*ind_time)+ noise_temp; % assumption temperature can randomly vary +-5°C;

if (wt_particles ==0 |ind_current==0 |ind_time ==0) % if one of these values = 0, no induction is applied and the T should be equal to room temp
    heating_temp=T_room;

end
final_temp=T_room+(heating_temp-T_room)*exp(-r*cooling_time);%+(10*rand()-5)% assumption temperature can randomly vary +-5°C
    
end

