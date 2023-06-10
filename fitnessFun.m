function [ fit ] = fitnessFun( pop,C_s, ServerNum, Lambda, Job_Period, Job_Load, Job_Deadline, alpha, beta, gama  )
%UNTITLED7 此处显示有关此函数的摘要
%   此处显示详细说明
fit = zeros(1,size(pop,2));
for i = 1:size(pop,2)
    P_s = 0;
    flag = 1;
    temp = floor(pop(:,i));
    for j = 1:ServerNum  
        
        a = find(temp==j);
        if isempty(a)
            continue
        else
            num = floor((pop(a,i) - temp(a))*1000);
            num2 = unique(num);
            resource = round((pop(a,i)*10^3 - floor(pop(a,i)*10^3))*10^3);
            c = 0;
            for k = num2'
                t = find(num==k);
                c = c + max(resource(t));
            end
            
            if c > C_s(j)
                flag = 0;
                fit(i) = 0;
                break
            end
            P_v = 0;            
            for k = num2'
                b = find(num == k);
                P_v = P_v + alpha(j)*resource(b(1));
                assigntemp = [];
                for m = b'               
                    assigntemp = [assigntemp; Job_Period(a(m)) Job_Load(a(m))/Lambda(j,a(m)) Job_Deadline(a(m)) resource(m)];
                    P_v = P_v + beta(j)*Job_Load(a(m))/(Lambda(j,a(m))*Job_Period(a(m)));
                end
                flag = responseTimeFuc2(assigntemp);
                if flag == 0
                    break
                end
            end
            if flag == 0
                fit(i) = 0;
                break
            end
        end
        P_s = P_s + P_v;
    end
    if flag == 0
        continue
    else
        n = find(temp<=ServerNum);
        n = length(n);
        if n > 0 
        	fit(i) = gama*n + 1/P_s;
        else
            fit(i) = 0;
        end

    end   
end
end

