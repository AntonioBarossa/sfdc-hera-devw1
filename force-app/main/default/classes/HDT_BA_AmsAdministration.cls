public with sharing class HDT_BA_AmsAdministration implements Database.Batchable<SObject>, Database.Stateful{
    
    private String method;
    private HDT_INF_AmsAdministration engine;
    private HDT_WRP_AmsAdministration.HDT_WRP_OperationResult operationResult;
    private String logId;
    private HDT_SRV_AmsAdministration amsSrv = new HDT_SRV_AmsAdministration();

    public HDT_BA_AmsAdministration(String method, String className) {
        
        engine = (HDT_INF_AmsAdministration)Type.forName(className).newInstance();
        this.method = method;
        operationResult = new HDT_WRP_AmsAdministration.HDT_WRP_OperationResult();
        logId = amsSrv.insertAmsLogRecord(method);
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
        operationResult.logId = logId;
        engine.finishOperations(operationResult);
        return;
    }

}