function pop = InitialFun( popsize, ServerNum, JobNum, C_x )

for i = 1:popsize
    pop(:,i) = ceil((ServerNum + 3)*rand(JobNum,1));
    
    for j = 1:ServerNum
        a = find(pop(:,i)==j);
        if isempty(a)
            continue
        else
            VMnum = randi(C_x(j));
            b = randi(C_x(j),VMnum,1);
            b = C_x(j)*b/sum(b);
            b = round(b);
            if sum(b) > C_x(j)
                index = find(b>1,1);
                b(index) = b(index) - 1;
            end
            index = find(b==0);
            VMnum = VMnum - length(index);
            b(index) = [];
            x = randi(VMnum,1,length(a));
            for n = 1:length(a)
                pop(a(n),i) = pop(a(n),i) + b(x(n))/10^6+ x(n)/1000;
            end
        end
    end
        
            
end

