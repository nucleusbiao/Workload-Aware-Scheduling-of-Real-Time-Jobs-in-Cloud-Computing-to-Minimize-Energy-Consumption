function scheduleFlag = responseTimeFuc2(job_VM)

scheduleFlag = true;
resource = job_VM(end,end);
for i = 1:size(job_VM, 1)
    responseTime = 0;
    for j = 1:i
        if i == 1
            responseTime = job_VM(j,2)/resource;
        else
            responseTime = responseTime + ceil(job_VM(i,3)/job_VM(j,1))*job_VM(j,2)/resource;
        end
        if responseTime > job_VM(i,3)
            scheduleFlag = false;
            break
        end
    end
    if scheduleFlag == false
        break
    end
end
end

