%% code initiation setting----
clc; clear all; close all;
visualisation = true; % function to plot effect 1 variable on output parameters (break stress, cost, debonding stress, visual quality, type of failure)

%% noise parameters ---------
general_noise = 0.1; % noise factor to scale the level of noise on the initial contact angle of the material; initial setting = 9% stDev on contact angle 
noise_factor_plasma = 0.3; %noise factor to scale the level of noise during plasma treatment ; initial value = 1
noise_material = 0.4; % noise factor to scale the level of noise on strength of material initial value = 0.4. This is obtained from experimental values for substrate failure (so this should be OK)
noise_temp = 0.05*(10*rand()-5); % noise on temperature rise due to induction heating

%% Joint information: Adhesive and substrate materials----
material = 'GFRE'; % type of substrate material. 
valid_materials = {'PPS', 'ABS', 'Aluminum', 'GFRE'};% List of valid materials. Choice between PPS, ABS, Aluminum, GFRE.
sample_size = 25; % Sample width [mm]
glue_type = 'Araldite'; % Choice between 'Araldite' OR 'Adekit' OR 'DP190' only available
valid_adhesives = {'Araldite', 'Adekit', 'DP190'};% List of valid adheisves. hoice between 'Araldite' OR 'Adekit' OR 'DP190' only available.
%% Pretreatment------
%Pretreatment of the substrate surface: only ONE choice between dry tissue cleaning,compressed air, degreasing, US bath (this is material dependant)
pretreatment = 1; %a parameter to indicate whether pretreatment is used or not. Yes(1)/No(0). 
%If pretreatment = 0 --> then degreasing and dry_tissue and compressed_air and US_bath need to be set to 0
%If pretreatment = 1 --> then any of the parameters (degreasing, dry_tissue, compressed_air, US_bath) must be set to 1

%only one pretreatment method can be used
degreasing = 1; % pretreatment by solvant degreasing. Yes(1)/No(0) [Degreasing with IPA]
dry_tissue = 0; % pretreatment by cleaning with dry tissue. Yes(1)/No(0) [3 passes with clean dry tissue]
compressed_air = 0; %pretreatment by cleaning with compressed air. Yes(1)/No(0) [compressed air at 4 bars] 
US_bath = 0; %pretreatment using ultrasonic cleaning bath. Yes(1)/No(0) [at frequency = 35 Hz, temperature = 60 °C, time = 10 min] 

%% Surface treatment------
% plasma parameters:
plasma = 1;% a parameter to indicate whether the plasma treamtent is used or not. Yes(1)/No (0)
plasma_power = 400; % Plasma power [Watt] / range: 300-500
plasma_speed = 59; % Speed at which plasma nozzle moves over the sample [mm/s] / range: 5-250
plasma_distance = 5; % Distance between plasma nozzle and sample [mm] / range: 4-20
plasma_passes = 50; % Number of passes / range: 1-50
time_between_plasma_glue = 60; % Time between plasma and gluing [min] / range: 1-60
Width_plasma = 2; % assumption that plasma torch has width of 2 mm (tuned a little bit on experiments)

% roughness parameters:
roughening = 1; % a parameter to indicate whether roughening treamtent is used or not. Yes(1)/No(0). Using grit paper of grade P40 (fixed for now)
posttreatment = 1; % a parameter to indicate whether postcleaning after roughening treamtent is used or not. Yes(1)/No(0). posttreatment uses the same methods as the pretreatment

%% Curing parameters------
curing_time = 56; % Time during which samples are in the curing oven/induction [min] / range: 1-60
wt_particles = 46;% wt% curie particles added to allow induction heating (allowable range = 10-50%)
ind_current_bonding = 22;% induction curren [A] allowable range = 5-30 A
curing_method = 'oven'; % 'induction' or 'oven'
curing_temperature = 180; % Temperature of the curing oven[°C]
cooling_time = 30; % time needed to transfer sample from induction heating to test bench [s]
noise_curing = 0.005; % noise factor to scale the level of noise during curing is not expected to have an effect as we do not see cohesive failure; initial value = 0.005

