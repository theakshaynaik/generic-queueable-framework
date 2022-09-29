/**
 * @description       : Test class for GenericQueueable Framework
 * @author            : Akshay Naik
 * @date              : 23.09.2022
 **/
@isTest
private class GenericQueueableChain_Test {

    /**
     * @description - setup test data
     */
    @TestSetup
    static void setupData() {
        List<Opportunity> oppList = new List<Opportunity>();
        for(Integer i = 0; i < 3; i++) {
            Opportunity oppObj = new Opportunity();
            oppObj.CloseDate = Date.today().addMonths(1);
            oppObj.Name = 'test opp';
            oppObj.StageName = 'New';
            oppList.add(oppObj);
        }
        insert oppList;
    }

    /**
     * @description - test method for single queueable job
     */
    @isTest
    static void testSingleJob() {
        Opportunity oppObj = [SELECT Id FROM Opportunity LIMIT 1];
        Test.startTest();
        GenericQueueableChain.chunkJobs(GenericQueueableImpl.class, new Set<Id>{oppObj.Id}, 2);
        GenericQueueableChainService.addJob(GenericQueueableImpl.class, new Set<Id>{oppObj.Id});
        GenericChainedQueueable queueableJob = new GenericChainedQueueable(GenericQueueableChainService.jobs, 0);
        Test.stopTest();
        List<AsyncApexJob> asyncJobList = [SELECT Id, JobType, Status, ApexClassId, ApexClass.Name FROM AsyncApexJob WHERE ApexClass.Name = 'GenericChainedQueueable'];
        System.assertNotEquals(asyncJobList, null, 'Async job should be queued'); 
    }

    /**
     * @description - test method for bulk queueable jobs
     */
    @isTest
    static void testBulkChunkJobs() {
        Set<Id> oppIds = new Set<Id>();
        for(Opportunity oppObj : [SELECT Id FROM Opportunity LIMIT 3]) {
            oppIds.add(oppObj.Id);
        }
        Test.startTest();
        GenericQueueableChain.chunkJobs(GenericQueueableImpl.class, oppIds, 2);
        GenericQueueableChainService.addJob(GenericQueueableImpl.class, oppIds);
        GenericChainedQueueable queueableJob = new GenericChainedQueueable(GenericQueueableChainService.jobs, 0);
        Test.stopTest();
        List<AsyncApexJob> asyncJobList = [SELECT Id, JobType, Status, ApexClassId, ApexClass.Name FROM AsyncApexJob WHERE ApexClass.Name = 'GenericChainedQueueable'];
        System.assertNotEquals(asyncJobList, null, 'Async job should be queued'); 
    }

    /**
     * @description - test method for service scheduable job
     */
    @isTest
    static void testServiceExecuteGenericSchedulable() {
        Opportunity oppObj = [SELECT Id FROM Opportunity LIMIT 1];
        Test.startTest();
        GenericQueueableChainService.addJob(GenericQueueableImpl.class, new Set<Id>{oppObj.Id});
        GenericQueueableChainService.executeGenericSchedulable();
        Test.stopTest();
        List<AsyncApexJob> asyncJobList = [SELECT Id, JobType, Status, ApexClassId, ApexClass.Name FROM AsyncApexJob WHERE ApexClass.Name = 'GenericChainedSchedulable'];
        System.assertNotEquals(asyncJobList, null, 'Async job should be scheduled'); 
    }

    /**
     * @description - test method for service queueable job
     */
    @isTest
    static void testServiceExecuteGenericQueueable() {
        Opportunity oppObj = [SELECT Id FROM Opportunity LIMIT 1];
        Test.startTest();
        GenericQueueableChainService.addJob(GenericQueueableImpl.class, new Set<Id>{oppObj.Id});
        GenericQueueableChainService.executeGenericQueueable();
        Test.stopTest();
        List<AsyncApexJob> asyncJobList = [SELECT Id, JobType, Status, ApexClassId, ApexClass.Name FROM AsyncApexJob WHERE ApexClass.Name = 'GenericChainedQueueable'];
        System.assertNotEquals(asyncJobList, null, 'Async job should be queued'); 
    }

    /**
     * @description - test method for helper scheduable job
     */
    @isTest
    static void testHelperExecuteGenericSchedulable() {
        Opportunity oppObj = [SELECT Id FROM Opportunity LIMIT 1];
        Test.startTest();
        GenericQueueableChainService.addJob(GenericQueueableImpl.class, new Set<Id>{oppObj.Id});
        GenericChainedQueueableHelper.executeGenericSchedulable(GenericQueueableChainService.jobs,0);
        Test.stopTest();
        List<AsyncApexJob> asyncJobList = [SELECT Id, JobType, Status, ApexClassId, ApexClass.Name FROM AsyncApexJob WHERE ApexClass.Name = 'GenericChainedSchedulable'];
        System.assertNotEquals(asyncJobList, null, 'Async job should be scheduled'); 
    }

    /**
     * @description - test method for helper queueable job
     */
    @isTest
    static void testHelperExecuteGenericQueueable() {
        Opportunity oppObj = [SELECT Id FROM Opportunity LIMIT 1];
        Test.startTest();
        GenericQueueableChainService.addJob(GenericQueueableImpl.class, new Set<Id>{oppObj.Id});
        GenericChainedQueueableHelper.executeGenericQueueable(GenericQueueableChainService.jobs,0);
        Test.stopTest();
        List<AsyncApexJob> asyncJobList = [SELECT Id, JobType, Status, ApexClassId, ApexClass.Name FROM AsyncApexJob WHERE ApexClass.Name = 'GenericChainedQueueable'];
        System.assertNotEquals(asyncJobList, null, 'Async job should be queued'); 
    }

    /**
     * @description - test method for single queueable job failure scenario
     */
    @isTest
    static void testSingleJobFailure() {
        Opportunity oppObj = [SELECT Id FROM Opportunity LIMIT 1];
        Test.startTest();
        GenericQueueableChain.chunkJobs(Integer.class, new Set<Id>{oppObj.Id}, 2);
        GenericQueueableChainService.addJob(Integer.class, new Set<Id>{oppObj.Id});
        Test.stopTest();
        List<AsyncApexJob> asyncJobList = [SELECT Id, JobType, Status, ApexClassId, ApexClass.Name FROM AsyncApexJob WHERE ApexClass.Name = 'GenericChainedQueueable'];
        System.assertNotEquals(asyncJobList, null, 'Async job should be queued'); 
    }
}