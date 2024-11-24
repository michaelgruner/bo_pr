function [tensileStrength, failureMode,VisualQ, cost, Feasibility,FinalcontactAngle] = bondingModel2(pretreatment,posttreatment,material, dry_tissue, compressed_air, US_bath, degreasing, roughening, glue_type, sample_size, plasma, plasma_power, plasma_speed, plasma_distance, plasma_passes, time_between_plasma_glue,curing_time, curing_temperature, batch_size, number_repetitions,Width_plasma, general_noise, noise_factor_plasma,noise_curing, noise_material,wt_particles,curing_method,ind_current_bonding,ind_current_debonding,ind_time_debonding, order)
% This function predicts the final strength of two bonded samples after
% applying an adhesive bonding process with the given process parameters
% Inputs:
% - material: The material of the samples to be joined. Only 'PPS' is valid for now.
% - glue_type: The specific glue used for the bonding. Only 'Araldite' or 'Adekit' are valid for now.
% - sample_size [mm]: The width of the samples, i.e. the length of the bond.
% - degreasing [0-1]: Whether the sample is degreased with IPA before the plasma process.
% - plasma_power [W]: Power setting of the plasma torch [0, 300-500].
% - plasma_speed [mm/s]: The speed at which the plasma torch moves over the sample.
% - plasma_distance [mm]: The distance between the plasma torch nozzle and the sample.
% - plasma_passes: The number of passes of the plasma torch over the sample.
% - time_between_plasma_glue [min]: The time between the plasma treatment and the glue application during which the pretreatment effect can wear out.
% - curing_time [min]: The amount time that the sample is put in the curing oven.
% - curing_temperature [°C]: The temperature setting of the curing oven.
%
% Output:
% - tensileStrength [MPa]: The final breaking strength
% - failureMode: Adhesion failure (1), Glue failure (2)

%step 1: Calculate contact angle based on pretreatment and treatment order
		%Order 1: material as received- bonding
		%Order 2: material as received - Pretreatment - bonding  --> already included in the current model for PPS and ABS.
		%Order 3: material as received - Pretreatment - plasma treatment - bonding --> already included in the current model PPS and ABS.
		%Order 4: material as received - Pretreatment - roughening - bonding
		%Order 5: material as received - Pretreatment - roughening - PostTreatment - bonding
		%Order 6: material as received - Pretreatment - roughening - PostTreatment - plasma treatment - bonding
% Order of the pretreatment processes
if (material =="PPS"|| material == "ABS") % for plastics, the avaiable orders are 1, 2, and 3
    if(pretreatment ==0 && plasma==0)
        order = 1; %input('select order number:');
    elseif (pretreatment==1 && plasma==0)
       order = 2;
    elseif (pretreatment==1 && plasma==1)
        order =3;
    else fprintf (['***error - check the predefined bonding order***\n'...
            'Available bonding order for PPS and ABS substrates:\n',...    
            '1 = material as received - bonding \n',...
            '2 = material as received - pretreatment - bonding \n',...
            '3 = material as received - pretreatment - plasma treatment - bonding']);
    end
elseif (material =="GFRE") % for composites, the avaiable orders are 1, 2, 3, 4, 5 and 6
     if(pretreatment ==0 && plasma==0 && roughening ==0&& posttreatment ==0)
       order = 1;
    elseif (pretreatment ==1 && plasma==0 && roughening ==0&& posttreatment ==0)
       order = 2;
    elseif (pretreatment ==1 && plasma==1 && roughening ==0&& posttreatment ==0)
       order = 3;
    elseif (pretreatment ==1 && plasma==0 && roughening ==1&& posttreatment ==0)
       order = 4;
    elseif (pretreatment ==1 && plasma==0 && roughening ==1 && posttreatment ==1)
       order = 5;
    elseif (pretreatment ==1 && plasma==1 && roughening ==1 && posttreatment ==1)
       order = 6;
    else fprintf (['***error - check the predefined bonding order***\n'...
            'Available bonding order for GFRE substrates:\n',...    
            '1 = material as received - bonding \n',...
            '2 = material as received - pretreatment - bonding \n',...
            '3 = material as received - pretreatment - plasma treatment - bonding\n',...
            '4 = material as received - pretreatment - roughening - bonding\n',...
            '5 = material as received - pretreatment - roughening - posttreatment - bonding\n',...
            '6 = material as received - pretreatment - roughening - posttreatment - plasma treatment - bonding']);
     end
    Reduc_CA_rough_noPostCleaning=1.04; %experimentally determined
    Reduc_CA_rough_withPostCleaning=0.933; %(based on 10.1016/j.apsusc.2006.10.049 - new value experimentally determined)
