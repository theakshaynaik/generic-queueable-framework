/**
 * @description       : Helper class for GenericChainedQueueable
 * @author            : Akshay Naik
 * @date              : 23.09.2022
 **/
public with sharing class GenericChainedQueueableHelper {

    /**
     * @description - execute the logic as per the classtype and re-queue the next job, if any
     * @param genericJobsAndCurrentJobMap - map to store generic jobs and current job number
     */
    public void execute(Map<String, Object> genericJobsAndCurrentJobMap) {
        Integer nextJobNumber;
        List<GenericQueueableJob> jobs;
        try {
            Integer currentJobNumber = (Integer) genericJobsAndCurrentJobMap.get('currentJobNumber');
            nextJobNumber = currentJobNumber + 1;
            jobs = (List<GenericQueueableJob>) genericJobsAndCurrentJobMap.get('jobs');
            GenericQueueableJob job = jobs[currentJobNumber];
            IGenericQueueable genericQueueableInstance = (IGenericQueueable) job.getClassType().newInstance();
            genericQueueableInstance.execute(job.getIds());
        } catch (Exception e) {
            System.debug('Exception: ' + e.getLineNumber() + ' error: ' + e.getMessage());
        } finally {
            if(nextJobNumber >= jobs.size()) {
                return;
            }
            if(Limits.getQueueableJobs() < Limits.getLimitQueueableJobs()) {
                executeGenericQueueable(jobs, nextJobNumber);
                return;
            }
            executeGenericSchedulable(jobs, nextJobNumber);
        }
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
