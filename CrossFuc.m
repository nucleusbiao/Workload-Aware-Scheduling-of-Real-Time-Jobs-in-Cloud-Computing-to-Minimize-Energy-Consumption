function [ pop ] = CrossFuc( pop,popsize,fit )
%UNTITLED2 �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
pc = 0.8;
L = size(pop,1);
[~,index] = max(fit);
poptemp = pop(:,index);
for i = 1:2:popsize
    p = rand();
    if p < pc
        q = round(rand(1,L));
        for j =1:L
            if q(j) == 1
                temp = pop(j,i+1);
                pop(j,i+1) = pop(j,i);
                pop(j,i) = temp;
            end
        end
    end

end
pop(:,1) = poptemp;

