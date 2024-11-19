% Cost calculation model developed by Jeroen Jordens (Flanders Make) and
% implemented by Bart Van Doninck (Flanders Make) within the scope of the
% Flanders AI initiative (GC1 - Use case: JMLab)

function [cost] = cost_calculator(dry_tissue, compressed_air, US_bath, degreasing, roughening, pretreatment, posttreatment, sample_size,plasma, plasma_power, plasma_speed, plasma_passes, curing_time, curing_temperature, batch_size, number_repetitions, glue_type, curing_method, ind_current_bonding, ind_current_debonding, wt_particles, ind_time_debonding)

% Fixed parameters:
OPERATOR_DAYS = 200;        %Available working days
OPERATOR_HOURS_DAY = 8;     %Operator working hours per day
OPERATOR_HOURS_TOTAL = OPERATOR_DAYS*OPERATOR_HOURS_DAY;       %Available operator hours per year
HIGH_OPERATOR_WAGE = 90000; %Yearly salary of educated production planner
LOW_OPERATOR_WAGE = 60000;  %Yearly salary of production operator
SAMPLES_BATCH = 30;         %Number of samples per batch
BATCH_TIME = 2;             %Hours to complete the batch
ELECTRICITY_COST_KWH = 0.2;

%% Planning costs

PLANNER_COST_HOUR = HIGH_OPERATOR_WAGE/OPERATOR_HOURS_TOTAL;            %Planner cost/hour
PLANNER_COST_SAMPLE = BATCH_TIME/SAMPLES_BATCH*PLANNER_COST_HOUR;      %Planner cost/sample
OPERATOR_COST_HOUR = LOW_OPERATOR_WAGE/OPERATOR_HOURS_TOTAL;            %Planner cost/hour
OPERATOR_COST_SAMPLE = BATCH_TIME/SAMPLES_BATCH*OPERATOR_COST_HOUR;      %Planner cost/sample

cost_planning = PLANNER_COST_SAMPLE/number_repetitions;

%% Cleaning costs 

% Fixed parameters:
IPA_SOLVENT_COST = 450;     %Cost per bottle
IPA_SOLVENT_VOLUME = 200;   %Volume of IPA bottle
IPA_SOLVENT_CONSUMPTION = 0.01;   %IPA Consumption: 10mL/sample
IPA_SOLVENT_COST_LITER = IPA_SOLVENT_COST/IPA_SOLVENT_VOLUME;                 %IPA cost/liter
IPA_SOLVENT_COST_SAMPLE = IPA_SOLVENT_COST_LITER*IPA_SOLVENT_CONSUMPTION;     %IPA cost/sample

LINT_FREE_TISSUE_COST = 5.5;   %Cost lint-free tissues
LINT_FREE_TISSUE_AMOUNT = 200; %Amount of lint-free tissues per pack
LINT_FREE_TISSUES_CONSUMPTION = 2;  %Consumption of tissues per sample
LINT_FREE_TISSUE_COST_AMOUNT = LINT_FREE_TISSUE_COST/LINT_FREE_TISSUE_AMOUNT; %Cost of one lint-free tissue
LINT_FREE_TISSUE_COST_SAMPLE = LINT_FREE_TISSUE_COST_AMOUNT*LINT_FREE_TISSUES_CONSUMPTION; %Tissue cost/sample

COMPRESSOR_TANK_CAPACITY=30; %Liters
FLOW_RATE = 80; %liter/min
COMPRESSOR_POWER = 750; %Watts
TIME_TO_FILL_TANK = COMPRESSOR_TANK_CAPACITY/FLOW_RATE; %in minutes
COST_COMPRESSED_AIR_HOUR=(TIME_TO_FILL_TANK/60)*(COMPRESSOR_POWER/1000)*ELECTRICITY_COST_KWH; %cost per hour

