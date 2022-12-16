% IEEE VTS Motor Vehicles Challenge 2023
% University of California, Merced
% Main Script
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

% Track selection: For more information on the tracks, please refer to the Reamdme.md file on the "Tracks" folder.
list        = { 'Track No.  1: FTP75',...
                'Track No.  2: ECE 15',...
                'Track No.  3: Artemis Urban',...
                'Track No.  4: Artemis Rural',...
                'Track No.  5: ViresRuralRoadDescent1',...
                'Track No.  6: ViresRuralRoadDescent2',...
                'Track No.  7: NonOptMunich1',...
                'Track No.  8: OptMunich1',...
                'Track No.  9: NonOptMunich2' ...
                'Track No. 10: OptMunich2'};
[ind,tf]    = listdlg('PromptString',{'Please select a track',...
            'Please note: Only one can be selected at a time'},'SelectionMode','single','ListString',list,'ListSize',[300 200]);

N_pre       = 100;                                                          % Preview window size

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
param.fuelcell.H2_tank_level = 40;                                           % [kg] H2 tank initial level value

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

%% Main simulation
fprintf('Please wait until the simulation is completed...\n\n')
tic;
out = sim('testEnergyManagementAlgorithm.slx','StopTime',num2str(Tend));
sim_time = toc;
fprintf('Success!\t Total simulation time is: \t %d seconds\n',sim_time)
fprintf('Please check the auto-generated html report for further evaluation of your designed EMA.\n')

%% Reporting (The following lines must remain unchanged)
Results;
options.showCode = false;
publish(urlReport,options);
web(urlPublish)
