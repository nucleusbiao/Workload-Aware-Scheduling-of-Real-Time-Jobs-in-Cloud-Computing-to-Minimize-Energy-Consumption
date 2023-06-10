clc
clear
%%
sumValue = 0;
for xxxxxxx=1:1
Job_Period = 5*(1+randi(20, 1, 30));
Job_Load = randi(20, 1, 30)/10.*Job_Period;
Job_Deadline = randi(30, 1, 30)/10.*Job_Period;
Job_Lambda = (5+randi(10, 1, 30))/10;
C_s_1 = 10;
alpha = 20;
beta = 10;
gama = 10;
Job_Load_PerUnit = Job_Load./Job_Lambda;
Job_Util_PerUnit = Job_Load_PerUnit./Job_Period;
Job_UtilD_PerUnit = Job_Load_PerUnit./Job_Deadline;

%%
[Job_Deadline, Index] = sort(Job_Deadline, 'ascend');
Job_Period = Job_Period(Index);
Job_Load = Job_Load(Index);
Job_Lambda = Job_Lambda(Index);
Job_Load_PerUnit = Job_Load_PerUnit(Index);
Job_Deadline = Job_Deadline(Index);
Job_UtilD_PerUnit = Job_UtilD_PerUnit(Index);

%%
Assign = {};
value = {};
jobSingleValue = 1e2;
for i = 1:size(Job_Period, 2)
    for j = 1:C_s_1
        resource = j; 
        if eq(i,1)
            if Job_Load_PerUnit(i)/resource < Job_Deadline(i)
                Assign{i}{j}{1} = [Job_Period(i), Job_Load_PerUnit(i), Job_Deadline(i), resource];
                %value{i}{j} = jobSingleValue + Job_UtilD_PerUnit(i)/resource;
                value{i}{j} = 1/(alpha*resource + beta*Job_UtilD_PerUnit(i))+gama*1;
            else
                Assign{i}{j} = {};
                value{i}{j} = 0;
            end
        else
            if isempty(Assign{i-1}{j})
               if Job_Load_PerUnit(i)/resource < Job_Deadline(i)
                   Assign{i}{j}{1} = [Job_Period(i), Job_Load_PerUnit(i), Job_Deadline(i), resource];
                   %value{i}{j} = jobSingleValue + Job_UtilD_PerUnit(i)/resource;
                   value{i}{j} = 1/(alpha*resource + beta*Job_UtilD_PerUnit(i))+gama*1;
               else
                    Assign{i}{j} = {};
                    value{i}{j} = 0;
                end
            else
                newjob = [Job_Period(i), Job_Load_PerUnit(i), Job_Deadline(i)];
                
                % 合的情况
                valueTemp = [];
                for k = 1:size(Assign{i-1}{j}, 2)
                    job_VM = Assign{i-1}{j}{k};                    
                    scheduleFlag = responseTimeFuc(job_VM, newjob);
                    if scheduleFlag 
                        P_v = alpha * job_VM(end,end);
                        for m = 1:size(job_VM,1)
                            P_v = P_v + beta*job_VM(m,2)/job_VM(m,3);
                        end
                        valueTemp = [valueTemp; 1/P_v];
                    else
                        valueTemp = [valueTemp; 0];
                    end
                end  
                [valueMax, index] = max(valueTemp);
                if valueMax == 0
                    valeMaxMerge = value{i-1}{j};
                else
                    assignTemp = Assign{i-1}{j};
                    assignTemp{index} = [assignTemp{index};[newjob assignTemp{index}(end,end)]];
                    valeMaxMerge = ComputeValue(assignTemp,alpha,beta,gama);
                end

                
                % 分的情况
                resourceAssigned = 0;
                value_Sep_max = 0;
                for k = 1:resource-1
                    if Job_Load_PerUnit(i)/k < Job_Deadline(i)
                        

                        resource_left = resource - k;
                        assignTemp = Assign{i-1}{resource_left};
                        assignTemp{end+1} = [newjob k];
                        value_Sep_Temp  = ComputeValue(assignTemp,alpha,beta,gama);

                        if (value_Sep_Temp  > valeMaxMerge) & (value_Sep_Temp > value_Sep_max)
                            value_Sep_max = value_Sep_Temp ;
                            resourceAssigned = k;
                        end                            
                    end
                end
                
                % �?��处理
                if eq(resourceAssigned,0) & (valueMax > 0)  % 合的情况  
                    Assign{i}{j} = Assign{i-1}{j};
                    job_VM = Assign{i}{j}{index};    
                    job_VM = [job_VM; newjob, job_VM(end,end)];
                    Assign{i}{j}{index} = job_VM;    
                    value{i}{j} = valeMaxMerge;
                    
                elseif ~eq(resourceAssigned,0) % 分的情况
                    Assign{i}{j} = Assign{i-1}{resource - resourceAssigned};
                    size_vm = size(Assign{i}{j}, 2);
                    job_VM = [newjob, resourceAssigned];
                    Assign{i}{j}{size_vm+1} = job_VM;
                    value{i}{j} = value_Sep_max;
                    
                else % 合不进，分不�?
                    Assign{i}{j} = Assign{i-1}{j};
                    value{i}{j} = value{i-1}{j};
                end
            end
        end
    end
end



end
[ServerResult, Value, index2] = assignResult( Assign , value );
    