COST_DEMI_WATER_LITER = 0.24; %euros/liter
US_TANK_CAPACITY = 2.5; %Liters
TOTAL_DEMI_WATER_COST = COST_DEMI_WATER_LITER*US_TANK_CAPACITY; %euros
US_OPERATING_TIME = 30; %minutes
POWER_US_HEATING = 100; %Watts
POWER_US_ULTRASOUND = 120; %Watts
COST_US_BATH_HEATING =(US_OPERATING_TIME/60)*(POWER_US_HEATING/1000)*ELECTRICITY_COST_KWH;
COST_US_BATH_ULTRASOUND = (US_OPERATING_TIME/60)*(POWER_US_ULTRASOUND/1000)*ELECTRICITY_COST_KWH;
TOTAL_COST_US_BATH = TOTAL_DEMI_WATER_COST+COST_US_BATH_HEATING+COST_US_BATH_ULTRASOUND;
%-----
cost_degreasing = degreasing*(30/60/60*OPERATOR_COST_HOUR+LINT_FREE_TISSUE_COST_SAMPLE+IPA_SOLVENT_COST_SAMPLE);
cost_dry_tissue = dry_tissue*(30/60/60*OPERATOR_COST_HOUR+LINT_FREE_TISSUE_COST_SAMPLE);
cost_compressed_air = compressed_air*(30/60/60*(OPERATOR_COST_HOUR+COST_COMPRESSED_AIR_HOUR));
cost_US_bath = US_bath*((30/60/60*OPERATOR_COST_HOUR)+TOTAL_COST_US_BATH); %assuming the operator takes 30 seconds to place the sample in the bath

cost_pretreatment = pretreatment*sum([cost_degreasing,cost_dry_tissue,cost_compressed_air,cost_US_bath]);
cost_posttreatment = posttreatment*cost_pretreatment;


%% Roughening costs

COST_GRINDING_PAPER = 3; %Euros
POWER_GRINDING_MACHINE = 500; %Watts
TIME_GRINDING_SAMPLE = 30; %seconds
COST_GRINDING = (TIME_GRINDING_SAMPLE/60/60)*(POWER_GRINDING_MACHINE/100)*ELECTRICITY_COST_KWH; %Euros
TOTAL_ROUGHENING_COST = COST_GRINDING_PAPER+COST_GRINDING; %Eruos

cost_roughening = roughening*((TIME_GRINDING_SAMPLE/60/60*OPERATOR_COST_HOUR)+TOTAL_ROUGHENING_COST);

%% Plasma costs

% Fixed parameters:
PLASMA_COST = 29900;    %Cost of plasma device
PLASMA_DEPRECIATION = 10;   %Depreciation period (in years)
PLASMA_OCCUPANCY = 0.6;    %Occupancy of the machine [0-1]
PLASMA_USAGE = OPERATOR_DAYS*OPERATOR_HOURS_DAY*PLASMA_OCCUPANCY;     %Usage hours per year
PLASMA_COST_SEC = PLASMA_COST/PLASMA_DEPRECIATION/PLASMA_USAGE/3600;  %Usage cost of plasma machine per second

YASKAWA_COST = 39845;      % Cost of Yaskawa robot
YASKAWA_DEPRECIATION = 10;  % Depreciation period (in years)
YASKAWA_OCCUPANCY = 0.6;    % Occupancy of the machine [0-1]
YASKAWA_USAGE = OPERATOR_DAYS*OPERATOR_HOURS_DAY*YASKAWA_OCCUPANCY;    %Usage hours per year
YASKAWA_COST_SEC = YASKAWA_COST/YASKAWA_DEPRECIATION/YASKAWA_USAGE/3600; % Usage cost of yaskawa robot per second
%-----

plasma_time = sample_size/plasma_speed*plasma_passes;
electricity_cost = plasma_time/3600*plasma_power/1000*ELECTRICITY_COST_KWH;
equipment_cost = plasma_time*PLASMA_COST_SEC;
operator_cost = (plasma_time+34)/3600*OPERATOR_COST_HOUR;
robot_cost = (plasma_time)*YASKAWA_COST_SEC;
cost_plasma = plasma*(plasma_power>0)*(electricity_cost+equipment_cost+operator_cost+robot_cost);

%% Adhesive costs
if (glue_type=="Araldite")
    ADHESIVE_COST = 21.25;      % Cost of adhesive container Araldite: 22.08[€], Adekit 21.25 EUR
    ADHESIVE_VOLUME = 0.4;     % Volume of adhesive in the container 0.05L for Araldite 0.4L for Adekit [L]
elseif (glue_type=="Adekit")
    ADHESIVE_COST = 21.25;      % Cost of adhesive container Araldite: 22.08[€], Adekit 21.25 EUR
    ADHESIVE_VOLUME = 0.4;     % Volume of adhesive in the container 0.05L for Araldite 0.4L for Adekit [L]
