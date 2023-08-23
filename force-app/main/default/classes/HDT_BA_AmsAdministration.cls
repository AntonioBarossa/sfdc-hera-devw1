public with sharing class HDT_BA_AmsAdministration implements Database.Batchable<SObject>{
    
    private String method;
    private HDT_INF_AmsAdministration engine;
    private HDT_WRP_AmsAdministration.HDT_WRP_OperationResult operationResult;
    
    public HDT_BA_AmsAdministration(String method, String className) {
        engine = (HDT_INF_AmsAdministration)Type.forName(className).newInstance();
        this.method = method;
    }

    public Iterable<SObject> start(Database.BatchableContext context)
    {
        return engine.startOperations(method);
    }

    public void execute(Database.BatchableContext context, List<SObject> scope)
    {
        operationResult = engine.operate(method, scope);
    }

    public void finish(Database.BatchableContext context)
    {
        engine.finishOperations(operationResult);
        return;
    }

}