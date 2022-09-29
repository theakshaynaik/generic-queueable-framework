/**
 * @description       : Schedulable class to process the generic queueable jobs
 * @author            : Akshay Naik
 * @date              : 23.09.2022
 **/
public with sharing class GenericChainedSchedulable implements Schedulable {

    private List<GenericQueueableJob> jobs;
    private Integer currentJobNumber;
    
    /**
     * @description - constructor to set jobs and initialize currentJobNumber
     * @param jobs
     */
    public GenericChainedSchedulable(List<GenericQueueableJob> jobs) {
        this.jobs = jobs;
        this.currentJobNumber = 0;
    }

    /**
     * @description - constructor to set jobs and currentJobNumber
     * @param jobs
     * @param currentJobNumber
     */
    public GenericChainedSchedulable(List<GenericQueueableJob> jobs, Integer currentJobNumber) {
        this.jobs = jobs;
        this.currentJobNumber = currentJobNumber;
    }

    /*
    * @description: enqueue job to perform DAS Callout and update account based on the response
    * @param sc - SchedulableContext
    */
    public void execute(SchedulableContext sc) {
        System.enqueueJob(new GenericChainedQueueable(jobs, currentJobNumber));
        System.abortJob(sc.getTriggerId());
    }
}
