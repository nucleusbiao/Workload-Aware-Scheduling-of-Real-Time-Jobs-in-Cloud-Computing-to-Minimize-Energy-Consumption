function scheduleFlag = responseTimeFuc(job_VM, newjob)
% job_VM = [Job_Period(i), Job_Load_PerUnit(i), Job_Deadline(i), resource];
resource = job_VM(end, end);
job_VM = [job_VM; newjob, resource];
deadline = newjob(end);
responseTimeNewJob = 0;

for i = 1:size(job_VM, 1)
    responseTimeNewJob = responseTimeNewJob + ceil(deadline/job_VM(i,1))*job_VM(i,2)/resource;
end

if responseTimeNewJob <= deadline
    scheduleFlag = true;
else
   scheduleFlag = false; 
end