/**
 * @description       : Helper class for GenericChainedQueueable
 * @author            : Akshay Naik
 * @date              : 23.09.2022
 **/
public with sharing class GenericChainedQueueableHelper {

    /**
     * @description - declaration for the logic to be executed in async context
     * @param genericJobsAndCurrentJobMap - map to store generic jobs and current queueable job number
     */
    public void execute(Map<String, Object> genericJobsAndCurrentJobMap) {
        Integer currentJobNumber = (Integer) genericJobsAndCurrentJobMap.get('currentJobNumber');
        Integer nextJobNumber = currentJobNumber + 1;
        List<GenericQueueableJob> jobs = (List<GenericQueueableJob>) genericJobsAndCurrentJobMap.get('jobs');
        GenericQueueableJob job = jobs[currentJobNumber];
        
        IGenericQueueable genericQueueableInstance = (IGenericQueueable) job.getClassType().newInstance();
        genericQueueableInstance.execute(job.getIds());
    
        if(nextJobNumber >= jobs.size()) {
            return;
        }
        if(Limits.getQueueableJobs() < Limits.getLimitQueueableJobs()) {
            executeGenericQueueable(jobs, nextJobNumber);
            return;
        }
        executeGenericSchedulable(jobs, nextJobNumber);
    }

    /**
     * @description - execute GenericChainedQueueable class
     * @param jobs
     * @param nextJobNumber
     */
    @TestVisible
    private static void executeGenericQueueable(List<GenericQueueableJob> jobs, Integer nextJobNumber) {
        System.enqueueJob(new GenericChainedQueueable(jobs, nextJobNumber));
    }

    /**
     * @description - execute GenericChainedSchedulable class
     * @param jobs
     * @param nextJobNumber
     */
    @TestVisible
    private static void executeGenericSchedulable(List<GenericQueueableJob> jobs, Integer nextJobNumber) {
        Datetime nextRunTime = Datetime.now().addSeconds(10);
        String nextFireTime = String.valueOf(nextRunTime.second()) + ' ' + String.valueOf(nextRunTime.minute()) + ' ' + String.valueOf(nextRunTime.hour()) + ' * * ?';
        System.schedule('GenericChainedSchedulable ' + String.valueOf(Math.random()), nextFireTime, new GenericChainedSchedulable(jobs, nextJobNumber));
    }
}
