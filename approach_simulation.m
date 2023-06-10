clc
clear
%%
for x = 1:100
    tic
    JobNum = 20;
    ServerNum = 10;
    eval(strcat('load .\多服务器数据\',num2str(JobNum),'\',num2str(JobNum),'Jobdata',num2str(x),'.mat;'));
    C_s = 100/ServerNum*ones(1,ServerNum);
    alpha = 0.5*ones(1,ServerNum);
    beta = 2*ones(1,ServerNum);
    gama = 10;
    [Job_Deadline, Index] = sort(Job_Deadline, 'ascend');
    Job_Period = Job_Period(Index);
    Job_Load = Job_Load(Index);
    Lambda = Lambda(1:ServerNum,:);
    %% A-DP
   tic
    [ JobinS,unassignedJob,ServerResult,ActivatedServers ] = Schedule_MultipleServers( Job_Period,Job_Load,Job_Deadline,Lambda,ServerNum,C_s,alpha,beta,gama );
   t1(x) = toc;
    P_s1(x) = 0;
    for i = ActivatedServers
        P_v = 0;
        for j = 1:size(ServerResult{i},2)
            P_v = P_v + alpha(i)*ServerResult{i}{j}(1,end-1);
            for k = 1:size(ServerResult{i}{j},1)
                P_v = P_v + beta(i)*ServerResult{i}{j}(k,2)/ServerResult{i}{j}(k,1);
            end
        end
        P_s1(x) = P_s1(x) + P_v;
    end
    assignNum1(x) = JobNum - size(unassignedJob,1);
%     eval(strcat('save E:\work\code\code\数据\A-DP_1Server50Job_Result',num2str(x),'.mat assignNum P_s  t'));
    SR = ServerResult;
    %% S-Strategy1
   tic
    [ ServerResult,ActivatedServers,unassignedJob ] = S_Strategy( Job_Period,Job_Load,Job_Deadline,Lambda,ServerNum,C_s,alpha,beta,gama );
   t2(x) = toc;
    P_s2(x) = 0;
    for i = ActivatedServers
        if isempty(ServerResult{i})
            continue
        else
            P_v = alpha(i)*sum(ServerResult{i}(:,4));
            for j = 1:size(ServerResult{i},1)
                P_v = P_v + beta(i)*ServerResult{i}(j,2)/ServerResult{i}(j,1);
            end
            P_s2(x) = P_s2(x) + P_v;
        end
    end
    assignNum2(x) = JobNum - size(unassignedJob,1);
%     eval(strcat('save E:\work\code\code\数据\S-Strategy_1Server50Job_Result',num2str(x),'.mat assignNum P_s ServerResult t'));

    %% 粒子群算法
    n = 200;
   tic
    [Gbest_y, Gbest_x,ServerResult,P_s3(x)] = PSO( n,ServerNum,C_s,Job_Period,Job_Load,Job_Deadline, alpha, beta, gama,Lambda,0);
   t3(x) = toc;
    assignNum3(x) = floor(Gbest_y/10);
%     eval(strcat('save E:\work\code\code\数据\PSO_1Server50Job_Result',num2str(x),'.mat assignNum P_s ServerResult t'));
    %% PSO+

    n = 200;
    xi = zeros(n,JobNum+sum(C_s));
    xi(2:n,1:JobNum) = randi(ServerNum+2,n-1,JobNum) + (randi(100,n-1,JobNum)-1)./100;
    xi(2:n,JobNum+1:JobNum+C_s(1)) = randi(C_s(1),n-1,C_s(1));
    for i = 2:ServerNum
        xi(:,JobNum+1+sum(C_s(1:i-1)):JobNum+sum(C_s(1:i))) = randi(C_s(i),n,C_s(i));
    end
    for ServerIndex = 1:size(SR,2)
        for p = 1:size(SR{ServerIndex},2)
            for q = 1:size(SR{ServerIndex}{p},1)
                JobIndex = SR{ServerIndex}{p}(q,end);
                xi(1,JobIndex) = ServerIndex + (p-1)*ServerNum/100;
                xi(1,JobNum+sum(C_s(1:ServerIndex-1))+p) = SR{ServerIndex}{p}(q,end-1);
            end
        end
    end
    tic
    [Gbest_y, Gbest_x,ServerResult,P_s4(x)] = PSO( n,ServerNum,C_s,Job_Period,Job_Load,Job_Deadline, alpha, beta, gama,Lambda,1,xi);
    t4(x) = toc;
    assignNum4(x) = floor(Gbest_y/10);
%     eval(strcat('save E:\work\code\code\数据\PSOwi_1Server50Job_Result',num2str(x),'.mat assignNum P_s ServerResult t'));
    %% S-Strategy2
    tic
    [ ServerResult,P_s5(x),unassignedJob ] = SimpleSchedule( Job_Period,Job_Load,Job_Deadline,Lambda,ServerNum,C_s,alpha,beta,gama  );
    t5(x) = toc;
    assignNum5(x) = JobNum - size(unassignedJob,1);
    
end
eval(strcat('save E:\work\code\code\实验代码（5组不同任务数）\result\',num2str(JobNum),'\1Server50Job_Result',num2str(x),...
    '.mat assignNum1 P_s1 t1 assignNum2 P_s2 t2 assignNum3 P_s3 t3 assignNum4 P_s4 t4 assignNum5 P_s5 t5'));



