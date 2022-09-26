/**
* @author Akshay Naik
* @date 23/09/22
* @description Async Service for Bulk Lead Conversion
*/
public without sharing class LeadConversionBulkAsyncService implements IGenericQueueable {

    /**
     * @description - logic to be executed in async context
     * @param leadIds - lead Ids to be processed
     */
    public void execute(Set<Id> leadIds) {
        System.debug('leadIds ++ ' + leadIds);
        /*
        Map<Id, Lead> leadMap = LeadSelector.getLeadsById(leadIds, fieldsToQuery);
        LeadConversionService conversionServiceObj = new LeadConversionService();
        conversionServiceObj.convertLeads(leadMap);
        */
    }
}