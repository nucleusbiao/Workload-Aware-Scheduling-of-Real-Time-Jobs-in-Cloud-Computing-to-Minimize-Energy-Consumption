function [ pop ] = SelectFuc( fit,popsize,pop )
%UNTITLED 此处显示有关此函数的摘要
%   此处显示详细说明
sum_fit = sum(fit);
value = fit./sum_fit;
value = cumsum(value);
ms = sort(rand(popsize,1));
n = 1;
i = 1;
try
while i < popsize
    if ms(i) < value(n)
        pop(:,i) = pop(:,n);
        i = i + 1;
    else
        n = n + 1;
    end
end
catch
    c= 1;
end

