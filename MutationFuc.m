function [ pop ] = MutationFuc( pop,popsize,ServerNum,fit )
%UNTITLED3 此处显示有关此函数的摘要
%   此处显示详细说明
pm = 0.01;
n = randi(popsize);
i = 1;
[~,index] = max(fit);
while i < n
    k = randi(popsize);
    if k == index
        break
    end       
    p = rand();
    h = randi(size(pop,1));
    if p < pm
        temp = pop(h,k) - floor(pop(h,k));
        pop(h,k) = ceil(ServerNum*rand) + temp;
    end
    i = i + 1;
end
    
end

