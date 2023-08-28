public interface HDT_INF_AmsAdministration {
    
    List<SObject> startOperations(String method);

    HDT_WRP_AmsAdministration.HDT_WRP_OperationResult operate(String method, List<SObject> objectsToWork);

    AmsAdministration__c finishOperations(HDT_WRP_AmsAdministration.HDT_WRP_OperationResult operationResult);

}