public with sharing class HDT_QBL_DiscardDocusignEnvManagement implements Queueable,  Database.AllowsCallouts{
    private String recordId;
    private Set<Id> oIds;
    private DocumentSendTracking__c dst;
        
    public HDT_QBL_DiscardDocusignEnvManagement(String recordId,String caseId,String orderId) {
        this.recordId = recordId;
        SObject objToUpdate;
        if (String.isNotEmpty(caseId)){
            objToUpdate = new Case(Id = (Id)caseId);
        }else if (String.isNotEmpty(orderId)){
            objToUpdate = new Order(Id = (Id)orderId);
        }
        this.updateRecord(objToUpdate);
    }

    public HDT_QBL_DiscardDocusignEnvManagement(Set<Id> oids) {
        this.oIds = oids;
    }

    public HDT_QBL_DiscardDocusignEnvManagement(DocumentSendTracking__c dst) {
        this.dst = dst;
    }

    public void execute(System.QueueableContext qc) {
        if (String.isNotEmpty(this.recordId)){
            String responseJson = HDT_SRV_DocumentalManagementFacade.discardDocusignEnvelope(this.recordId);
            Map<String,String> response = (Map<String,String>)JSON.deserialize(responseJson, Map<String,String>.class);
            if (response.containsKey('outcome') && 'OK'.equalsIgnoreCase(response.get('outcome'))){
                HDT_UTL_DatabaseService.deleteSObject(this.recordId);
            }
            return;
        }
        List<DocumentSendTracking__c> dstList = new List<DocumentSendTracking__c>();
        if(this.oIds != null && !this.oIds.isEmpty()){
            dstList = HDT_QR_DocumentalConfiguration.getEnvelopesToCancel(this.oids,'Intesa','E-Mail');    
        }else if (this.dst!= null){
            dstList.add(dst);
        }
        for (DocumentSendTracking__c dst : dstList){
            HDT_SRV_DocumentalManagementFacade.discardDocusignEnvelope(dst.Id);
        }
    }

    private void updateRecord(SObject objToUpdate){
        if (objToUpdate != null){
            objToUpdate.put('DocusignURL__c','');
            HDT_UTL_DatabaseService.updateSObject(objToUpdate);
        }
    }

}
