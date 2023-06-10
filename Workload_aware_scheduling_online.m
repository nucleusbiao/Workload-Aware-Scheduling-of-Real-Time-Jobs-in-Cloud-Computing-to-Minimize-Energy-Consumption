clc
clear

ServerNum = 5;
JobNum = 100;

pp = 0.5;  %周期

C_s = 100*ones(1,ServerNum);
alpha = 0.5*ones(1,ServerNum);
beta = 2*ones(1,ServerNum);
gama = 10;
ActivatedServers2 = [];
for xx = 1:50
    eval(strcat('load E:\work\code\code\动态任务实验\data\data',num2str(xx),'.mat'));
    [Job_Deadline, Index] = sort(Job_Deadline, 'ascend');
    Job_Period = Job_Period(:,Index);
    Job_Load = Job_Load(Index);
    %%
    tic
    for q = 1:24/pp
        Job_PeriodTemp = min(Job_Period((q-1)*2*pp+1:q*2*pp,:),[],1);
        if q==1
            
            %JobinS保存了每个服务器里的任务、虚拟机编号
            [ JobinS,unassignedJob,ServerResult,ActivatedServers] = Schedule_MultipleServers( Job_PeriodTemp,Job_Load,Job_Deadline,Lambda,ServerNum,C_s,alpha,beta,gama );
        else
            oldPeriod = Job_Period(q-1,:);
            left_Period = [];      %未被吸收的
            left_Load = [];
            left_Deadline = [];
            L = [];
            Num = [];
            f = zeros(1,size(Job_PeriodTemp,2));
            for JobIndex = 1:size(Job_PeriodTemp,2)
                f(JobIndex) = 1/Job_PeriodTemp(JobIndex) - 1/oldPeriod(JobIndex);
                if f(JobIndex) > 0
                    %% 频率增大
                    for i = ActivatedServers
                        a = find(JobinS{i}(:,1)==JobIndex);
                        if isempty(find(JobinS{i}(:,1)==JobIndex,1))
                            continue
                        else
                            VMIndex = JobinS{i}(a,2);
                        end
                        assign = ServerResult{i};
                        right = f(JobIndex);
                        ftemp = right;
                        left = 0;
                        while right-left>0.00001          %二分法搜索
                            assignTemp = assign;
                            index = find(assignTemp{VMIndex}(:,end)==JobIndex);
                            assignTemp{VMIndex}(index,1) = (1/assignTemp{VMIndex}(index,1) + f(JobIndex))^-1;
                            scheduleFlag = responseTimeFuc2(assignTemp{VMIndex}(:,1:4));
                            if scheduleFlag
                                left = ftemp;
                                ServerResult{i} = assignTemp;
                            else
                                right = ftemp;
                            end
                            ftemp = (right + left)/2;
                        end
                        ftemp = left;
                        f(JobIndex) = f(JobIndex) - ftemp;
                        if f(JobIndex)==0
                            break
                        end
                    end
                    
                else
                    %% 频率减小
                    for i = fliplr(ActivatedServers)
                        a = find(JobinS{i}(:,1)==JobIndex);
                        if isempty(find(JobinS{i}(:,1)==JobIndex,1))
                            continue
                        else
                            VMIndex = JobinS{i}(a,2);
                        end
                        assign = ServerResult{i};
                        index = find(assign{VMIndex}(:,end)==JobIndex);
                        if 1/assign{VMIndex}(index,1) + f(JobIndex) > 0
                            assign{VMIndex}(index,1) = (1/assign{VMIndex}(index,1) + f(JobIndex))^-1;
                            ServerResult{i} = assign;
                            f(JobIndex) = 0;
                        else
                            f(JobIndex) = f(JobIndex) + 1/assign{VMIndex}(index,1);
                            assign{VMIndex}(index,:) = [];
                        end
                        if f(JobIndex) == 0
                            break
                        end
                    end
                end
                if f(JobIndex) > 0    %未被吸收完的任务
                    left_Period = [left_Period 1/f(JobIndex)];
                    left_Load = [left_Load Job_Load(JobIndex)];
                    left_Deadline = [left_Deadline Job_Deadline(JobIndex)];
                    L = [L Lambda(:,JobIndex)];
                    Num = [Num JobIndex];
                end
            end
            if ~isempty(left_Period)
                C_sTemp = C_s;
                C_sTemp(ActivatedServers) = [];
                SIndex = setdiff(1:ServerNum,ActivatedServers);
                if size(ActivatedServers,2)==ServerNum
                    [ JobinS,unassignedJob,ServerResult,ActivatedServers] = Schedule_MultipleServers( Job_PeriodTemp,Job_Load,Job_Deadline,Lambda,ServerNum,C_s,alpha,beta,gama );
                else
                    [ JobinS2,unassignedJob2,ServerResult2,ActivatedServers2] = Schedule_MultipleServers( left_Period,left_Load,left_Deadline,L,ServerNum-size(ActivatedServers,2),C_sTemp,alpha,beta,gama );
                    
                    [ServerResult2,JobinS2 ] = tfIndex( ServerResult2,JobinS2, Num );
                    
                    ActivatedServers = [ActivatedServers SIndex(ActivatedServers2)];
                    ServerResult(SIndex(ActivatedServers2)) = ServerResult2(ActivatedServers2);
                    JobinS(SIndex(ActivatedServers2)) = JobinS2(ActivatedServers2);
                    ActivatedServers2 = SIndex(ActivatedServers2);
                end
            else
                [ ActivatedServers,ServerResult ] = CloseServer( ActivatedServers,ServerResult,Lambda ) ;
            end
            
        end
        EnergyConsumption(q) = EnergyConsumptionFuc( ServerResult,ActivatedServers,alpha,beta,pp );
    end
    TotalEnergyConsumption1(xx) = sum(EnergyConsumption);
    t1(xx) = toc;
    %% 取最大频率
    for k = 1:JobNum
        Job_PeriodTemp(k) = min(Job_Period(:,k));
    end
    %% S-Strategy1
    tic
    [ ServerResult,ActivatedServers,unassignedJob ] = S_Strategy( Job_PeriodTemp,Job_Load,Job_Deadline,Lambda,ServerNum,C_s,alpha,beta,gama );
    t2(xx) = toc;
    P_s2(xx) = 0;
    for i = ActivatedServers
        if isempty(ServerResult{i})
            continue
        else
            P_v = alpha(i)*sum(ServerResult{i}(:,4));
            for j = 1:size(ServerResult{i},1)
                P_v = P_v + beta(i)*ServerResult{i}(j,2)/ServerResult{i}(j,1);
            end
            P_s2(xx) = P_s2(xx) + P_v;
        end
    end
    TotalEnergyConsumption2(xx) = P_s2(xx)*24*60*60;
    %% S-Strategy2
    tic
    [ ServerResult,P_s5(xx),unassignedJob ] = SimpleSchedule( Job_Period(17,:),Job_Load,Job_Deadline,Lambda,ServerNum,C_s,alpha,beta,gama  );
    t5(xx) = toc;
    TotalEnergyConsumption5(xx) = P_s5(xx)*24*60*60;
    
end




