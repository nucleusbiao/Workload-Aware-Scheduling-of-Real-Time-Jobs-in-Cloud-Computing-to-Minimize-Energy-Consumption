function [ ActivatedServers,ServerResult ] = CloseServer( ActivatedServers,ServerResult,Lambda )
%UNTITLED 此处显示有关此函数的摘要
%   此处显示详细说明

for i = size(ActivatedServers,2):-1:1   %将效率低的服务器中的任务往前面效率高的服务器放，失败则退出
    ServerResultTemp = ServerResult;
    ServerIndex = ActivatedServers(i);
    AStemp = ActivatedServers(1:i-1);
    assign = ServerResultTemp{ServerIndex};
    for j = 1:size(assign,2)
        for k = 1:size(assign{j},1)
            JobIndex = assign{j}(k,end);
            flag = 0;
            L = Lambda(AStemp,JobIndex);
            [~,index] = sort(L,'descend');   %先选择执行该任务效率最高的服务器插入，失败则尝试下一个
            for n = index'
                assign1 = ServerResultTemp{AStemp(n)};
                for m = 1:size(assign1,2)
                    a = find(assign1{m}(:,end)==JobIndex,1);
                    if isempty(a)
                        newjob = assign{j}(k,1:end-2);
                        scheduleflag = responseTimeFuc(assign1{m}(:,1:4),newjob);
                        if scheduleflag
                            assign1{m} = [assign1{m};assign{j}(k,1:3) assign1{m}(1,end-1) JobIndex];
                            ServerResultTemp{AStemp(n)} = assign1;
                            flag = 1;
                            break
                        else
                            continue
                        end
                    else
                        assign1{m}(a,1) = (1/assign1{m}(a,1) + 1/assign{j}(k,1))^-1;
                        scheduleflag = responseTimeFuc2(assign1{m}(:,1:end));
                        if scheduleflag
                            ServerResultTemp{AStemp(n)} = assign1;
                            flag = 1;
                            break
                        else
                            continue
                        end
                    end
                end
                if flag == 1
                    break
                end
            end
            if flag == 0
                return
            end
        end
    end
    ServerResult = ServerResultTemp;
    ServerResult{ServerIndex} = [];
    ActivatedServers = AStemp;
end

end