%% debonding parameters:
ind_current_debonding =5;% induction curren [A] allowable range = 5-30 A
ind_time_debonding = 458; % time induction current is applied during debonding [s], allowable range = 1-600 s


%% fixed parameters (at the moment)----------------------------
%Batch information
T_room = 23; % temperature in the room [°C], standard = 23°C
batch_size = 30; %Standard = 30 samples/batch
number_repetitions = 5; %Number of repetitions for the same configuration (of a complete batch)

%% Error check for input parameters---------
disp('Checking for errors...');

disp('Checking for errors in joint information');
if ~ismember(material, valid_materials)
    disp('***Error. Material name is incorrect. Valid options are: PPS, ABS, Aluminum, GFRE***');
end
if ~ismember(glue_type, valid_adhesives)
    disp('***Error. Adhesive name is incorrect. Valid options are: Araldite, Adekit, DP190***');
end

disp('Checking for errors in pretreatment parameters...');
if any([pretreatment, degreasing, dry_tissue, compressed_air, US_bath] < 0) || any([pretreatment, degreasing, dry_tissue, compressed_air, US_bath] > 1)
    disp('***Error in pretreatment parametrs. Value must be between 0 and 1***');
end
if (sum([degreasing, dry_tissue, compressed_air, US_bath])>1)
    disp ('***Error. Only one pretreatment method can be used***');
end
if (pretreatment == 1 && sum([degreasing, dry_tissue, compressed_air, US_bath])<1)
    disp ('***Error. Select at least one pretreatment method***');
end
if (pretreatment == 0 && sum([degreasing, dry_tissue, compressed_air, US_bath])>=1)
    disp ('***Error. None of the pretreatment conditions should be active because Precleaning is set to 0***');
end

disp('Checking for errors in Plasma parameters...');

if (plasma < 0 || plasma > 1)
    disp('***Error. plasma variable must be between 0 and 1***');
end
if (plasma_power > 500 || plasma_power < 300)
    disp ('***Error. The parameter plasma_power is outside the range. The range of the plasma_power is between 300 and 500 Watts***')
end
if (plasma_speed>250 || plasma_speed<5)
    disp ('***Error. The parameter plasma_speed is outside the range. The range of the plasma_speed is between 5 and 250 mm/s***')
end
if (plasma_distance>20 || plasma_power<4)
    disp ('***Error. The parameter plasma_distance is outside the range. The range of the plasma_distance is between 4 and 20 mm***')
end
if (plasma_passes>50 || plasma_passes<1)
    disp ('***Error. The parameter plasma_passes is outside the range. The range of the plasma_passes is between 1 and 50***')
end
if (time_between_plasma_glue>60 || time_between_plasma_glue<1)
    disp ('***Error. The parameter time_between_plasma_glue is outside the range. The range of the time_between_plasma_glue is between 1 and 60 min***')
end
if (curing_time>60 || curing_time<1)
    disp ('***Error. The parameter curing_time is outside the range. The range of the curing_time is between 1 and 60 min***')
end

if any([roughening, posttreatment] < 0) || any([roughening, posttreatment] > 1)
    disp('***Error in roughening and posttreatment parameters. Variable must be between 0 and 1***');
end
disp('Checking for errors in weight particle parameter....');
if (wt_particles>50 || wt_particles<10)
    disp ('***Error. The parameter wt_particles is outside the range. The range of the wt_particles is between 10 and 50%***')
end

disp('Checking for errors in induction current parameter...');
if (ind_current_bonding>30 || ind_current_bonding<5)
    disp ('***Error. The parameter ind_current_bonding is outside the range. The range of the ind_current_bonding is between 5 and 30 A***')
