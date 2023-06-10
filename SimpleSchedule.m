function [ ServerResult,P_s,unassignedJob ] = SimpleSchedule( Job_Period,Job_Load,Job_Deadline,Lambda,ServerNum,C_s,alpha,beta,gama  )
%UNTITLED 此处显示有关此函数的摘要
%   此处显示详细说明
JobNum = size(Job_Deadline,2);
unassignedJob = [];
for i = 1:ServerNum
    ServerResult{i} = [];
end
[Job_Period,index] = sort(Job_Period,'ascend');
Job_Deadline = Job_Deadline(index);
Job_Load = Job_Load(index);

for i = 1:JobNum
    [~,index] = sort(Lambda(:,1),'descend');
    flag = 0;
    for ServerIndex = index'
        if isempty(ServerResult{ServerIndex})
            if Job_Load(i)/(Lambda(ServerIndex,i)*C_s(ServerIndex))<Job_Deadline(i)
                flag = 1;
                ServerResult{ServerIndex} = [ServerResult{ServerIndex};Job_Period(i) Job_Load(i)/Lambda(ServerIndex,i) Job_Deadline(i) C_s(ServerIndex)];
                break
            else
                continue
            end
        else
            for k = 0:size(ServerResult{ServerIndex},1)
                pos = size(ServerResult{ServerIndex},1) - k;
                newjob = [Job_Period(i) Job_Load(i)/Lambda(ServerIndex,i) Job_Deadline(i) C_s(ServerIndex)];
                if k~=0
                    temp = [ServerResult{ServerIndex}(1:pos,:);newjob;ServerResult{ServerIndex}(pos+1:pos+k,:)];
                else
                    temp = [ServerResult{ServerIndex}(1:pos,:);newjob;];
                end
                flag =  responseTimeFuc2(temp);
                if flag
                    ServerResult{ServerIndex} = temp;
                    break
                end
            end
            if ~flag
                continue
            else
                break
            end
        end
    end
    if ~flag
        unassignedJob = [unassignedJob;Job_Period(i) Job_Load(i) Job_Deadline(i)];
    end
end
ActivatedServers = 1;
P_s = 0;
for i = 1:ServerNum
    if isempty(ServerResult{i})
        continue
    else
        P_v = alpha(i)*ServerResult{i}(1,4);
        for j = 1:size(ServerResult{i},1)
            P_v = P_v + beta(i)*ServerResult{i}(j,2)/ServerResult{i}(j,1);
        end
        P_s = P_s + P_v;
    end
end
end

