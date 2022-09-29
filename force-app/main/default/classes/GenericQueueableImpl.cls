/**
* @author Akshay Naik
* @date 23/09/22
* @description Async Service for opportunity enrichment
*/
public without sharing class GenericQueueableImpl implements IGenericQueueable {

    /**
     * @description - logic to be executed in async context
     * @param oppIds - opp Ids to be processed
     */
    public void execute(Set<Id> oppIds) {
        System.debug('oppIds ++ ' + oppIds);
    }
}