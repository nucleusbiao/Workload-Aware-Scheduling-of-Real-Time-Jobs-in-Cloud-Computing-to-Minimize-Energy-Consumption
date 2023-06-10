function [ Gbest_y, Gbest_x,ServerResult,P_s] = PSO( n,ServerNum,C_s,Job_Period,Job_Load,Job_Deadline, alpha, beta, gama,Lambda,flag,x )
%粒子群算法

c1 = 2;                                   % 加速常数1，控制局部最优解
c2 = 2;                                   % 加速常数2，控制全局最优解
w = 0.6;                                  % 惯性因子
max_iteration = 10000;                      % 最大迭代数
                               % 速度最大值
JobNum = size(Job_Period,2);
if ~flag
    x = zeros(n,JobNum+sum(C_s));
    x(:,1:JobNum) = randi(ServerNum+2,n,JobNum) + (randi(100,n,JobNum)-1)./100;
    x(:,JobNum+1:JobNum+C_s(1)) = randi(C_s(1),n,C_s(1));
    for i = 2:ServerNum
        x(:,JobNum+1+sum(C_s(1:i-1)):JobNum+sum(C_s(1:i))) = randi(C_s(i),n,C_s(i));
    end
    Pbest_y=zeros(1,n);                        % 各个粒子的函数值作为其局部最优解
    Gbest_y=0;                              % 全局最优解的初始值设置为inf
else
    Gbest_y = PSO_target( x(1,:),ServerNum,C_s,Job_Period,Job_Load,Job_Deadline, alpha, beta, gama,Lambda );
    Pbest_y=zeros(1,n);                        % 各个粒子的函数值作为其局部最优解
    Pbest_y(1) = Gbest_y;
end
Pbest_x=x;                                % 将初始位置设置为局部最优解的位置

Gbest_x = x(1,:);                         % 初始全局最优位置设定为第一个粒子的位置

v = zeros(n,size(x,2));
v(:,1:JobNum) = randi(100,n,JobNum)/100;
v(:,JobNum+1:end) = randi(5,n,sum(C_s));
k=1;
y = Gbest_y;
while k<max_iteration
    for i = 1:n
        target(i) = PSO_target( x(i,:),ServerNum,C_s,Job_Period,Job_Load,Job_Deadline, alpha, beta, gama,Lambda );
        if target(i)>Pbest_y(i)
            Pbest_y(i)=target(i);      
            Pbest_x(i,:)=x(i,:);   
        end
    end
    % 更新全局最优位置及适应值
    [Gbest_y,index] = max(Pbest_y);
    Gbest_x = Pbest_x(index,:);
    y = [y Gbest_y];
    for i = 1:n
        v(i,:)=w*v(i,:)+c1*rand()*(Pbest_x(i,:)-x(i,:))+c2*rand()*(Gbest_x-x(i,:));
        v(i,:) = roundn(v(i,:),-2); 
%         tt = find(v(i,1:50)>10);
%         v(i,tt) = 2;
%         tt = find(v(i,1:50)<-10);
%         v(i,tt) = -2;
        x(i,:)=x(i,:)+v(i,:);
        a = find(x(i,:)<0);
        x(i,a) = 0;
        a = find(x(i,1:JobNum)==0);
        x(i,a) = randi(ServerNum);
    end
    k = k + 1;
end
plot(y);
for i = 1:ServerNum
    ServerResult = {};
end
temp = floor(Gbest_x(1:JobNum));
P_s = 0;
for j =1:ServerNum
    a = find(temp==j);
    if isempty(a)
        continue
    else
        VMIndex = round((Gbest_x(a) - temp(a))*100/ServerNum) + 1;
        p = find(VMIndex==C_s(j)+1);
        VMIndex(p) = C_s(j);
        %         c = round(Gbest_x(JobNum+1+sum(C_s(1:j-1)):JobNum+sum(C_s(1:j))));
        %         c = round(C_s(j)*c/sum(c));
        c = round(Gbest_x(JobNum+1+sum(C_s(1:j-1)):JobNum+sum(C_s(1:j))));
        vm = unique(VMIndex);
        P_v = 0;
        for m = 1:length(vm)
            b = find(VMIndex == vm(m));
            if c(vm(m)) == 0
                continue
            end
            P_v = P_v + alpha(j)*c(vm(m));
            assigntemp = [];
            for l = b
                assigntemp = [assigntemp; Job_Period(a(l)) Job_Load(a(l))/Lambda(j,a(l)) Job_Deadline(a(l)) c(vm(m))];
                P_v = P_v + beta(j)*Job_Load(a(l))/(Lambda(j,a(l))*Job_Period(a(l)));
            end
            ServerResult{j}{m} = assigntemp;
        end
    end
    P_s = P_s + P_v;
end

