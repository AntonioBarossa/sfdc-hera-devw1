public inherited sharing class HDT_QR_DocumentalConfiguration {

    public static List<Document> getDocument(){
        Id folderId = [SELECT Id FROM Folder WHERE DeveloperName  =: 'DocumentalPayloadAdministration' LIMIT 1].Id;
        List<Document> docList = new List<Document>();
        docList = [
            SELECT Id, Name, CreatedDate, LastModifiedDate
            FROM Document
            WHERE FolderId = :folderId
            WITH SECURITY_ENFORCED
            ORDER BY Name
        ];
        return docList;
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
        return [SELECT Id, ProcessType__c,Source__c,SignMode__c,SendMode1__c,SendMode2__c,SendMode3__c FROM HDT_SignModeSettings__mdt WHERE Source__c =:source AND ProcessType__c=:processType  WITH SECURITY_ENFORCED];
    }

}