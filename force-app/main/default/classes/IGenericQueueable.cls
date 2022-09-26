/**
 * @description       : Interface for Generic Queueable
 * @author            : Akshay Naik
 * @date              : 23.09.2022
 **/
public interface IGenericQueueable {

    /**
     * @description - declaration for the logic to be executed in async context
     * @param ids - ids to be processed
     */
    void execute(Set<Id> ids);
}