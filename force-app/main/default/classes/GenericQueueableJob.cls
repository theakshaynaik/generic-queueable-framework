/**
 * @description       : Wrapper class to store the class type and ids for generic queueable job 
 * @author            : Akshay Naik
 * @date              : 23.09.2022
 **/
public with sharing class GenericQueueableJob {

    private Type classType;
    private Set<Id> ids;

    /**
     * @description - constructor to set class type and ids
     * @param classType - class type that should be executed
     * @param ids - ids to be processed
     */
    public GenericQueueableJob(Type classType, Set<Id> ids) {
        this.classType = classType;
        this.ids = ids;
    }

    /**
     * @description - get class type
     * @return Type - class type
     */
    public Type getClassType() {
        return this.classType;
    }
     
    /**
     * @description - get ids
     * @return Set<Id> - ids
     */
    public Set<Id> getIds() {
        return this.ids;
    }
}