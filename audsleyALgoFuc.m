function scheduleFlag = audsleyALgoFuc(job_VM, newjob)
% job_VM = [Job_Period(i), Job_Load_PerUnit(i), Job_Deadline(i), resource];
resource = job_VM(end, end);
job_VM = [job_VM; newjob, resource];


scheduleFlag = true;

while 1
    for i = size(job_VM, 1):-1:1
        testJob = job_VM(i, :);
        deadline = testJob(3);
        job_VM_temp = [job_VM(1:i-1, :); job_VM(i+1:end, :); testJob];
        
        responseTimeTestJob = 0;
        for j = 1:size(job_VM_temp, 1)
            responseTimeTestJob = responseTimeTestJob + ceil(deadline/job_VM_temp(j,1))*job_VM_temp(j,2)/resource;
        end
        
        if responseTimeTestJob <= deadline
            job_VM = job_VM_temp(1:end-1, :);
            break
        elseif eq(i,1)
            scheduleFlag = false;
            break
        end
    end
    if ~scheduleFlag
        break
    elseif isempty(job_VM)
        break
    end
end