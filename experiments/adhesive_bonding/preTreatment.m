
function [contactAngle] = preTreatment(material, dry_tissue, compressed_air, US_bath, degreasing, general_noise) %plasma_power, roughening, noise_factor_plasma)
% This function calculates the effect of cleaning and pretreatment
% conditions on the contact angle of different substrates. The following
% materials will be considered: Plastics (ABS, PPS), metals (Aluminum), and
% composites (Glass fiber reinforced epoxy)

%Step 1: Assign an initial mean contact angle based on the type of material(literature based)
if strcmp(material,'PPS')
    initialContactAngle = 80; % degrees. From previous code
    stdevContactAngle = general_noise; % percent, initial value = 9%
    Reduc_CA_cleaning_dry_tissue=0.835; %% experimentally determined
    Reduc_CA_cleaning_compressed_air=0.662; %% experimentally determined
    Reduc_CA_cleaning_US_bath=1; %% US bath is not applicable for PPS, so pass the initial mean contact angle
    Reduc_CA_cleaning_degreasing=0.9; %%from the previous code
elseif strcmp(material,'ABS')
    initialContactAngle = 70; % degrees. Experimentally determined
    stdevContactAngle = general_noise; % percent, initial value = 9%
    Reduc_CA_cleaning_dry_tissue=0.921; %% experimentally determined
    Reduc_CA_cleaning_compressed_air=0.982; %%experimentally determined
    Reduc_CA_cleaning_US_bath=1; %%not applicable for ABS, so pass the initial mean contact angle
    Reduc_CA_cleaning_degreasing=0.9; %%from the previous code
elseif strcmp (material,'Aluminum')
    initialContactAngle = 90; %degrees - experimentally determined and align with the following papers: 10.3390/molecules14104087, 10.1016/j.ijadhadh.2014.07.007, 10.3390/molecules14104087, 10.3390/ma13102240
    stdevContactAngle = general_noise; % percent, initial value = 9%
    Reduc_CA_cleaning_dry_tissue=0.897; %%experimentally determined
    Reduc_CA_cleaning_compressed_air=0.957; %%experimentally determined
    Reduc_CA_cleaning_US_bath=0.962; %%experimentally determined
    Reduc_CA_cleaning_degreasing=0.863; %%experimentally determined
elseif strcmp (material,'GFRE')
    initialContactAngle = 78; %degrees - experimentally determined and align with the following paper: 10.1016/j.apsusc.2006.10.049
    stdevContactAngle = general_noise; % percent, initial value = 9%
    Reduc_CA_cleaning_dry_tissue=0.772; %%experimentally determined
    Reduc_CA_cleaning_compressed_air=0.956; %%experimentally determined
    Reduc_CA_cleaning_US_bath=1; %%not applicable for GFRE - pass the initial contact angle value
    Reduc_CA_cleaning_degreasing=0.952; %%experimentally determined
else
    disp([material, 'not known'])
end

%step 2: calculate the new mean contact angle based on the selected pretreatment/cleaning methods. The choice is between
%dry tissue, compressed air, solvant degreasing, US bath.
if (dry_tissue)
   meanContactAngle =  Reduc_CA_cleaning_dry_tissue*initialContactAngle; %  reduces the mean contact angle 
   stdevContactAngle = 0.67*stdevContactAngle; % reduces the variation on the samples
elseif (compressed_air)
   meanContactAngle = Reduc_CA_cleaning_compressed_air*initialContactAngle; % reduces the mean contact angle 
   stdevContactAngle = 0.67*stdevContactAngle; %  reduces the variation on the samples
elseif (US_bath)
   meanContactAngle = Reduc_CA_cleaning_US_bath*initialContactAngle; %  reduces the mean contact angle 
   stdevContactAngle = 0.67*stdevContactAngle; %  reduces the variation on the samples
elseif(degreasing)
   meanContactAngle = Reduc_CA_cleaning_degreasing*initialContactAngle; % reduces the mean contact angle 
   stdevContactAngle = 0.67*stdevContactAngle; %  reduces the variation on the samples
else
    meanContactAngle=initialContactAngle;
    stdevContactAngle=general_noise;
end

%Step 3:Calculate the final contact andgle
contactAngle = meanContactAngle+(stdevContactAngle/100*meanContactAngle)*randn();

end
