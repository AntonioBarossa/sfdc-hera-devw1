public without sharing class HDT_LC_CanaleIVRNoShare {
    public List<Order>  getOrderByUsernamePassword(String username, String password) {
        List<Order> listOrder = [
            SELECT Username__c, Password__c,UniqueAutentication__c,MethodSignedAccepted__c,(Select Username__c, RecordType.DeveloperName, VasSubtype__c, isTransition__c, Phase__c FROM Orders__r) FROM Order WHERE Username__c = :username AND Password__c = :password WITH SECURITY_ENFORCED
        ];

        return listOrder;
    }
	public DocumentalActivity__c  getActivityByOrder(String orderId) {
        List<DocumentalActivity__c> dl = [SELECT Id, OrderId__c FROM DocumentalActivity__c where orderId__c = :orderId WITH SECURITY_ENFORCED];

        return  !dl.isEmpty() ? dl[0] : null ;
    }

    public DocumentSendTracking__c getDocumentalSendTracking(String orderId)
    {
        List<DocumentSendTracking__c> dst = [SELECT Id, Order__c FROM DocumentSendTracking__c WHERE Order__c = :orderId WITH SECURITY_ENFORCED];
        return dst[0];
    }

    public map<String,String> getPlico(String recordId){
        String s = showOriginalDocument(recordId);
        Map<String,String> mapReturn = (Map<String,String>)JSON.deserialize(s, Map<String,String>.class);
        return mapReturn;
    }
    
    public static String showOriginalDocument(String recordId){
        String context;
        String baseSixtyFour = '';
        String body='';
        String result='';
        String responseCode;
        String responseStatus;
        Map<String,String> resultMap = new Map<String,String>();
        HDT_WRP_DocumentalResponse.HDT_WRP_PostelResponse postelResponse = new HDT_WRP_DocumentalResponse.HDT_WRP_PostelResponse();
        try{
            SObject documentalObject = getDocumentalObjectById(recordId);
            System.debug('showOriginalDocument - documentalObject: ' + documentalObject);
            String documentType = HDT_SRV_DocumentalManagement.getDocumentType(documentalObject);
            body = HDT_SRV_DocumentalManagement.generateGetEnvelopeRequest(documentalObject, documentType);
            postelResponse = HDT_SRV_DocumentalManagement.executeGetEnvelopeCalloutRequest(body, documentType);
            baseSixtyFour = postelResponse.content;
            resultMap.put('outcome','OK');
            resultMap.put('base64',baseSixtyFour);
            resultMap.put('type',  documentType);
        }catch(Exception ex){
            resultMap.put('outcome','KO');
            resultMap.put('errorMessage', ex.getMessage());
        }
        return JSON.serialize(resultMap);
    }
    
    public static SObject getDocumentalObjectById(Id recordId){
        
        System.debug('getDocumentalObjectById - recordId: ' + recordId);
        
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
}
