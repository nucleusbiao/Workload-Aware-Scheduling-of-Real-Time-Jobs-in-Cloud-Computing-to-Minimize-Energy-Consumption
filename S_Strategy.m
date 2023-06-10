function [ ServerResult,ActivatedServers,unassignedJob ] = S_Strategy( Job_Period,Job_Load,Job_Deadline,Lambda,ServerNum,C_s,alpha,beta,gama )

JobinServers_Load_PerUnit = [];
P_s = [];
for i = 1:ServerNum
    JobinServers_Load_PerUnit(i,:) = Job_Load./Lambda(i,:);
    JobinServers_Util_PerUnit(i,:) = JobinServers_Load_PerUnit(i,:)./Job_Period;
    JobinServers_UtilD_PerUnit(i,:) = JobinServers_Load_PerUnit(i,:)./Job_Deadline;
    P_s(i) = alpha(i)*C_s(i) + beta(i)*sum(JobinServers_UtilD_PerUnit(i,:));
end
[~,index] = sort(P_s, 'ascend');
for i = 1:ServerNum
    ServerResult{i} = [];
end

ActivatedServers = [];

for n = 1:ServerNum
    ServerIndex = index(n);
    ActivatedServers = [ActivatedServers ServerIndex];
    C = C_s(ServerIndex);
    Left_Period = [];
    Left_Load = [];
    Left_Deadline = [];
    lambda = [];
    for i = 1:size(Job_Period, 2)
        Job_Load_PerUnit = Job_Load./Lambda(ServerIndex,:);
        for c =1:C
            if ceil(Job_Deadline(i)/Job_Period(i))*Job_Load_PerUnit(i)/c <= Job_Deadline(i)
                ServerResult{ServerIndex} = [ServerResult{ServerIndex};Job_Period(i), Job_Load_PerUnit(i), Job_Deadline(i), c];
                C = C - c;
                break
            end
        end
        if isempty(c)
            c = 0;
        end
        if ceil(Job_Deadline(i)/Job_Period(i))*Job_Load_PerUnit(i)/c > Job_Deadline(i)           
            Left_Period = [Left_Period Job_Period(i)];
            Left_Load = [Left_Load Job_Load(i)];
            Left_Deadline = [Left_Deadline Job_Deadline(i)];
            lambda = [lambda Lambda(:,i)];
        end
    end
    Lambda = lambda;
    Job_Period = Left_Period;
    Job_Load = Left_Load;
    Job_Deadline = Left_Deadline;
end
unassignedJob = [];
for m = 1:size(Job_Period,2)
    unassignedJob = [unassignedJob;Job_Period(m) Job_Load(m) Job_Deadline(m)];
end
    
end

