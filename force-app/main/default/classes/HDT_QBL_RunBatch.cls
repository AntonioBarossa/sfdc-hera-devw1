public with sharing class HDT_QBL_RunBatch implements Queueable, Database.AllowsCallouts {
    private String runId;

    
    public HDT_QBL_RunBatch(String runId){
        this.runId = runId;
    }
    
    public void execute(System.QueueableContext qc){
        if(String.isNotBlank(runId)){
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeStringField('runId', runId);
            gen.writeStringField('status', 'success');
            gen.writeStringField('resultDescription', 'success');
            gen.writeEndObject();
            String pretty = gen.getAsString();
    
            HttpRequest req = new HttpRequest();
            req.setEndpoint('Callout:MulesoftBasePath'+'/jobs/outcomes');
            req.setMethod('POST');
            req.setBody(pretty);
            req.setTimeout(120000);
            req.setHeader('Accept', 'application/json');
            req.setHeader('Content-Type', 'application/json');
            Http http = new Http();
            HTTPResponse res = http.send(req);
        }
    }
}
