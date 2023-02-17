% IEEE VTS Motor Vehicles Challenge 2023
% Results (this code is not to be changed by the competitors)
close all
load("BLScores.mat")                                                        % loading baseline scores for all tracks. They are saved under var name Perf_history

t           = out.time;                                                     % simulation time

RefSpeed    = out.speed(:,1);                                               % reference speed of the chosen track
ActSpeed    = out.speed(:,2);                                               % actual vehicle speed
RefCurv     = out.speed(:,3);                                               % reference curvature of the chosen track

SOC_bat     = out.vehicle(:,1);                                             % actual battery's SoC
T_bat       = out.vehicle(:,2);                                             % actual battery's temperature
i_bat       = out.vehicle(:,3);                                             % actual battery's current
v_bat       = out.vehicle(:,4);                                             % actual battery's voltage
Tq_bat      = out.vehicle(:,5);                                             % chasisControlBus.Torque
H2SoC       = out.vehicle(:,6);                                             % Hydrogen fuel tank SoC
H2P         = out.vehicle(:,7);                                             % actual fuel cell's power

J_eng       = string(sprintf('%.8f',out.scores(end,1)*2.7778e-7));          % [kWh] Energy performance metric
J_loss      = string(sprintf('%.8f',out.scores(end,7)*2.7778e-7));          % [kWh] Total loss performance metric
J_eng_tot   = string(sprintf('%.8f',(out.scores(end,1)+out.scores(end,7))*2.7778e-7));  % [kWh] Total Energy performance metric 

J_SOC       = string(sprintf('%.8f',out.scores(end,2)));                    % [s] Battery and FC SoC performance metric 
J_T         = string(sprintf('%.8f',out.scores(end,3)));                    % [C] Temperature performance metric 
J_v         = string(sprintf('%.8f',out.scores(end,4)));                    % [s] Velocity derating performance metric 
J_deg       = string(sprintf('%.8f',out.scores(end,5)));                    % [Ah/cycle] Battery's degradation performance metric 
J_tire      = string(sprintf('%.8f',out.scores(end,8)*0.000277778));        % [kWh] Tire losses performance metric

% Check if the exit flag is 1 (when the SoC safety constraints are violated), penalize the total performance.
flag        = out.scores(end,6);                                            % Indicating exit flag

if flag==1
    J_flg = inf;
else
    J_flg = 0;
end

% Performance metric weights (for the time being they are chosen uniformly)
k_E         = 1/6;
k_soc       = 1/6;
k_T         = 1/6;
k_v         = 1/6;
k_deg       = 1/6;
k_tire      = 1/6;

% Baseline performance metrics
J_eng_BL    = Perf_history(1,ind);
J_SOC_BL    = Perf_history(2,ind);
J_T_BL      = Perf_history(3,ind);
J_deg_BL    = Perf_history(4,ind);
J_v_BL      = Perf_history(5,ind);
J_tire_BL   = Perf_history(6,ind);

% Normalized performance metrics of EMA with respect to the baseline EMA
JT_E        = check_score(str2double(J_eng_tot),J_eng_BL);
JT_SOC      = check_score(str2double(J_SOC),J_SOC_BL);
JT_T        = check_score(str2double(J_T),J_T_BL);
JT_v        = check_score(str2double(J_v),J_v_BL);
JT_deg      = check_score(str2double(J_deg),J_deg_BL);
JT_tire     = check_score(str2double(J_tire),J_tire_BL);

% Computation of the total performance J
J = k_E*JT_E+k_soc*JT_SOC+k_T*JT_T+k_v*JT_v+k_deg*JT_deg+k_tire*JT_tire+J_flg;
J = string(sprintf('%.8f',J));

% EMA control variable outputs for plotting
alpha_FC    = out.EMA(:,1);
alpha_TV    = out.EMA(:,2);
alpha_AD    = out.EMA(:,3);
alpha_v     = out.EMA(:,4);

%% Figures
set(figure(1),'Position',[100 200 350 250]);
set(figure(2),'Position',[100 200 350 450]);
set(figure(3),'Position',[100 200 350 250]);
set(figure(4),'Position',[100 200 350 250]);
set(figure(5),'Position',[100 200 350 250]);

figure(1),
f1 = subplot(2,1,1);
plot(t(2:end),RefSpeed(2:end),'b',t(2:end),ActSpeed(2:end),'r','linewidth',0.8); grid on, grid minor
pos_f1 = get(f1,'Position');
set(gca,'FontSize',12,'TickLabelInterpreter','latex'),
ylabel('$v$ [m/s]','Interpreter','latex','FontSize', 12),
hl = legend('$v^\star$','$v_{meas}$','Interpreter','latex','Location',...
        'northwest','Orientation','horizontal','FontSize', 10);
pos_hl = get(hl, 'Position');
subplot(2,1,2),
plot(t(2:end),RefCurv(2:end),'b','linewidth',0.8); grid on, grid minor
set(gca,'FontSize',12,'TickLabelInterpreter','latex'),
ylabel('$\kappa$ [1/m]','Interpreter','latex','FontSize', 12),
xlabel('time [s]','Interpreter','latex','FontSize', 12),
set(hl,'Position',[pos_f1(1)+pos_f1(3)-pos_hl(3)...
pos_hl(2)+pos_hl(4)+0.025...
pos_hl(3)...
0.8*pos_hl(4)]);

img1 = sprintf([urlHTML,'/fig1.png']);
saveas(gcf,img1);

