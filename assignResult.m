function [ServerResult, Value, index2] = assignResult( Assign , value )
%根据value值 获取最终分配到服务器的结果
v = 0;
index1 = 1;
index2 = 1;
for i = 1:size(value,2)
    for j = 1:size(value{i},2)
        vtemp = value{i}{j};
        if vtemp > v
            v = vtemp;
            index1 = i;
            index2 = j;
        end
    end
end
if v==0
    ServerResult = [];
else
    ServerResult = Assign{index1}{index2};
end
Value = v;
