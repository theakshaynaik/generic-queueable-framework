/**
 * @description       : Test class for GenericQueueable Framework
 * @author            : Akshay Naik
 * @date              : 23.09.2022
 **/
@isTest
private class GenericQueueableChain_Test {
 
    private static final String PROCESSNAME_NEWLEADVALIDATION = 'NewLeadValidation';
    private static final String RULENAME_MANDATORYFIELDS = 'MandatoryFields';
    private static final String RULENAME_PERFORMSALESREPCHECK = 'PerformSalesRepCheck';
    private static final String PROCESSNAME_NEWLEADCONVERSION = 'NewLeadConversion';
    private static final String RULENAME_OWNERIDCONFIG = 'ownerIdConfig';
    private static final String RULENAME_ACCOUNTFIELDSMAPPINGCONFIG = 'accountFieldsMappingConfig';
    private static final String RULENAME_CONTACTFIELDSMAPPINGCONFIG = 'contactFieldsMappingConfig';
    private static final String RULENAME_OPPORTUNITYFIELDSMAPPINGCONFIG = 'opportunityFieldsMappingConfig';
    private static final String RULENAME_ADDRESSFIELDSMAPPINGCONFIG = 'addressFieldsMappingConfig';
    
    /**
     * @description - setup test data
     */
    @TestSetup
    static void setupData() {
        UnitTestDataFactory.getRecordtypeValues();
	    Integration_Config__c cs1 = new Integration_Config__c(Name = 'GoogleMapsSignature', Password__c = 'Abvcd-asdfdgfhjklhnO0=');
        insert cs1;
        Map<Id, User> userMap = UserSelector.getUsersWithDynamicCondition('Id, Name, CompanyName, Entity__c, Title', 'Title LIKE \'%City Head%\' AND CompanyName = \'Talabat\' AND IsActive = True ORDER BY Name');
        User userObj = userMap.values()[0];
        Country__c countryAE = UnitTestDataFactory.createCountry('AE','United Arab Emirates', 'AED');
        insert new List<Country__c>{countryAE};
        List<Business_Config__c> configList = new List<Business_Config__c>();
        configList.add(UnitTestDataFactory.createBusinessConfig(PROCESSNAME_NEWLEADVALIDATION, 'Process', RULENAME_MANDATORYFIELDS, 'State,City,Company,LeadSource,Email,Area__c,Target_Partner__c,Delivery_Area_Check__c', countryAE.Id, 'Talabat_Lead', true, true));
        configList.add(UnitTestDataFactory.createBusinessConfig(PROCESSNAME_NEWLEADCONVERSION, 'Process', RULENAME_OWNERIDCONFIG, '{"defaultOwner":"'+userObj.Id+'","mechanism":"RecommendationRule","LeadField":"OwnerId"}', countryAE.Id, 'Talabat_Lead', true, true));
        configList.add(UnitTestDataFactory.createBusinessConfig(PROCESSNAME_NEWLEADCONVERSION, 'Process', RULENAME_ACCOUNTFIELDSMAPPINGCONFIG, '{"FieldMapping":{"Delivery_Area_Check__c":"Delivery_Area_Check__c"},"DataMapping":{ "Type":"Branch - Main"}}', countryAE.Id, 'Talabat_Lead', true, true));
        configList.add(UnitTestDataFactory.createBusinessConfig(PROCESSNAME_NEWLEADCONVERSION, 'Process', RULENAME_CONTACTFIELDSMAPPINGCONFIG, '{"FieldMapping":{ "Email":"Email"},"DataMapping":{ "Contact_Role__c":"Owner" }}', countryAE.Id, 'Talabat_Lead', true, true));
        configList.add(UnitTestDataFactory.createBusinessConfig(PROCESSNAME_NEWLEADCONVERSION, 'Process', RULENAME_OPPORTUNITYFIELDSMAPPINGCONFIG, '{"FieldMapping":{"Mark_for_Testing_Training__c":"Mark_for_Testing_Training__c"},"DataMapping":{"Type":"Contract & Product","Business_Type__c":"New Business"}}', countryAE.Id, 'Talabat_Lead', true, true));
        configList.add(UnitTestDataFactory.createBusinessConfig(PROCESSNAME_NEWLEADCONVERSION, 'Process', RULENAME_ADDRESSFIELDSMAPPINGCONFIG, '{"FieldMapping":{"LatLng__Longitude__s":"Coordinates__Longitude__s","LatLng__Latitude__s":"Coordinates__Latitude__s","CountryName__c":"country"},"CompositeMapping":{"AddressLine__c":"street,city,postalCode,country"},"DataMapping":{"Type__c":"Billing Address;Shipping Address;Restaurant Address"}}', countryAE.Id, 'Talabat_Lead', true, true));
        insert configList;
        List<Lead> leadList = UnitTestDataFactory.createLeads(3, countryAE, 'LastNameStr', 'Talabat', 'AED', 'Burger King', 'Talabat_Lead');
        for(Lead leadObj : leadList) {
            leadObj.Record_Country__c = 'United Arab Emirates';
            leadObj.State = 'Dubai';
            leadObj.City = 'Dubai';
            leadObj.Email = 'testemail@test.com';
            leadObj.LeadSource = 'Import';
        }
        insert leadList;
    }

