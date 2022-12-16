function Ji = check_score(J_sim,J_BL)

if J_BL==0 && J_sim ==0
    Ji = 1;
elseif J_BL==0 && J_sim > 0
    Ji = inf;
else 
    Ji = J_sim/J_BL;
end