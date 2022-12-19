public inherited sharing class HDT_QR_DocumentalConfiguration {

    public static List<Document> getDocument(){
        Id folderId = [SELECT Id FROM Folder WHERE DeveloperName  =: 'DocumentalPayloadAdministration' LIMIT 1].Id;
        List<Document> docList = new List<Document>();
        docList = [
            SELECT Id, Name, CreatedDate, LastModifiedDate
            FROM Document
            WHERE FolderId = :folderId
            //AND Name != 'Driver3'
            WITH SECURITY_ENFORCED
            ORDER BY Name
        ];
        return docList;
    }
    public static List<SObject> getRecordFromServiceItems(String context,Set<String> numberSet){
        if(numberSet.size()<= 0){
            return new List<SObject>();
        }
        if(context.equalsIgnoreCase('Case')){
            return [SELECT Id, CaseNumber FROM Case WHERE CaseNumber IN:numberSet WITH SECURITY_ENFORCED];
        }else {
            return [SELECT Id, OrderNumber FROM Order WHERE OrderNumber IN:numberSet WITH SECURITY_ENFORCED];
        }
    }
    
    public static List<Document> getDocumentByContext(String context){
        List<Document> docList = [
            SELECT Id, Name, Body
            FROM Document
            WHERE Name =:context
            WITH SECURITY_ENFORCED
        ];
        return docList;
    }

    public static List<DocumentalPayloadAdministration__c> getDocumentalPayloadAdministration(List<DocumentalPayloadAdministration__c> docPayloadAdminList){
        docPayloadAdminList = new List<DocumentalPayloadAdministration__c>();
        docPayloadAdminList = [
            SELECT Class__c, Context1__c, Context2__c, Context3__c, Context4__c, DefaultValue__c, Expression__c,
                   Field1__c, Field2__c, Field3__c, Field4__c, IsData__c, Iterative__c, ManageAmount__c, Method__c,
                   Object1__c, Object2__c, Object3__c, Object4__c, OrderPayloadField__c, OrderSection__c, PayloadField__c,
                   Separetor__c, Type__c
            FROM DocumentalPayloadAdministration__c
            WHERE Type__C != 'TDRV'
            WITH SECURITY_ENFORCED
            ORDER BY OrderSection__c, OrderPayloadField__c
        ];
        return docPayloadAdminList;
    }

    public static List<HDT_SignModeSettings__mdt> getSignModeSettings(String processType,String source){
        return [SELECT Id, ProcessType__c,Source__c,SignMode__c,SendMode1__c,SendMode2__c,SendMode3__c FROM HDT_SignModeSettings__mdt WHERE (Source__c =:source OR Source__c = '') AND (ProcessType__c=:processType OR ProcessType__c = '')  WITH SECURITY_ENFORCED];
    }

    public static DocumentalActivity__c getDocumentalActivityById(String recordId){

        List<DocumentalActivity__c> activities = [
            SELECT Id, AttachmentCode__c, EnvelopeId__c, PostelTimestamp__c,DocumentalSystem__c
            FROM DocumentalActivity__c
            WHERE Id = :recordId
            WITH SECURITY_ENFORCED
        ];

        if (!activities.isEmpty()) {
            return activities[0];
        }

        return null;
    }

    public static DocumentSendTracking__c getDocumentSendTrackingById(String recordId){

        List<DocumentSendTracking__c> sends = [
            SELECT Id, EnvelopeId__c
            FROM DocumentSendTracking__c
            WHERE Id = :recordId
            WITH SECURITY_ENFORCED
        ];

        if (!sends.isEmpty()) {
            return sends[0];
        }

        return null;
    }

    // Restituisce un oggetto DocumentalActivity__c o DocumentSendTracking__c a seconda dell'Id passato in input.
    public static SObject getDocumentalObjectById(Id recordId){
        if (String.isBlank(recordId)) {
            return null;
        }

        if (recordId.getSobjectType() == DocumentalActivity__c.getSObjectType()) {
            List<DocumentalActivity__c> activities = [
                SELECT Id, EnvelopeId__c, CaseId__r.SignMode__c, OrderId__r.SignatureMethod__c
                FROM DocumentalActivity__c
                WHERE Id = :recordId
                WITH SECURITY_ENFORCED
            ];

            if (!activities.isEmpty()) {
                return activities[0];
            }
        } else if (recordId.getSobjectType() == DocumentSendTracking__c.getSObjectType()) {
            List<DocumentSendTracking__c> sends = [
                SELECT Id, EnvelopeId__c, Case__r.SignMode__c, Order__r.SignatureMethod__c
                FROM DocumentSendTracking__c
                WHERE Id = :recordId
                WITH SECURITY_ENFORCED
            ];

            if (!sends.isEmpty()) {
                return sends[0];
            }
        }

        return null;
    }

    public static SObject getDocumentSendTracking(String transactionId){
        List<DocumentSendTracking__c> toReturn = [SELECT Id,Case__c,Order__c FROM DocumentSendTracking__c WHERE EnvelopeId__c=:transactionId WITH SECURITY_ENFORCED];
        if(!toReturn.isEmpty()){
            return toReturn[0];
        }else {
            return null;
        }
    }

    public static Order getParentOrder(String orderId){
        List<Order> orders = [SELECT Id,ParentOrder__c FROM Order WHERE Id =:orderId WITH SECURITY_ENFORCED];
        if(!orders.isEmpty()){
            return orders[0];
        }else {
            return null;
        }
    }

    public static Order getOrderPriceBook(String orderId){
        List<Order> orders = [SELECT Id,SBQQ__Quote__r.SBQQ__PriceBook__r.Name,Pricebook2.Name FROM Order WHERE Id =:orderId WITH SECURITY_ENFORCED];
        if(!orders.isEmpty()){
            return orders[0];
        }else {
            return null;
        }
    }

}