function [preview,refSpeed,refCurv,Tend,T_s] = trackSelect(ind,N_pre)
switch ind
    case 1
        load('track1')
    case 2
        load('track2')
    case 3
        load('track3')
    case 4
        load('track4')
    case 5
        load('track5')
    case 6 
        load('track6')
    case 7
        load('track7')
    case 8
        load('track8')
    case 9
        load('track9')
    case 10
        load('track10')
end
[preview,refSpeed,refCurv] = track_info(N_pre,speed,curv,t);