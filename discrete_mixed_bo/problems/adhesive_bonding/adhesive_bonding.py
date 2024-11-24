# Import required modules
import matlab.engine
import torch
from torch import Tensor
from typing import Optional

from discrete_mixed_bo.problems.base import DiscreteTestProblem

# Start MATLAB engine
eng = matlab.engine.start_matlab()
eng.addpath('../discrete_mixed_bo/problems/adhesive_bonding', nargout=0)

class AdhesiveBonding(DiscreteTestProblem):

    def __init__(
        self,
        noise_std: Optional[float] = None,
        negate: bool = False,
        bounds: dict = {}
    ) -> None:
        self._named_bounds = bounds

        # Build the bounds array using only the bounds member, discarding the fixed values
        self._bounds = []
        integer_indices = []
        categorical_indices = []

        for key, item in self._named_bounds.items():
            if item["type"] in ["integer", "categorical", "continuous"]:
                index = len(self._bounds)
                self._bounds.append(item["bounds"])

                if item["type"] == "integer":
                    integer_indices.append(index)
                elif item["type"] == "categorical":
                    categorical_indices.append(index)

        # Continuous indices will be automatically deducted by the base class

        super().__init__(noise_std, negate, integer_indices, categorical_indices)

    def evaluate_true(self, X: Tensor) -> Tensor:
        # X is a square tensor of 20x20
        # Should i iterate over each row?

        Y = []
        for Xi in X:
            # Convert input to MATLAB compatible format (assuming x is a list of input variables)
            x_matlab = matlab.double(Xi.tolist())

            # Same ordering as the instantiation
            curing_time, ind_current_bonding, plasma_distance, Plasma_passes, plasma_power, plasma_speed, time_between_plasma_glue, wt_particles, curing_method, compressed_air, degreasing, dry_tissue, US_bath, glue_type, material, Plasma, pretreatment, roughening, noise_curing, posttreatment = x_matlab[0]

            # Map categorical values
            curing_method = self._named_bounds['curing_method']['mapping'][int(curing_method)]
            glue_type = self._named_bounds['glue_type']['mapping'][int(glue_type)]
            material = self._named_bounds['material']['mapping'][int(material)]
            #order = self._named_bounds['order']['mapping'][order]
            noise_curing = self._named_bounds['noise_curing']['mapping'][int(noise_curing)]

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
                sample_size, Plasma, plasma_power, plasma_speed, plasma_distance, Plasma_passes, time_between_plasma_glue,
                curing_time, curing_temperature, batch_size, number_repetitions, Width_plasma, general_noise,
                noise_factor_plasma, noise_curing, noise_material, wt_particles, curing_method, ind_current_bonding
            )

            # Return only the tensile strength as the objective to be optimized
            Y.append(tensile_strength)

        return torch.tensor(
            Y,
            dtype=X.dtype,
            device=X.device)
