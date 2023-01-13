# Changelog

All notable changes to this project will be documented in this file.

## [Beta 3] - 2022-01-13

### Changed
Changes on main.m script:
- Added FC SOC safety to stop the car if SoC_H2 tank goes below 1%.
- Increased minimum allowed FC SoC (param.fuelcell.SOCmin) to 10%.
- Reduced H2 tank size to 0.15 kg.
- Decreased battery's maximum allowed SoC to 80%.
- Decreased safety stop tolerance level of battery to 99% from 100.1%.
- Lowered maximum allowed temperature to 35 deg C.

Changes on Simulink model (testEnergyManagementAlgorithm.slx):
- Initial velocity of the vehicle is set to zero. This solves [discussion #11](https://github.com/DLR-VSDC/IEEE-MVC-2023/discussions/11)
- Safety stop condition have been added to the model/Performance Metrics, the one with yellow comment.
- Inside Baseline EMA block, few additional signals are added that competitors could have access to.
- Renamed H2_I to H2_content.
- Included P_battery directly instead of computing it from P=V*I.
- Removed some unnecessary scopes.


### Fixed

- Updated documentation of aging model - [Discussion #15](https://github.com/DLR-VSDC/IEEE-MVC-2023/discussions/15),   
refer to [updated chapter 3c of the paper](./media/MVC2023_chapter3C_update_Beta3.pdf)
- New FMU model `MVC2023_Hash_47c69bf5.fmu` changed battey voltage signal from OCV to the acutual measured value in the circuit.    
 Added some additional signals to the batterybus and rexbus. This solves [discussion #11](https://github.com/DLR-VSDC/IEEE-MVC-2023/discussions/11)

## [Beta 2] - 2022-01-03

### Changed

- New parameterization of the intial values, please refer to main.m - please mind that these might be changed in the final version
- [Extend state vector in the EMA #8](https://github.com/DLR-VSDC/IEEE-MVC-2023/issues/8)

### Fixed
- Revised model of the fuel cell - [Fuel Cell Model: wrong SI-units in H2 consumption #10](https://github.com/DLR-VSDC/IEEE-MVC-2023/issues/10):
	- New FMU model `MVC2023_Hash_ddadadfe.fmu` with revised fuel cell model
	- Corrected fuel cell consumption table (wrong units) and Modelica model, refer to [updated chapter 3e of the paper](./media/MVC2023_chapter3E_update_Beta2.pdf)


## [Beta 1] - 2022-12-16

### Added

- A new Performance metric is included, and it is called `J_tire`. This performance metric captures tire losses, to evaluate the torque vectoring capability of the designed EMA.

### Changed

- [Updated chapter 4c of the paper (Performance Metrics)](./media/MVC2023_chapter4C_update_Beta1.pdf).
- Track naming is updated according to their mission tracks (e.g. [FTP75.mat](ftp://ftp75.mat/), ECE15.mat, etc.).
- Some tracks are extended (repeated over and over) to challenge the energy management algorithms to drive the vehicle in more efficient way. (Some tracks may be longer than what the power source can deliver)
- Fuel Cell's H2 tank size has been reduced to 40 kg.
- After each run of the main script, a folder will be auto-generated on `/Reporting/Report_History` with the name of the track, date and time. This folder contains HTML report and the generated performance plots. This could help the participants to evaluate their progress.
- `J_engergy` is extended to the total energy, i.e. energy provided by the battery and the fuel cell and all the losses.
- The final score of the EMA is computed as the normalized metrics with respect to the Baseline Policy against each track. If one `J_x` is nonzero while baseline gives zero, the overall `J` will be penalized by a large number.
- Competitors are invited to improve the EMA such that the overall performance metric goes below 1 (`J_tot = 1` is when the designed EMA works exactly as the baseline EMA, `J_tot > 1` works worse and `J_tot < 1` better).

### Fixed

## [Alpha] - 2022-11-02

### Added

- Initial version of the IEEE MVC 2023 material
