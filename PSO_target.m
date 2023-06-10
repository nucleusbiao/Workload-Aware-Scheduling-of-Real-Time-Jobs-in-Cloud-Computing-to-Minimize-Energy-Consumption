function [ target ] = PSO_target( x,ServerNum,C_s,Job_Period,Job_Load,Job_Deadline, alpha, beta, gama,Lambda )
%UNTITLED9 此处显示有关此函数的摘要
%   此处显示详细说明
JobNum = size(Job_Period,2);
temp = floor(x(1:JobNum));
P_s = 0;
flag = 1;
n = 0;
for j =1:ServerNum
    a = find(temp==j);
    if isempty(a)
        continue
    else
        VMIndex = round((x(a) - temp(a))*100/ServerNum) + 1;
        p = find(VMIndex==C_s(j)+1);
        VMIndex(p) = C_s(j);
%         c = round(x(JobNum+1+sum(C_s(1:j-1)):JobNum+sum(C_s(1:j))));
%         c = round(C_s(j)*c/sum(c));
        c = round(x(JobNum+1+sum(C_s(1:j-1)):JobNum+sum(C_s(1:j))));
%         resource = c(a);
        vm = unique(VMIndex);
        try
        if sum(c(vm))>C_s(j)
            flag = 0;
            break
        end
        catch
            break
        end
        P_v = 0;
        for m = vm
            b = find(VMIndex == m);
            if c(m) <= 0
                continue
            end
            P_v = P_v + alpha(j)*c(m);
            assigntemp = [];
            for l = b
                assigntemp = [assigntemp; Job_Period(a(l)) Job_Load(a(l))/Lambda(j,a(l)) Job_Deadline(a(l)) c(m)];
                n = n + 1;
                P_v = P_v + beta(j)*Job_Load(a(l))/(Lambda(j,a(l))*Job_Period(a(l)));
            end
            flag = responseTimeFuc2(assigntemp);
            if ~flag
                break
            end            
        end
        if ~flag
            break
        end
    end
    P_s = P_s + P_v;
end
if flag == 0
    target = 0;
    return
else
    if P_s > 0
        target = gama*n + 1/P_s;
    else
        target = 0;
    end
end
end

