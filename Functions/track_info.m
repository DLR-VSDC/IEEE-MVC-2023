function [preview,refSpeed,refCurv] = track_info(N_pre,speed,curv,t)
    % Extending the reference values with "zero" speed and curvature (for preview info)
    extData     = [[speed curv]; zeros(N_pre*100,2)];

    % Create Preview information for each time step i
    for i=1:length(t)
        collect(:,i) = prew(i,N_pre,extData);
    end

    % Timeseries creation of each signal to import to main Simulink
    preview     = timeseries(collect,t);
    refSpeed    = timeseries(speed,t);
    refCurv     = timeseries(curv,t);
end