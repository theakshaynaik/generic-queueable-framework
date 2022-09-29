/**
* @author Akshay Naik
* @date 27/09/22
* @description Service to enrich opportunities
*/
public without sharing class OpportunityEnrichmentService {

    /**
     * @description Method to enrich opportunities
     * @param oppIdList 
     */
    @AuraEnabled
    public static void enrichOpportunities(List<Id> oppIdList){
        try{
            Set<Id> oppIdSet = new Set<Id>(oppIdList);            
            GenericQueueableChain.chunkJobs(GenericQueueableImpl.class, oppIdSet, 50);
        } catch(Exception ex){
            throw new OpportunityEnrichmentServiceException(ex.getMessage());
        }
    }

    /*******************************************************************************************************
    * @description Class to handle exceptions
    */
    public class OpportunityEnrichmentServiceException extends Exception {}
}