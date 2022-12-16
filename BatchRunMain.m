% IEEE VTS Motor Vehicles Challenge 2023
% University of California, Merced
% Batch Run
%----------------------------------------------------
% Results can be found in the .\media folder 
% openfig('.\media\bEMACriteriaAllTracks.fig')
% openfig('.\media\bEMAPerformanceAllTracks.fig')
%----------------------------------------------------
clc;clear;close all;
addpath(genpath('Reporting'))
addpath('Functions')
addpath('Tracks')
% add the folder to the MATLAB path
addpath(fullfile(pwd, 'FMIKit-Simulink-3.0'))
% initialize FMI Kit
FMIKit.initialize()

%% Initialization
Ts_solver   = 0.01;                                                         % Solver maximum sampling time
Ts_sample   = 0.01;                                                         % Sampling of tracks and outputs

%      'Track No.  1: FTP75',
%      'Track No.  2: ECE15',
%      'Track No.  3: Artemis Urban',
%      'Track No.  4: Artemis Rural',
%      'Track No.  5: ViresRuralRoadDescent1',
%      'Track No.  6: ViresRuralRoadDescent2',
%      'Track No.  7: NonOptMunich1',
%      'Track No.  8: OptMunich1',
%      'Track No.  9: NonOptMunich2',
%      'Track No. 10: OptMunich2'

N_pre       = 100;                                                          % Preview window size

%% Run the baseline for all ten tracks:
for ind = 1:10
    % Generate inputs to the Simulink model
    [Track,urlReport,urlHTML,urlPublish,FolderName,...
        preview,refSpeed,refCurv,Tend,T_s] = trackSelect(ind,N_pre);
    fprintf('Simulation of the Mission: %s',Track)
    fprintf('\n\nInitializing the Simulink model:\n')
    %% System Parameters 
    % The following parameters are not allowed to be changed.
    param.fuelcell.Imax     = 40;                                               % [A] maximum Fuel cell current
    param.fuelcell.SOCmax   = 1.00;                                             % [-] maximum allowed SoC
    param.fuelcell.SOCmin   = 0.05;                                             % [-] minimum allowed SoC
    param.fuelcell.H2_tank_level = 40;                                          % [kg] H2 tank initial level value

    param.bat.SOCmax        = 1.00;                                             % [-] maximum allowed SoC
    param.bat.SOCmin        = 0.20;                                             % [-] minimum allowed SoC  
    param.bat.SOC_delta     = 0.05;                                             % [-] SOC for derating
    
    param.bat.SOCmin_stop   = 0.01;                                             % [-] vehicle shutdown if battery SoC become lower than this value
    param.bat.SOCmax_stop   = 1.01;                                             % [-] vehicle shutdown if battery SoC become higher than this value
    param.bat.SOC_init = 0.8;                                                   % [-] vehicle battery start SoC

    param.bat.Tmax          = 40;                                               % [deg C] maximum allowed temperature
    
    % Baseline EMA parameters
    param.EMAbaseline.kfc   = 0.8;                                              % fuel cell distribution ratio
    param.EMAbaseline.ktv   = 0.5;                                              % torque vectoring ratio
    param.EMAbaseline.a_ad  = 0.5;                                              % front/rear ratio
    
    % Main simulation
    fprintf('Please wait until the simulation is completed...\n\n')
    tic;
    out = sim('testEnergyManagementAlgorithm.slx','StopTime',num2str(Tend));
    sim_time = toc/60;
    fprintf('Success!\t Total simulation time is: \t %d min\n',sim_time)
    fprintf('Please check the auto-generated html report for further evaluation of your designed EMA.\n\n')
    Report_bl;  % Reporting
    Perf_history(:,ind) = str2double(Scores.Values); % Collecting performance on this track
end
save('BLScores.mat','Perf_history')
%% Plot Performance vs. Track
figure(1),
X = categorical({'FTP75','ECE15','ArtemisUrban','ArtemisRural','ViresRuralDescent1','ViresRuralDescent2',... 
    'NonOptMunich1','OptMunich1','NonOptMunich2','OptMunich2'});
X = reordercats(X,{'FTP75','ECE15','ArtemisUrban','ArtemisRural','ViresRuralDescent1','ViresRuralDescent2',... 
    'NonOptMunich1','OptMunich1','NonOptMunich2','OptMunich2'});

