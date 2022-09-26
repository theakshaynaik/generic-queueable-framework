/**
* @author Akshay Naik
* @date 27/09/22
* @description Controller class for Quick Convert Button & Bulk Lead Convert Button - New Implementation without Lead Conversion Page
*/
public without sharing class LeadConversionController {

    private static final string NEWLEADCONVERSION_PROCESS = 'NewLeadConversion';
    private static final string GLOBALCONFIG_RECORDTYPE = 'Global_Config';
    private static final string QUEUEABLECHUNKSIZE_RULE = 'QueueableChunkSize';

    /**
     * @description Method to convert a list of leads
     * @param filteredLeadIdList 
     */
    @AuraEnabled
    public static void convertBulkLeads(List<Id> filteredLeadIdList){
        Log.addMetaInformation(LogConstants.MetaType.BUSINESS_PROCESS, LogConstants.METAINFORMATION_BUSINESS_PROCESS_SALES);
        Log.addMetaInformation(LogConstants.MetaType.OPERATION, SalesSelfServiceConstants.OPERATIONNAME_BULKLEADCONVERSION);
        Log.push('LeadConversionController', 'convertBulkLeads');
        try{
            String fieldsToQuery = getFieldsToQuery();
            Set<Id> filteredLeadIdSet = new Set<Id>(filteredLeadIdList);
            String chunkSizeStr = SalesBusinessConfigProvider.getBusinessRulesByRecordType(NEWLEADCONVERSION_PROCESS, GLOBALCONFIG_RECORDTYPE)?.get(QUEUEABLECHUNKSIZE_RULE)?.Business_Rule_Value__c;
            if(String.isBlank(chunkSizeStr)) {
                return;
            }
            Integer chunkSize = Integer.valueOf(chunkSizeStr);
            GenericQueueableChain.chunkJobs(LeadConversionBulkAsyncService.class, filteredLeadIdSet, chunkSize);
            Log.pop();
        } catch(Exception ex){
            Log.message('Error :' + ex.getMessage() + '  ' + ex.getLineNumber() + '  ' + ex.getStackTraceString(), 'Bulk_Lead_Conversion', LoggingLevel.ERROR);
            Log.forcePop('LeadConversionController', 'convertBulkLeads');
            throw new LeadConversionControllerException(ex.getMessage());
        } finally{
            Log.emit();
        }
    }

    /**
     * @description Method to get a string of comma separated field names from fieldset
     * @return String
     */
    @testVisible
    private static String getFieldsToQuery(){
        Log.push('LeadConversionController', 'getFieldsToQuery');
        List<String> fieldsToQueryList = new List<String>();
        for (Schema.FieldSetMember eachField : SObjectType.Lead.FieldSets.FieldsToQueryForNewLeadConversion.getFields()) {
            fieldsToQueryList.add(eachField.getFieldPath());
        }
        String fieldToQueryString = String.join(fieldsToQueryList, ',');
        Log.pop();
        return fieldToQueryString.removeEnd(',');
    }

    /*******************************************************************************************************
    * @description Class to handle exceptions
    */
    public class LeadConversionControllerException extends Exception {}
}