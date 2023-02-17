function [Track,urlReport,urlHTML,urlPublish,FolderName,preview,refSpeed,refCurv,Tend,T_s] = trackSelect(ind,N_pre)
switch ind
    case 1
        load('FTP75')
        Track = 'FTP75';
    case 2
        load('ECE15')
        Track = 'ECE15';
    case 3
        load('ArtemisUrban')
        Track = 'ArtemisUrban';
    case 4
        load('ArtemisRural')
        Track = 'ArtemisRural';
    case 5
        load('ViresRuralRoadDescent1')
        Track = 'ViresRuralRoadDescent1';
    case 6 
        load('ViresRuralRoadDescent2')
        Track = 'ViresRuralRoadDescent2';
    case 7
        load('NonOptMunich1')
        Track = 'NonOptMunich1';
    case 8
        load('OptMunich1')
        Track = 'OptMunich1';
    case 9
        load('NonOptMunich2')
        Track = 'NonOptMunich2';
    case 10
        load('OptMunich2')
        Track = 'OptMunich2';
end
[preview,refSpeed,refCurv] = track_info(N_pre,speed,curv,t);

% The following must remain unchanged
FolderName      = sprintf([Track,'_',datestr(now, 'dd_mmm_yyyy_HH_MM')]);
urlRepo         = sprintf(['Reporting/Report_History/',FolderName]);
urlReport       = sprintf([urlRepo,'/Report.m']);
urlHTML         = sprintf([urlRepo,'/html']);
urlPublish      = sprintf([urlHTML,'/Report.html']);

mkdir(urlRepo);addpath(urlRepo);
mkdir(urlHTML);addpath(urlHTML);

copyfile('Reporting/Report_template.m','Report.m')
movefile('Report.m',urlRepo);