Y1 = [Perf_history(1,:)]';
Y2 = [Perf_history(2,:)/60]';
Y3 = [Perf_history(3,:)]';
Y4 = [Perf_history(4,:)]';
Y5 = [Perf_history(5,:)/60]';
Y6 = [Perf_history(6,:)]';
subplot(321),bar(X,Y1,'b');
ylabel('$J_{E,tot} [kWh]$','Interpreter','latex','FontSize', 12);set(gca,'xtick',X,'XTickLabel',X,'TickLabelInterpreter','latex');

subplot(322),bar(X,Y2,'r');
ylabel('$J_{SoC} [min]$','Interpreter','latex','FontSize', 12);set(gca,'xtick',X,'XTickLabel',X,'TickLabelInterpreter','latex');

subplot(323),bar(X,Y3,'m');
ylabel('$J_{TC} [^\circ C]$','Interpreter','latex','FontSize', 12);set(gca,'xtick',X,'XTickLabel',X,'TickLabelInterpreter','latex');

subplot(324),bar(X,Y4,'g');
ylabel('$J_{deg} [mAh/cycle]$','Interpreter','latex','FontSize', 12);set(gca,'xtick',X,'XTickLabel',X,'TickLabelInterpreter','latex');

subplot(325),bar(X,Y5,'k');
ylabel('$J_v [min]$','Interpreter','latex','FontSize', 12);set(gca,'xtick',X,'XTickLabel',X,'TickLabelInterpreter','latex');

subplot(326),bar(X,Y6,'c');
ylabel('$J_{tire} [Wh]$','Interpreter','latex','FontSize', 12);set(gca,'xtick',X,'XTickLabel',X,'TickLabelInterpreter','latex');







count = 1:ind;
myTrack = {'FTP75','ECE15','ArtemisUrban','ArtemisRural','ViresRuralDescent1','ViresRuralDescent2',... 
    'NonOptMunich1','OptMunich1','NonOptMunich2','OptMunich2'}; 
figure(2),
sgtitle('Baseline Performance of 10 Tracks','Interpreter','latex','FontSize', 12)
subplot(611),
plot(count,Perf_history(1,:),'b*:','LineWidth',1);grid on, grid minor;
set(gca,'xtick',[1:ind],'xticklabel',myTrack,'FontSize',9,'TickLabelInterpreter','latex')
ylabel('$J_{E,loss} [kWh]$','Interpreter','latex','FontSize', 12);
xlim([1,ind]);

subplot(612),
plot(count,Perf_history(2,:)/60,'b*:','LineWidth',1);grid on, grid minor;
set(gca,'xtick',[1:ind],'xticklabel',myTrack,'FontSize',9,'TickLabelInterpreter','latex')
ylabel('$J_{SoC} [min]$','Interpreter','latex','FontSize', 12);xlim([1,ind]);

subplot(613),
plot(count,Perf_history(3,:),'b*:','LineWidth',1);grid on, grid minor;
set(gca,'xtick',[1:ind],'xticklabel',myTrack,'FontSize',9,'TickLabelInterpreter','latex')
ylabel('$J_{TC} [^\circ C]$','Interpreter','latex','FontSize', 12);xlim([1,ind]);

subplot(614),
plot(count,Perf_history(4,:),'b*:','LineWidth',1);grid on, grid minor;
set(gca,'xtick',[1:ind],'xticklabel',myTrack,'FontSize',9,'TickLabelInterpreter','latex')
ylabel('$J_{deg} [mAh/cycle]$','Interpreter','latex','FontSize', 12);xlim([1,ind]);

subplot(615),
plot(count,Perf_history(5,:)/60,'b*:','LineWidth',1);grid on, grid minor;
set(gca,'xtick',[1:ind],'xticklabel',myTrack,'FontSize',9,'TickLabelInterpreter','latex')
ylabel('$J_v [min]$','Interpreter','latex','FontSize', 12);xlim([1,ind]);

subplot(616),
plot(count,Perf_history(6,:),'m*:','LineWidth',1);grid on, grid minor; %tire loss
set(gca,'xtick',[1:ind],'xticklabel',myTrack,'FontSize',9,'TickLabelInterpreter','latex')
ylabel('$J_{tire} [Wh]$','Interpreter','latex','FontSize', 12);