elseif (material == 'Aluminum') %for Aluminum, the available orders are 1, 2, 4, and 5
     if(pretreatment ==0 && plasma==0 && roughening ==0 && posttreatment ==0)
       order = 1;
     elseif (pretreatment ==1 && plasma==0 && roughening ==0 && posttreatment ==0)
       order = 2;
     elseif (pretreatment ==1 && plasma==0 && roughening ==1 && posttreatment ==0)
       order = 4;
     elseif (pretreatment ==1 && plasma==0 && roughening ==1 && posttreatment ==1)
       order = 5;
     else fprintf (['***error - check the predefined bonding order***\n'...
            'Available bonding order for Aluminum substrates:\n',...
            '1 = material as received - bonding \n',...
            '2 = material as received - pretreatment - bonding \n',...
            '4 = material as received - pretreatment - roughening- bonding\n',...
            '5 = material as received - pretreatment - roughening - posttreatment - bonding']);
    end
    Reduc_CA_rough_noPostCleaning=0.161; %experimentally determined
    Reduc_CA_rough_withPostCleaning=0.745; %(based on 10.1016/j.npe.2019.03.008 - new value experimentally determined)
end

if order == 1 %% material as received- bonding
    FinalcontactAngle = preTreatment(material, dry_tissue, compressed_air, US_bath, degreasing, general_noise);
elseif order == 2 %%material as received - cleaning - bonding
    FinalcontactAngle = preTreatment(material, dry_tissue, compressed_air, US_bath, degreasing, general_noise);
elseif order ==3 %%material as received - cleaning - plasma treatment - bonding
    FinalcontactAngle = (preTreatment(material, dry_tissue, compressed_air, US_bath, degreasing, general_noise)*plasmaTreatment(sample_size,plasma_power,plasma_distance/10,plasma_passes,plasma_speed))+agingPlasmaTreatment(time_between_plasma_glue);
elseif order==4 %%material as received - cleaning - roughening- bonding
    FinalcontactAngle = preTreatment(material, dry_tissue, compressed_air, US_bath, degreasing, general_noise)*Reduc_CA_rough_noPostCleaning;
elseif order ==5 %%material as received - cleaning - roughening - cleaning - bonding
    FinalcontactAngle = preTreatment(material, dry_tissue, compressed_air, US_bath, degreasing, general_noise)*Reduc_CA_rough_noPostCleaning*Reduc_CA_rough_withPostCleaning;
elseif order ==6 %%material as received - cleaning- roughening - cleaning - plasma treatment - bonding
    FinalcontactAngle = (preTreatment(material, dry_tissue, compressed_air, US_bath, degreasing, general_noise)*Reduc_CA_rough_noPostCleaning*Reduc_CA_rough_withPostCleaning*plasmaTreatment(sample_size,plasma_power,plasma_distance/10,plasma_passes,plasma_speed))+agingPlasmaTreatment(time_between_plasma_glue);
end

% Step 2: Applying the adhesive, influence of adhesive type (neglected),
% temperature and humidity. We won't assume an influence of temperature and humidity at the moment
stress_adhesion = contactAngle_Stress(FinalcontactAngle);

% Step 3: temperatuur en tijd in oven
% stress_glue = Inf
stress_glue = curingProcess(curing_temperature, curing_time, noise_curing, wt_particles);
        
% Step 4: Cost calculation
cost = cost_calculator(dry_tissue, compressed_air, US_bath, degreasing, roughening, pretreatment, posttreatment, sample_size, plasma, plasma_power, plasma_speed, plasma_passes, curing_time, curing_temperature, batch_size, number_repetitions, glue_type, curing_method, ind_current_bonding, ind_current_debonding, wt_particles, ind_time_debonding);
        
%Step 5: Visual Quality inspection
[VisualQ] = MaxSampleTemperature(material, plasma_speed, Width_plasma, plasma_power, plasma_distance);
        
% Results      
[failureMode, mat_strength ]= failureMech(material,stress_adhesion, stress_glue, noise_material);
[stress] = min([stress_adhesion, stress_glue, mat_strength]);

tensileStrength = stress;
Feasibility = 1; % feasibility is not working for ABS

end

