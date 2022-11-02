function W_hat = prew(k,N_pre,Data)    
    W_hat = zeros(N_pre*2,1);         % Collector of the preview information
    for i=1:N_pre
        W_hat(i,:)       = Data(k+(i-1),1);
        W_hat(i+N_pre,:) = Data(k+(i-1),2);
    end
end