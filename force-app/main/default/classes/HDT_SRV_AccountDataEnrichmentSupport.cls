public without sharing virtual class HDT_SRV_AccountDataEnrichmentSupport {

    public Boolean success = true;
    public String errorMessage;
    public List<HDT_AccountDataEnrichment__mdt> enrichmentbMetadataList;
    public String recordId;
    public String relatedToId;
    public String body;
    public String endPoint;

    public virtual void setMetadata(List<HDT_AccountDataEnrichment__mdt> enrichmentbMetadataList){
        this.enrichmentbMetadataList = enrichmentbMetadataList;
    }

    public virtual void setRecordIds(String recordId, String relatedToId){
        this.recordId = recordId;
        this.relatedToId = relatedToId;
    }

    public virtual void execute(){
        setBodyRequest();        
    }

    public virtual void setBodyRequest(){
        System.debug(LoggingLevel.DEBUG, '>>> setBodyRequest...');
    }

}