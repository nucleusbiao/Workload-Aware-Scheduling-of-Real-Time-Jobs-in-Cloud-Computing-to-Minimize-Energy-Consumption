function [ JobinS,unassignedJob,ServerResult,ActivatedServers ] = Schedule_MultipleServers( Job_Period,Job_Load,Job_Deadline,Lambda,ServerNum,C_s,alpha,beta,gama )
%UNTITLED3 此处显示有关此函数的摘要
%   此处显示详细说明
JobinServers_Load_PerUnit = [];
P_s = [];
for i = 1:ServerNum
    JobinServers_Load_PerUnit(i,:) = Job_Load./Lambda(i,:);
    JobinServers_Util_PerUnit(i,:) = JobinServers_Load_PerUnit(i,:)./Job_Period;
    JobinServers_UtilD_PerUnit(i,:) = JobinServers_Load_PerUnit(i,:)./Job_Deadline;
    P_s(i) = alpha(i)*C_s(i) + beta(i)*sum(JobinServers_UtilD_PerUnit(i,:));
end
[~,index] = sort(P_s, 'ascend');
%[Lambda, S_j] = sort(Lambda, 'descend');
Servers = [];
ServerResult = {};

for i = 1:ServerNum
    for x = 1:ServerNum
        eval(strcat('Assign',num2str(x),'={};'))
    end
    for x = 1:ServerNum
        eval(strcat('value',num2str(x),'={};'))
    end
    for x = 1:ServerNum
        ServerResult{x} = [];   %保存服务器最后的结果
        Value{x} = [];           %保存最终的value值
    end
    Servers = index(1:i);
    ActivatedServers = index(1:i);
    LambdaTemp = Lambda(Servers,:);
    if eq(i,1)
        S_j = ones(1,size(Job_Period,2));       
    else
        [~,S_j] = sort(LambdaTemp,'descend'); % S_j(i,j),表示第j个任务第i个选择的服务器
    end
    %更新J_s  J_s{n}{k}保存了将第Servers(n)个处理器作为第k个选择的任务
    for k = 1:i
        for n = 1:i             
            J_s{Servers(n)}{k} = find(Servers(S_j(k,:))==Servers(n));           
        end
    end

