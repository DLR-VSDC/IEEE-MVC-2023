function W_hat = prew(k,N_pre,Data)    
    W_hat = zeros(N_pre*2,1);         % Collector of the preview information
    for i=1:N_pre
        W_hat(i,:)       = Data(k+100*(i-1),1);                             % speed preview
        W_hat(i+N_pre,:) = Data(k+100*(i-1),2);                             % curvature preview
    end
end