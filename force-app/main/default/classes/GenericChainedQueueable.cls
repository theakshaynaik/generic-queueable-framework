/**
 * @description       : Queueable class to process the generic queueable jobs
 * @author            : Akshay Naik
 * @date              : 23.09.2022
 **/
public with sharing class GenericChainedQueueable implements Queueable, Database.AllowsCallouts {
    
    private List<GenericQueueableJob> jobs;
    private Integer currentJobNumber;

    /**
     * @description - constructor to set jobs and initialize currentJobNumber
     * @param jobs
     */
    public GenericChainedQueueable(List<GenericQueueableJob> jobs) {
        this.jobs = jobs;
        this.currentJobNumber = 0;
    }

    /**
     * @description - constructor to set jobs and currentJobNumber
     * @param jobs
     * @param currentJobNumber
     */
    public GenericChainedQueueable(List<GenericQueueableJob> jobs, Integer currentJobNumber) {
        this.jobs = jobs;
        this.currentJobNumber = currentJobNumber;
    }

    /**
     * @description - to call the helper logic
     * @param context - QueueableContext
     */
    public void execute(QueueableContext context) {
        if(this.jobs == null || this.currentJobNumber == null) {
            return;
        }
        Map<String, Object> genericJobsAndCurrentJobMap = new Map<String, Object>();
        genericJobsAndCurrentJobMap.put('jobs', this.jobs);
        genericJobsAndCurrentJobMap.put('currentJobNumber', this.currentJobNumber);
        new GenericChainedQueueableHelper().execute(genericJobsAndCurrentJobMap);
    }
}