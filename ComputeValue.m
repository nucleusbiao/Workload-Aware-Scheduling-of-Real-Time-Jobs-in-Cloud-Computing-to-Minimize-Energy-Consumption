function value = ComputeValue( Assign ,alpha,beta,gama)
P_s = 0;
num = 0;
for i = 1:size(Assign,2)
    num = num + size(Assign{i},1);
    jobs = Assign{i};
    P_v = alpha*jobs(end,end);
    for j = 1:size(Assign{i},1)
         P_v = P_v + beta*jobs(j,2)/jobs(j,3);
    end
    P_s = P_s + P_v;
end
value = num*gama + 1/P_s;
