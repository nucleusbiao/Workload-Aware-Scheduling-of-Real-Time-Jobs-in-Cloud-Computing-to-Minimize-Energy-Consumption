function [ EnergyConsumption ] = EnergyConsumptionFuc( ServerResult,ActivatedServers,alpha,beta,pp )
%UNTITLED2 此处显示有关此函数的摘要
%   此处显示详细说明
P_s = 0;
for i = ActivatedServers
    P_v = 0;
    for j = 1:size(ServerResult{i},2)
        P_v = P_v + alpha(i)*ServerResult{i}{j}(1,end-1);
        for k = 1:size(ServerResult{i}{j},1)
            P_v = P_v + beta(i)*ServerResult{i}{j}(k,2)/ServerResult{i}{j}(k,1);
        end
    end
    P_s = P_s + P_v;
end
EnergyConsumption = P_s*pp*60*60;