    /**
     * @description - test method for single queueable job
     */
    @isTest
    static void testSingleJob() {
        Set<Id> leadIds = new Set<Id>();
        Lead leadObj = LeadSelector.getAll()[0];
        Test.startTest();
        GenericQueueableChain.chunkJobs(GenericQueueableImpl.class, new Set<Id>{leadObj.Id}, 2);
        GenericQueueableChainService.addJob(GenericQueueableImpl.class, leadIds);
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
        Set<Id> leadIds = new Set<Id>();
        List<Lead> leadList = LeadSelector.getAll();
        for(Lead leadObj : leadList) {
            leadIds.add(leadObj.Id);
        }
        Test.startTest();
        GenericQueueableChain.chunkJobs(GenericQueueableImpl.class, leadIds, 2);
        GenericQueueableChainService.addJob(GenericQueueableImpl.class, leadIds);
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
        Set<Id> leadIds = new Set<Id>();
        List<Lead> leadList = LeadSelector.getAll();
        for(Lead leadObj : leadList) {
            leadIds.add(leadObj.Id);
        }
        Test.startTest();
        GenericQueueableChainService.addJob(GenericQueueableImpl.class, leadIds);
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
        Set<Id> leadIds = new Set<Id>();
        List<Lead> leadList = LeadSelector.getAll();
        for(Lead leadObj : leadList) {
            leadIds.add(leadObj.Id);
        }
        Test.startTest();
        GenericQueueableChainService.addJob(GenericQueueableImpl.class, leadIds);
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
        Set<Id> leadIds = new Set<Id>();
        List<Lead> leadList = LeadSelector.getAll();
        for(Lead leadObj : leadList) {
            leadIds.add(leadObj.Id);
        }
        Test.startTest();
        GenericQueueableChainService.addJob(GenericQueueableImpl.class, leadIds);
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
        Set<Id> leadIds = new Set<Id>();
        List<Lead> leadList = LeadSelector.getAll();
        for(Lead leadObj : leadList) {
            leadIds.add(leadObj.Id);
        }
        Test.startTest();
        GenericQueueableChainService.addJob(GenericQueueableImpl.class, leadIds);
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
        Set<Id> leadIds = new Set<Id>();
        Lead leadObj = LeadSelector.getAll()[0];
        Test.startTest();
        GenericQueueableChain.chunkJobs(Integer.class, new Set<Id>{leadObj.Id}, 2);
        GenericQueueableChainService.addJob(Integer.class, leadIds);
        Test.stopTest();
        List<AsyncApexJob> asyncJobList = [SELECT Id, JobType, Status, ApexClassId, ApexClass.Name FROM AsyncApexJob WHERE ApexClass.Name = 'GenericChainedQueueable'];
        System.assertNotEquals(asyncJobList, null, 'Async job should be queued'); 
    }
}