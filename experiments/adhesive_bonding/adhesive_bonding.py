# Import required modules
import matlab.engine
import torch
from discrete_mixed_bo import optimize_function, get_experiment_config  # Import necessary functions from bo_pr

# Start MATLAB engine
eng = matlab.engine.start_matlab()

# Define the evaluation function for adhesive bonding
def evaluate_adhesive_bonding(x):
    # Convert input to MATLAB compatible format (assuming x is a list of input variables)
    x_matlab = matlab.double(x.tolist())
    
    # Extract individual values if necessary (depends on the MATLAB function requirements)
    pretreatment, posttreatment, material, dry_tissue, compressed_air, US_bath, degreasing, roughening, glue_type, sample_size, plasma, plasma_power, plasma_speed, plasma_distance, plasma_passes, time_between_plasma_glue, curing_time, curing_temperature, batch_size, number_repetitions, Width_plasma, general_noise, noise_factor_plasma, noise_curing, noise_material, wt_particles, curing_method, ind_current_bonding = x_matlab
    
    # Call the main MATLAB function (e.g., bondingModel2) that evaluates the process
    tensile_strength, failure_mode, visual_quality, cost, feasibility, final_contact_angle = eng.bondingModel2(
        pretreatment, posttreatment, material, dry_tissue, compressed_air, US_bath, degreasing, roughening, glue_type,
        sample_size, plasma, plasma_power, plasma_speed, plasma_distance, plasma_passes, time_between_plasma_glue,
        curing_time, curing_temperature, batch_size, number_repetitions, Width_plasma, general_noise,
        noise_factor_plasma, noise_curing, noise_material, wt_particles, curing_method, ind_current_bonding
    )

    # Return only the tensile strength as the objective to be optimized
    return float(tensile_strength)

# Define the experiment in bo_pr
def run_experiment():
    try:
        # Get experiment configuration for adhesive bonding
        experiment_config = get_experiment_config("adhesive_bonding")
        
        # Set up bounds for the adhesive bonding problem based on experiment configuration
        bounds = torch.tensor(experiment_config['bounds'])

        # Define an initial dataset if provided in the experiment configuration
        initial_data = torch.tensor(experiment_config['initial_data']) if 'initial_data' in experiment_config else torch.rand(10, len(bounds))  # Example: 10 initial points

        # Run Bayesian optimization using bo_pr
        result = optimize_function(
            evaluate_adhesive_bonding,  # Objective function
            bounds=bounds,  # Bounds for each parameter
            initial_data=initial_data,  # Initial dataset
            num_iterations=experiment_config.get('num_iterations', 100)  # Number of iterations to run
        )
        
        # Output the final result
        print("Optimization result:", result)
    finally:
        # Stop MATLAB engine after running the experiment to ensure cleanup
        eng.quit()

# If executed as main script, run the experiment
if __name__ == "__main__":
    run_experiment()