%% 按顺序根据选择服务器的优先顺序分配任务
    assignedJob = [];
    JobinS = {};
    for k = 1:i
        for n = 1:i
            ServerIndex = Servers(n);
            eval(strcat('Assign = Assign',num2str(ServerIndex),';'));
            eval(strcat('value = value',num2str(ServerIndex),';'));
            Job_PeriodTemp = Job_Period(J_s{ServerIndex}{k});
            Job_DeadlineTemp = Job_Deadline(J_s{ServerIndex}{k});
            Job_LoadTemp = Job_Load(J_s{ServerIndex}{k});
            lambda = Lambda(ServerIndex,J_s{ServerIndex}{k});
            Job_Load_PerUnit = Job_LoadTemp./lambda;
            Job_UtilD_PerUnit = Job_Load_PerUnit./Job_DeadlineTemp;

            x = 0;
            cc = 1;
            if ~isempty(Assign)    %如果服务器已存在之前分配的任务
                x = 1;
                cc = size(Assign{1},2);    %服务器已经使用的资源
                for m = cc+1:C_s(ServerIndex)
                    Assign{1}{m} = Assign{1}{cc};
                    value{1}{m} = value{1}{cc};
                end
            end
            for m = 1 + x:size(Job_PeriodTemp, 2) + x
                for j = cc:C_s(ServerIndex)
                    resource = j;
                    m1 = m-x;
                    if eq(m,1)
                        if Job_Load_PerUnit(m1)/resource < Job_DeadlineTemp(m1)
                            Assign{m}{j}{1} = [Job_PeriodTemp(m1), Job_Load_PerUnit(m1), Job_DeadlineTemp(m1), resource, J_s{ServerIndex}{k}(m1)];
                            %value{m}{j} = jobSingleValue + Job_UtilD_PerUnit(m)/resource;
                            value{m}{j} = 1/(alpha(ServerIndex)*resource + beta(ServerIndex)*Job_UtilD_PerUnit(m1))+gama*1;                       
                        else
                            Assign{m}{j} = {};
                            value{m}{j} = 0;
                        end
                    else
                        if isempty(Assign{m-1}{j})
                            if Job_Load_PerUnit(m1)/resource < Job_DeadlineTemp(m1)
                                Assign{m}{j}{1} = [Job_PeriodTemp(m1), Job_Load_PerUnit(m1), Job_DeadlineTemp(m1), resource, J_s{ServerIndex}{k}(m1)];
                                %value{m}{j} = jobSingleValue + Job_UtilD_PerUnit(m)/resource;
                                value{m}{j} = 1/(alpha(ServerIndex)*resource + beta(ServerIndex)*Job_UtilD_PerUnit(m1))+gama*1;
                            else
                                Assign{m}{j} = {};
                                value{m}{j} = 0;
                            end
                        else
                            newjob = [Job_PeriodTemp(m1), Job_Load_PerUnit(m1), Job_DeadlineTemp(m1)];
                            % 鍚堢殑鎯呭喌
                            valueTemp = [];
                            for q = 1:size(Assign{m-1}{j}, 2)
                                job_VM = Assign{m-1}{j}{q};
                                scheduleFlag = responseTimeFuc(job_VM(:,1:end-1), newjob);
                                if scheduleFlag
                                    P_v = alpha(ServerIndex) * job_VM(end,end);
                                    for l = 1:size(job_VM,1)
                                        P_v = P_v + beta(ServerIndex)*job_VM(l,2)/job_VM(l,3);
                                    end
                                    valueTemp = [valueTemp; 1/P_v];
                                else
                                    valueTemp = [valueTemp; 0];
                                end
                            end
                            [valueMax, index1] = max(valueTemp);
                            if valueMax == 0
                                valeMaxMerge = value{m-1}{j};
                            else
                                assignTemp = Assign{m-1}{j};
                                assignTemp{index1} = [assignTemp{index1};[newjob assignTemp{index1}(end,end-1), J_s{ServerIndex}{k}(m1)]];
                                valeMaxMerge = ComputeValue(assignTemp,alpha(ServerIndex),beta(ServerIndex),gama);
                            end
                            
                            % 鍒嗙殑鎯呭喌
                            resourceAssigned = 0;
                            value_Sep_max = 0;
                            for q = 1:resource-cc
                                if Job_Load_PerUnit(m1)/q < Job_DeadlineTemp(m1)
                                    resource_left = resource - q;
                                    assignTemp = Assign{m-1}{resource_left};
                                    assignTemp{end+1} = [newjob q J_s{ServerIndex}{k}(m1)];
                                    value_Sep_Temp  = ComputeValue(assignTemp,alpha(ServerIndex),beta(ServerIndex),gama);
                                    if (value_Sep_Temp  > valeMaxMerge) & (value_Sep_Temp > value_Sep_max)
                                        value_Sep_max = value_Sep_Temp ;
                                        resourceAssigned = q;
                                    end
                                end
                            end
                            
                            % 鏈?粓澶勭悊
                            if eq(resourceAssigned,0) & (valueMax > 0) % 鍚堢殑鎯呭喌
                                Assign{m}{j} = Assign{m-1}{j};
                                job_VM = Assign{m}{j}{index1};
                                job_VM = [job_VM; newjob, job_VM(end,end-1), J_s{ServerIndex}{k}(m1)];
                                Assign{m}{j}{index1} = job_VM;
                                value{m}{j} = valeMaxMerge;
                                
                            elseif ~eq(resourceAssigned,0) % 鍒嗙殑鎯呭喌
                                Assign{m}{j} = Assign{m-1}{resource - resourceAssigned};
                                size_vm = size(Assign{m}{j}, 2);
                                job_VM = [newjob, resourceAssigned, J_s{ServerIndex}{k}(m1)];
                                Assign{m}{j}{size_vm+1} = job_VM;
                                value{m}{j} = value_Sep_max;

                                
                            else % 鍚堜笉杩涳紝鍒嗕笉浜?
                                Assign{m}{j} = Assign{m-1}{j};
                                value{m}{j} = value{m-1}{j};
                            end
                        end
                    end
                end
                
            end
            % 从J_s去除已分配任务
            
            [ServerResultTemp,v,c] = assignResult( Assign , value );   %选择value最大的分配结果进行保存
            JobinS{ServerIndex} = [];
            for m = 1:size(ServerResultTemp,2) 
                assignedJob = [assignedJob;ServerResultTemp{m}(:,end)];
                JobinS{ServerIndex} = [JobinS{ServerIndex}; ServerResultTemp{m}(:,end) m*ones(size(ServerResultTemp{m}(:,end),1),1)];
            end
            assignedJob = unique(assignedJob);
            ServerResult{ServerIndex} =  ServerResultTemp;
            Value{ServerIndex} = v;
            for m = 1:size(J_s,2)
                for p = 1:size(J_s{m},2)
                    J_s{m}{p} = setdiff(J_s{m}{p},assignedJob);
                end
            end
            if v~=0
                eval(strcat('Assign',num2str(ServerIndex),'{1}{c} = ServerResultTemp;'));
                eval(strcat('value',num2str(ServerIndex),'{1}{c} = v;'));
            end
        end
        
    end
    if size(assignedJob,1)==size(Job_Period,2)
        break
    end
end
ind = setdiff(1:size(Job_Period,2),assignedJob);
unassignedJob = [];
for i = 1:size(ind,2)   
    unassignedJob = [unassignedJob;Job_Period(ind(i)) Job_Load(ind(i)) Job_Deadline(ind(i)) ind(i)];
end

end

