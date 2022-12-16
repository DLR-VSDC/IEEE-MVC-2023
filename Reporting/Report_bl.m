% This script is only added to generate baseline metrics
% J_eng       = string(sprintf('%.4f',out.scores(end,1)*2.7778e-7)); % J to kWh
% J_loss      = string(sprintf('%.4f',out.scores(end,7)*2.7778e-7)); % J to kWh
J_eng_tot   = string(sprintf('%.4f',(out.scores(end,1)+out.scores(end,7))*2.7778e-7)); % [kWh]

J_SOC       = string(sprintf('%.4f',out.scores(end,2)));
J_T         = string(sprintf('%.4f',out.scores(end,3)));
J_v         = string(sprintf('%.4f',out.scores(end,4)));
J_deg       = string(sprintf('%.4f',out.scores(end,5)));
J_tire      = string(sprintf('%.4f',out.scores(end,8)*0.000277778)); % J to Wh


% Performance:
Metric = ["J_{E,tot}";"J_{SoC}";"J_{TC}";"J_{deg}";"J_{v}";"J_{tire}"];
Values = [J_eng_tot;J_SOC;J_T;J_deg;J_v;J_tire];
Scores = table(Metric,Values);
