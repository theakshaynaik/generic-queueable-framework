/**
 * @description       : Test class for GenericQueueableChain
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
        UnitTestDataFactory.getRecordtypeValues();
        Country__c kr = UnitTestDataFactory.createCountry('KR', 'Korea', 'KRW');
        insert kr;
        List<Lead> leadList = UnitTestDataFactory.createLeads(3, kr, 'Mustermann', 'Yogiyo', 'KRW', 'Mustermann Food', 'Yogiyo_Lead');
        for(Lead leadObj : leadList) {
            leadObj.order_date__c = system.today();
            leadObj.commission__c = 12;
            leadObj.Tariff_Name__c = 'Regional';
            leadObj.non_standard_contract_components__c = 'BladeT&C';
            leadObj.Platform__c = 'Yogiyo';
            leadObj.LeadSource = 'Inbound';
            leadObj.email = 'Mustermann@test.com';
        }
        insert leadList;
    }

    /**
     * @description - test method for generic queueable logic
     */
    @isTest
    static void testChunkJobs() {
        Set<Id> leadIds = new Set<Id>();
        List<Lead> leadList = LeadSelector.getAll();
        for(Lead leadObj : leadList) {
            leadIds.add(leadObj.Id);
        }
        Test.startTest();
        GenericQueueableChain.chunkJobs(LeadConversionBulkAsyncService.class, leadIds, 2);
        GenericQueueableChainService.addJob(LeadConversionBulkAsyncService.class, leadIds);
        GenericChainedQueueable queueableJob = new GenericChainedQueueable(GenericQueueableChainService.jobs, 0);
        Test.stopTest();
        System.assertNotEquals(GenericQueueableChainService.jobs[0].getClassType().newInstance(), null,'Valid instance should be present');
        System.assertNotEquals(GenericQueueableChainService.jobs[0].getIds(), null,'Ids cannot be null');    
    }

    /**
     * @description - test method for generic queueable logic
     */
    @isTest
    static void testServiceExecuteGenericSchedulable() {
        Set<Id> leadIds = new Set<Id>();
        List<Lead> leadList = LeadSelector.getAll();
        for(Lead leadObj : leadList) {
            leadIds.add(leadObj.Id);
        }
        Test.startTest();
        GenericQueueableChainService.addJob(LeadConversionBulkAsyncService.class, leadIds);
        GenericQueueableChainService.executeGenericSchedulable();
        Test.stopTest();
    }

    /**
     * @description - test method for generic queueable logic
     */
    @isTest
    static void testServiceExecuteGenericQueueable() {
        Set<Id> leadIds = new Set<Id>();
        List<Lead> leadList = LeadSelector.getAll();
        for(Lead leadObj : leadList) {
            leadIds.add(leadObj.Id);
        }
        Test.startTest();
        GenericQueueableChainService.addJob(LeadConversionBulkAsyncService.class, leadIds);
        GenericQueueableChainService.executeGenericQueueable();
        Test.stopTest();
    }

    /**
     * @description - test method for generic queueable logic
     */
    @isTest
    static void testHelperExecuteGenericSchedulable() {
        Set<Id> leadIds = new Set<Id>();
        List<Lead> leadList = LeadSelector.getAll();
        for(Lead leadObj : leadList) {
            leadIds.add(leadObj.Id);
        }
        Test.startTest();
        GenericQueueableChainService.addJob(LeadConversionBulkAsyncService.class, leadIds);
        GenericChainedQueueableHelper.executeGenericSchedulable(GenericQueueableChainService.jobs,0);
        Test.stopTest();
    }

    /**
     * @description - test method for generic queueable logic
     */
    @isTest
    static void testHelperExecuteGenericQueueable() {
        Set<Id> leadIds = new Set<Id>();
        List<Lead> leadList = LeadSelector.getAll();
        for(Lead leadObj : leadList) {
            leadIds.add(leadObj.Id);
        }
        Test.startTest();
        GenericQueueableChainService.addJob(LeadConversionBulkAsyncService.class, leadIds);
        GenericChainedQueueableHelper.executeGenericQueueable(GenericQueueableChainService.jobs,0);
        Test.stopTest();
    }
}