end
if (ind_current_debonding>30 || ind_current_debonding<5)
    disp ('***Error. The parameter ind_current_debonding is outside the range. The range of the ind_current_debonding is between 5 and 30 A***')
end

disp('Checking for errors in debonding time parameter...');
if (ind_time_debonding>600 || ind_time_debonding<1)
    disp ('***Error. The parameter ind_time_debonding is outside the range. The range of the ind_time_debonding is between 1 and 600 s***')
end

disp ('-----------------------error check completed--------------------')
%% visualisation
%[tensileStrength, failureMode, cost, VisualQ, debonding_stress] 
[tensileStrength, failureMode,VisualQ, cost, Feasibility]= bondingModel2(pretreatment,posttreatment,material, dry_tissue, compressed_air, US_bath, degreasing, roughening, glue_type, sample_size, plasma, plasma_power, plasma_speed, plasma_distance, plasma_passes, time_between_plasma_glue,curing_time, curing_temperature, batch_size, number_repetitions,Width_plasma, general_noise, noise_factor_plasma,noise_curing, noise_material,wt_particles,curing_method,ind_current_bonding,ind_current_debonding,ind_time_debonding);

if(visualisation)
    
    % bonding parameters
    %curing_time = 1:1:60; % Time during which samples are in the curing oven/induction [min] / range: 1-60
    %wt_particles = 10:10:50;% wt% curie particles added to allow induction heatin (allowable range = 10-50%)
    %ind_current_bonding = 5:1:30;% induction curren [A] allowable range = 5-30 A

    % debonding parameters:
    %ind_current_debonding = 5:1:30;% induction curren [A] allowable range = 5-30 A
    %ind_time_debonding = 1:1:600; % time induction current is applied during debonding [s], allowable range = 1-600 s
    
    tensileStrengths = [];
    failureModes = {};
    costs = [];
    FinalcontactAngles = [];
    VisualQs = {};
    %debonding_stresses = [];

    range = 300:10:500;
    for  plasma_power = range 
        %[tensileStrength, failureMode, cost, VisualQ, debonding_stress] 
        [tensileStrength, failureMode, VisualQ, cost, Feasibility,FinalcontactAngle]= bondingModel2(pretreatment,posttreatment,material, dry_tissue, compressed_air, US_bath, degreasing, roughening, glue_type, sample_size, plasma, plasma_power, plasma_speed, plasma_distance, plasma_passes, time_between_plasma_glue,curing_time, curing_temperature, batch_size, number_repetitions,Width_plasma, general_noise, noise_factor_plasma,noise_curing, noise_material,wt_particles,curing_method,ind_current_bonding,ind_current_debonding,ind_time_debonding);
        tensileStrengths = [tensileStrengths; tensileStrength];
        failureModes{end+1} = failureMode;
        costs = [costs; cost];
        FinalcontactAngles = [FinalcontactAngles; FinalcontactAngle];
        VisualQs{end+1} = VisualQ;
        %debonding_stresses = [debonding_stresses; debonding_stress];
    end
    %show final results
    tensileStrengths
    failureModes
    costs
    FinalcontactAngles
    VisualQs
    
    %plot final results
    f = categorical(failureModes);
    [labels_failureModes, ~, F] = unique(f);
  
    v = categorical(VisualQs);
    [labels_VisualQ, ~, V] = unique(v);

    figure
    
    subplot(321)
    plot(range, tensileStrengths)
    title('Tensile Strength [MPa]')
    
    subplot(322)
    plot(range, f)
    yticklabels = labels_failureModes;
    title('Failure Modes')
    
    subplot(323)
    plot(range, costs)
    title('Cost [EUR]')
    
    subplot(324)
    plot(range, v)
    yticklabels = labels_VisualQ;
    title('Visual Quality')
    
    subplot(325)
    plot(range, FinalcontactAngles)
    title('Contact Angle')
    
    %subplot(326)
    %plot(range, debonding_stresses)
    %title('Debonding stress [MPa]')
end