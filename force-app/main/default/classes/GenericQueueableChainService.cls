/**
 * @description       : Service class to run the generic queueble jobs 
 * @author            : Akshay Naik
 * @date              : 23.09.2022
 **/
public with sharing class GenericQueueableChainService {

    @TestVisible
    private static List<GenericQueueableJob> jobs = new List<GenericQueueableJob>();

    /**
     * @description - add job to generic queueable list
     * @param classType - class type that should be executed
     * @param ids - ids to be processed
     */
    public static void addJob(Type classType, Set<Id> ids) {
        GenericQueueableJob job = new GenericQueueableJob(classType, ids);
        addJob(job);
    }

    /**
     * @description - add job to generic queueable list
     * @param job - GenericQueueableJob
     */
    public static void addJob(GenericQueueableJob job) {
        if(jobs == null) {
            jobs = new List<GenericQueueableJob>();
        }
        jobs.add(job);
    }

    /**
     * @description - run the generic queueble jobs
     */
    public static void runJobInQueues() {
        if(jobs == null || jobs.isEmpty()) {
            return;
        }
        if(Test.isRunningTest()) {
            jobs = new List<GenericQueueableJob>{ jobs[0] };
        }
        if(Limits.getQueueableJobs() < Limits.getLimitQueueableJobs()) {
            executeGenericQueueable();
            return;
        }
        executeGenericSchedulable();
    }

    /**
     * @description - execute GenericChainedQueueable class
     * @param jobs
     */
    @TestVisible
    private static void executeGenericQueueable() {
        System.enqueueJob(new GenericChainedQueueable(jobs));
        jobs.clear();
    }

    /**
     * @description - execute GenericChainedSchedulable class
     * @param jobs
     */
    @TestVisible
    private static void executeGenericSchedulable() {
        Datetime nextRunTime = Datetime.now().addSeconds(10);
        String nextFireTime = String.valueOf(nextRunTime.second()) + ' ' + String.valueOf(nextRunTime.minute()) + ' ' + String.valueOf(nextRunTime.hour()) + ' * * ?';
        System.schedule('GenericChainedSchedulable ' + String.valueOf(Math.random()), nextFireTime, new GenericChainedSchedulable(jobs));
        jobs.clear();
    }
}