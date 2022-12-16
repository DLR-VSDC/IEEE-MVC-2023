## Major Updates on Beta 1 Release:
- [Updated chapter 4c of the paper (Performance Metrics)](./media/MVC2023_chapter4C_update_Beta1.pdf).
- Track naming is updated according to their mission tracks (e.g. [FTP75.mat](ftp://ftp75.mat/), ECE15.mat, etc.).
- Some tracks are extended (repeated over and over) to challenge the energy management algorithms to drive the vehicle in more efficient way. (Some tracks may be longer than what the power source can deliver)
- Fuel Cell's H2 tank size has been reduced to 40kg.
- After each run of the main script, a folder will be auto-generated on /Reporting/Report_History with the name of the track, date and time. This folder contains HTML report and the generated performance plots. This could help the participants to evaluate their progress.
- A new Performance metric is included, and it is called J_tire. This performance metric captures tire losses, to evaluate the torque vectoring capability of the designed EMA.
- J_engergy is extended to the total energy, i.e. energy provided by the battery and the fuel cell and all the losses.
- The final score of the EMA is computed as the normalized metrics with respect to the Baseline Policy against each track. If one J_x is nonzero while baseline gives zero, the overall J will be penalized by a large number.
- Competitors are invited to improve the EMA such that the overall performance metric goes below 1 (J_tot = 1 is when the designed EMA works exactly as the baseline EMA, over 1, works worse and below 1 better).
