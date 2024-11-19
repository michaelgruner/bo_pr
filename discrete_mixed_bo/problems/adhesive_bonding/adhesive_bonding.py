# Import required modules
import matlab
import torch

from discrete_mixed_bo.problems.base import DiscreteTestProblem

# Start MATLAB engine
eng = matlab.engine.start_matlab()

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

class AdhesiveBonding(DiscreteTestProblem):

    def __init__(
        self,
        noise_std: Optional[float] = None,
        negate: bool = False,
        named_bounds: Dict = {}
    ) -> None:
        self._named_bounds = named_bounds

        # Build the bounds array using only the bounds member, discarding the fixed values
        self._bounds = [
            item["bounds"]
            for key, item in named_bounds.items()
            if item["type"] in {"integer", "categorical", "continuous"}
        ]

        def extract_indices(bounds, named_bounds, of_type):
            return [
                idx
                for idx, item in enumerate(bounds)
                if any(
                        bound_item["bounds"] == item and bound_item["type"] == of_type
                        for bound_item in named_bounds.values()
                )
            ]

        integer_indices = extract_indices(self._bounds, named_bounds, "integer")
        categorical_indices = extract_indices(self._bounds, named_bounds, "categorical")
        # Continuous indices will be automatically deducted by the base class

        super().__init__(noise_std, negate, integer_indices, categorical_indices)

    def evaluate_true(self, X: Tensor) -> Tensor:
        # Convert input to MATLAB compatible format (assuming x is a list of input variables)
        x_matlab = matlab.double(X.tolist())

        # Same ordering as the instantiation
        curing_time, ind_current_bonding, plasma_distance, Plasma_passes, plasma_power, plasma_speed, time_between_plasma_glue, wt_particles, curing_method, compressed_air, degreasing, dry_tissue, US_bath, glue_type, material, Plasma, pretreatment, roughening, noise_curing, posttreatment = x_matlab

        # Map categorical values
        curing_method = self._named_bounds['curing_method']['mapping'][curing_method]
        glue_type = self._named_bounds['glue_type']['mapping'][glue_type]
        material = self._named_bounds['material']['mapping'][material]
        #order = self._named_bounds['order']['mapping'][order]
        noise_curing = self._named_bounds['noise_curing']['mapping'][noise_curing]

        # Fixed values
        batch_size = self._named_bounds["batch_size"]["bounds"]
        cooling_time = self._named_bounds["cooling_time"]["bounds"]
        curing_temperature = self._named_bounds["curing_temperature"]["bounds"]
        general_noise = self._named_bounds["general_noise"]["bounds"]
        noise_factor_plasma = self._named_bounds["noise_factor_plasma"]["bounds"]
        noise_material = self._named_bounds["noise_material"]["bounds"]
        noise_temp = self._named_bounds["noise_temp"]["bounds"]
        number_repetitions = self._named_bounds["number_repetitions"]["bounds"]
        sample_size = self._named_bounds["sample_size"]["bounds"]
        T_room = self._named_bounds["T_room"]["bounds"]
        Width_plasma = self._named_bounds["Width_plasma"]["bounds"]

        # Call the main MATLAB function (e.g., bondingModel2) that evaluates the process
        tensile_strength, failure_mode, visual_quality, cost, feasibility, final_contact_angle = eng.bondingModel2(
            pretreatment, posttreatment, material, dry_tissue, compressed_air, US_bath, degreasing, roughening, glue_type,
            sample_size, plasma, plasma_power, plasma_speed, plasma_distance, plasma_passes, time_between_plasma_glue,
            curing_time, curing_temperature, batch_size, number_repetitions, Width_plasma, general_noise,
            noise_factor_plasma, noise_curing, noise_material, wt_particles, curing_method, ind_current_bonding
        )

        # Return only the tensile strength as the objective to be optimized
        return torch.tensor(
            float(tensile_strength),
            dtype=X.dtype,
            device=X.device)
