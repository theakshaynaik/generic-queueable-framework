/**
 * @description       : Creating chunks of queueable jobs as per the chunk size
 * @author            : Akshay Naik
 * @date              : 23.09.2022
 **/
public with sharing class GenericQueueableChain {

    /**
     * @description - create chunks of queueable jobs according to the chunk size
     * @param classType - class type that should be executed in chunks as per chunk size
     * @param ids - ids to be processed
     * @param chunkSize - no of records to be processed in one queueable job (remaining records will be re-enqueued)
     */
    public static void chunkJobs(Type classType, Set<Id> ids, Integer chunkSize) {
        if(ids.size() <= chunkSize) {
            GenericQueueableChainService.addJob(classType, ids);	
            GenericQueueableChainService.runJobInQueues();
            return;
        }
        Map<Integer,Set<Id>> indexAndRecordIdsMap = constructIndexAndRecordIdsMap(ids, chunkSize);
        for(Integer index : indexAndRecordIdsMap.keySet()) {
            GenericQueueableChainService.addJob(classType, indexAndRecordIdsMap.get(index));	
        }
        GenericQueueableChainService.runJobInQueues();
    }

    /**
     * @description - construct index and recordIds map
     * @param ids - ids to be processed
     * @param chunkSize - no of records to be processed in one queueable job
     */
    private static Map<Integer,Set<Id>> constructIndexAndRecordIdsMap(Set<Id> ids, Integer chunkSize) {
        Integer key = 1;
        Integer iterator = 1;
        Map<Integer,Set<Id>> indexAndRecordIdsMap = new Map<Integer,Set<Id>>();
        for(Id recordId : ids) {
            if(indexAndRecordIdsMap.containsKey(key)) {
                indexAndRecordIdsMap.get(key).add(recordId);
            } else {
                indexAndRecordIdsMap.put(key, new Set<Id>{recordId});
            }
            if(iterator == (chunkSize * key)) {
                key++;
            }
            iterator++;
        }
        return indexAndRecordIdsMap;
    }
}