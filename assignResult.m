function [ServerResult, Value, index2] = assignResult( Assign , value )
%����valueֵ ��ȡ���շ��䵽�������Ľ��
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
