%% Constraints for Linear Programming

% Boundary-Constraints for relative tanklevel
% Index: Rülzheim(A505)-(1); Hatzenbühl(A510)-(2); Wörth(A516)-(3)
Lb_tank = [3.2;5.2;4.4];

Ub_tank = [5.5;7.3;5.4];

Tank.Label{1} = 'A505';
Tank.Label{2} ='A510';
Tank.Label{3} ='A516';
i = 1;
for i=1:length(Ub_tank);
    Tank.UB{i} = Ub_tank(i);
    i = i+1;
end
for i=1:length(Lb_tank);
    Tank.LB{i} = Lb_tank(i);
    i = i+1;
end