end
STATIC_MIXER_COST = 1.77;    % Cost of static mixer piece [€]
STATIC_MIXER_CONSUMPTION = 1/120;   % Consumption of static mixers per sample
STATIC_MIXER_COST_SAMPLE = STATIC_MIXER_COST*STATIC_MIXER_CONSUMPTION;   % Cost of static mixer per sample
ADHESIVE_CONSUMPTION = 0.05/120;    % Consumption of adhesive per sample [L/sample]
ADHESIVE_COST_SAMPLE = ADHESIVE_COST/ADHESIVE_VOLUME*ADHESIVE_CONSUMPTION; % Adhesive cost per sample
PARTICLES_COST=25; % cost = 25EUR/kg particles
ADHESIVE_MASS=(ADHESIVE_CONSUMPTION/1000)*1.05; % kg of adhesive used (specific density Araldite = 1.05 kg/m³ / 1L=0.001m³)
PARTICLES_MASS=ADHESIVE_MASS*wt_particles;

cost_particles=PARTICLES_MASS*PARTICLES_COST;
cost_adhesive = (30/3600*OPERATOR_COST_HOUR+STATIC_MIXER_COST_SAMPLE+ADHESIVE_COST_SAMPLE+cost_particles);

%% Curing costs

%Fixed parameters
OVEN_COST = 21839;       % Cost of curing oven [€]
OVEN_DEPRECIATION = 10;  % Depreciation period (in years)
OVEN_OCCUPANCY = 0.6;    % Occupancy of the curing oven [0-1]
OVEN_USAGE = 365*24*OVEN_OCCUPANCY;    % Usage hours per year
OVEN_COST_SEC = OVEN_COST/OVEN_DEPRECIATION/OVEN_USAGE/3600;   % Cost of the curing oven per second

INDUCTION_COST= 28400.50; %cost of induction heating device
INDUCTION_DEPRECIATION = 10; % Depreciation period (in years)
INDUCTION_OCCUPANCY = 0.6;    % Occupancy of the induction heating [0-1]
INDUCTION_USAGE = OPERATOR_DAYS*OPERATOR_HOURS_DAY*INDUCTION_OCCUPANCY;    % Usage hours per year
INDUCTION_COST_SEC = ((INDUCTION_COST/INDUCTION_DEPRECIATION)/INDUCTION_USAGE)/3600;   % Cost of the induction heating per second
%----

if contains(curing_method, 'oven')
    electricity_cost = curing_time/60*2.0115*exp(0.0086*curing_temperature)*ELECTRICITY_COST_KWH;
    operator_cost = 60/3600*OPERATOR_COST_HOUR;
    oven_cost = curing_time*60*OVEN_COST_SEC;
    cost_curing = (electricity_cost + operator_cost + oven_cost)*ceil(batch_size/30)/batch_size;
elseif contains(curing_method, 'induction')
    INDUCTION_ELEC_POWER_KW=(0.1135*exp(0.1198*ind_current_bonding))/0.95; % Calculates the electrical power based on induction current + power factor of 0.95
    INDUCTION_ELEC_POWER_KWH=INDUCTION_ELEC_POWER_KW*(curing_time/60);
    electricity_cost = INDUCTION_ELEC_POWER_KWH*ELECTRICITY_COST_KWH;
    operator_cost = (0.5/60)*OPERATOR_COST_HOUR; % assumption 30s needed for setting up equipment + loading/unloading sample
    induction_cost= curing_time*60*INDUCTION_COST_SEC;
    cost_curing=(electricity_cost + operator_cost + induction_cost);
    
else disp("no suitable curing method selected");    
end

%% Debonding costs
INDUCTION_ELEC_POWER_KW=(0.1135*exp(0.1198*ind_current_debonding))/0.95; % Calculates the electrical power based on induction current + power factor of 0.95
INDUCTION_ELEC_POWER_KWH=INDUCTION_ELEC_POWER_KW*(ind_time_debonding/60);
electricity_cost = INDUCTION_ELEC_POWER_KWH*ELECTRICITY_COST_KWH;
operator_cost = (0.5/60)*OPERATOR_COST_HOUR; % assumption 30s needed for setting up equipment + loading/unloading sample
induction_cost= ind_time_debonding*60*INDUCTION_COST_SEC;
cost_debonding=(electricity_cost + operator_cost + induction_cost);


%% Total costs
cost = cost_planning+cost_pretreatment+cost_posttreatment+cost_roughening+cost_plasma+cost_adhesive+cost_curing+cost_debonding;

% figure
% bar([cost_planning; cost_cleaning; cost_plasma; cost_adhesive; cost_curing]);
end