figure(2),
subplot(4,1,1),
plot(t(2:end),alpha_v(2:end),'b','linewidth',0.8); grid on, grid minor
set(gca,'FontSize',12,'TickLabelInterpreter','latex'),
ylabel('$\alpha_{v}$','Interpreter','latex','FontSize', 12),
subplot(4,1,2),
plot(t(2:end),alpha_FC(2:end),'b','linewidth',0.8); grid on, grid minor
set(gca,'FontSize',12,'TickLabelInterpreter','latex'),
ylabel('$\alpha_{FC}$','Interpreter','latex','FontSize', 12),
subplot(4,1,3),
plot(t(2:end),alpha_AD(2:end),'b','linewidth',0.8); grid on, grid minor
set(gca,'FontSize',12,'TickLabelInterpreter','latex'),
ylabel('$\alpha_{AD}$','Interpreter','latex','FontSize', 12),
subplot(4,1,4),
plot(t(2:end),alpha_TV(2:end),'b','linewidth',0.8); grid on, grid minor
set(gca,'FontSize',12,'TickLabelInterpreter','latex'),
ylabel('$\alpha_{TV}$','Interpreter','latex','FontSize', 12),
xlabel('time [s]','Interpreter','latex','FontSize', 12),

img2 = sprintf([urlHTML,'/fig2.png']);
saveas(gcf,img2);

figure(3),
subplot(2,1,1),
plot(t(2:end),SOC_bat(2:end),'b','linewidth',0.8); grid on, grid minor, hold on,
set(gca,'FontSize',12,'TickLabelInterpreter','latex'),
yline(param.bat.SOCmax,'b--','$SoC_{b,max}$','linewidth',1.5,'Interpreter','latex','FontSize', 12), hold on
yline(param.bat.SOCmin,'r--','$SoC_{b,min}$','linewidth',1,'Interpreter','latex','FontSize', 12)
ylabel('$SoC_{b}$','Interpreter','latex','FontSize', 12);
subplot(2,1,2),
plot(t(2:end),T_bat(2:end),'b','linewidth',0.8); grid on, grid minor, hold on
yline(param.bat.Tmax,'b--','$T_{bat,max}$','linewidth',1,'Interpreter','latex','FontSize', 12),
set(gca,'FontSize',12,'TickLabelInterpreter','latex'),
xlabel('time [s]','Interpreter','latex','FontSize', 12),
ylabel('$T_{b} [^\circ C]$','Interpreter','latex','FontSize', 12);

img3 = sprintf([urlHTML,'/fig3.png']);
saveas(gcf,img3);

figure(4),
subplot(2,1,1),
plot(t(2:end),i_bat(2:end),'b','linewidth',0.8); grid on, grid minor
set(gca,'FontSize',12,'TickLabelInterpreter','latex'),
ylabel('$i_{b} [A]$','Interpreter','latex','FontSize', 12);
subplot(2,1,2),
plot(t(2:end),v_bat(2:end),'b','linewidth',0.8); grid on, grid minor
set(gca,'FontSize',12,'TickLabelInterpreter','latex'),
xlabel('time [s]','Interpreter','latex','FontSize', 12),
ylabel('$v_{b} [V]$','Interpreter','latex','FontSize', 12);

img4 = sprintf([urlHTML,'/fig4.png']);
saveas(gcf,img4);

figure(5),
subplot(2,1,1),
plot(t(2:end),H2SoC(2:end),'b','linewidth',0.8); grid on, grid minor, hold on
set(gca,'FontSize',12,'TickLabelInterpreter','latex'),
yline(param.fuelcell.SOCmax,'b--','$SoC_{FC,max}$','linewidth',1,'Interpreter','latex','FontSize', 12), hold on
yline(param.fuelcell.SOCmin,'r--','$SoC_{FC,min}$','linewidth',1,'Interpreter','latex','FontSize', 12)
ylabel('$SoC_{H2}$','Interpreter','latex','FontSize', 12);
subplot(2,1,2),
plot(t(2:end),H2P(2:end),'b','linewidth',0.8); grid on, grid minor
set(gca,'FontSize',12,'TickLabelInterpreter','latex'),
xlabel('time [s]','Interpreter','latex','FontSize', 12),
ylabel('$P_{H2}$ [W]','Interpreter','latex','FontSize', 12);

img5 = sprintf([urlHTML,'/fig5.png']);
saveas(gcf,img5);

%% Save Performance
info = ['Date: ',datestr(now, 'dd-mmm-yyyy'),', Mission Track: ',Track];    % generate string name of the folder

Metric = ["Exit Flag";"J_{E,tot}";"J_{SoC}";"J_{TC}";"J_{deg}";"J_{v}";"J_{tire}";"J"]; % list of reported performance metrics
Values = [string(flag);J_eng_tot;J_SOC;J_T;J_deg;J_v;J_tire;J];                         % performance metrics' values
Unit = ["[-]";"[kWh]";"[s]";"[C]";"[Ah/cycle]";"[s]";"[Wh]";"[-]"];
Description  = ["Exit flag is 1 when the battery and the FC SoC safety constraints are violated; 0 otherwise";
                "Total energy: energy provided by the storage unit and the total losses";
                "Timespan that SoC constraints are violated";
                "Maximum temperature constraint violation";
                "Lost battery capacity due to battery aging";
                "Derating metric; duration in which the vehicle did not track the reference velocity profile";
                "Tire losses";
                "Final score of the designed EMA"];
Scores = table(Metric,Values,Unit,Description);                             % generate scores' table
scores_url  = sprintf([urlHTML,'/performance.mat']);
performance = struct;
performance.info = info;
performance.Scores = Scores;
save(scores_url,'-struct','performance');                                   % save performance scores