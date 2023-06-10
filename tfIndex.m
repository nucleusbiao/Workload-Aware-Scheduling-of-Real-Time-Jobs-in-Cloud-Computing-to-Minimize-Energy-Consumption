function [ServerResult,JobinS ] = tfIndex( ServerResult,JobinS, Num )
%UNTITLED2 此处显示有关此函数的摘要
%   此处显示详细说明
for i = 1:size(ServerResult,2)
    for j = 1:size(ServerResult{i},2)
        ServerResult{i}{j}(:,end) = Num(ServerResult{i}{j}(:,end))';
    end
    
end
for i = 1:size(JobinS,2)
    if ~isempty(JobinS{i})
     JobinS{i}(:,1) = Num( JobinS{i}(:,1));
    end
end

