/*
    @Author:  Carmine Scalise (carmine.scalise@webresults.it)
    @CreatedDate:  9/05/2022
*/

public with sharing class HDT_UTL_LandRegistry {

    String mockResp_OK = '{"status":"success","correlationId":"2ddbd94c-96c0-4aa2-a0fe-bb7603ebca7c","timestamp":"2020-08-06T17:49:57.819+02:00","data":{"testata":{"esito":"test","messaggio":"test"},"posizioni":[{"destinazioneUso":"test","descrizioneDestinazioneUso":"test","codiceAssenzaDatiCatastali":"test","descrizioneAssenzaDc":"test","comuneAmministrativo":"test","comuneCatastale":"test","codiceComuneCatastale":"test","codiceProvincia":"test","tipoUnita":"test","descrizioneTipoUnita":"test","sezioneUrbana":"test","foglio":"test","particella":"test","subalterno":"test","qualificaTitolareUtenza":"test","descrizioneQualifica":"test","superficieCatastale":"test","categoriaCatastale":"test"}]}}';
    String mockResp_KO = '{"status":"failed","correlationId":"2ddbd94c-96c0-4aa2-a0fe-bb7603ebca7c","timestamp":"2020-08-06T17:49:57.819+02:00","errorDetails":[{"code":"BAD_REQUEST","message":"There was an issue with your request message","additionalInfo":"Bad Request : There was an issue with your request message"}]}';

    @AuraEnabled
    public static list<LandRegistry__c> retrieveLandRegistryTable(Id caseId, Id orderId, Id servicePointId) {
        system.debug('pratica caseId: ' + caseId);
        system.debug('pratica orderId: ' + orderId);
        system.debug('pratica servicePointId: ' + servicePointId);

        HDT_QR_LandRegistry qrClass = new HDT_QR_LandRegistry();
        Id rtIdPraticaTARI = Schema.SObjectType.LandRegistry__c.getRecordTypeInfosByName().get('DatiCatastali - Pratica Ambiente').getRecordTypeId();

        list<LandRegistry__c> praticaData = new list<LandRegistry__c>();
        if(caseId != null) praticaData = qrClass.getPraticaTARILandRegistryByCaseIds(new list<Id> {caseId});
        else if(orderId != null) praticaData = qrClass.getPraticaTARILandRegistryByOrderIds(new list<Id> {orderId});
        system.debug('praticaData1: ' + JSON.serialize(praticaData));
        if(!praticaData.isEmpty()) return praticaData;

        list<LandRegistry__c> lndRgTable = new list<LandRegistry__c>();
        list<LandRegistry__c> originData = qrClass.getTARILandRegistryByServicePointIds(new list<Id> {servicePointId});
        for(LandRegistry__c curOriginRecord : originData){
            LandRegistry__c resultLR;
            resultLR = curOriginRecord.clone(false, true, false, false);
            resultLR.RecordTypeId = rtIdPraticaTARI;
            resultLR.ServicePoint__c = null;
            if(caseId != null) resultLR.Case__c = caseId;
            if(orderId != null) resultLR.Order__c = orderId;
            system.debug('pratica record: ' + JSON.serialize(resultLR));
            lndRgTable.add(resultLR);
        }
        insert lndRgTable;

        if(caseId != null) praticaData = qrClass.getPraticaTARILandRegistryByCaseIds(new list<Id> {caseId});
        else if(orderId != null) praticaData = qrClass.getPraticaTARILandRegistryByOrderIds(new list<Id> {orderId});
        system.debug('praticaData2: ' + JSON.serialize(praticaData));
        return praticaData;
    }
    
    @AuraEnabled
    public static list<CadastralCategories__c> getCadastralCategories() {     
	    list<CadastralCategories__c> cdCategories = [ SELECT Id, Category__c, Description__c FROM CadastralCategories__c WITH SECURITY_ENFORCED];
        return cdCategories;
    }
    
    @AuraEnabled
    public static list<CityTechnicalData__c> getCities() {        
	    list<CityTechnicalData__c> cities = [ SELECT Id, CadastralCity__c, CityCode__c, Province__c FROM CityTechnicalData__c WITH SECURITY_ENFORCED ORDER BY CadastralCity__c ASC];
        return cities;
    }
    
    @AuraEnabled(continuation=true cacheable=true)
    public static Object getVistaDatiCatastali(Id recordId){
        try {            
            Map<String,Object> request = new Map<String,Object>();
            String namedCredential = 'MulesoftBasePath';
            String path = '/data-enrichment/cadastral-data';

            String sobjectType = recordId.getSObjectType().getDescribe().getName();
            if('ServicePoint__c'.equalsIgnoreCase(sobjectType)){
                List<ServicePoint__c> sp = new HDT_QR_ServicePoint().getRecordById((String)recordId, 'SAPImplantCode__c');
                request.put('impianto', sp[0].SAPImplantCode__c);
            }
            if('Contract'.equalsIgnoreCase(sobjectType)){
                List<Contract> cn = new HDT_QR_Contract().getRecordById((String)recordId);
                request.put('contratto', cn[0].ContractNumber);
            }            

            HTTPRequest req = new HTTPRequest();
            req.setHeader('Content-type', 'application/json');
            req.setBody(JSON.serialize(request));
            req.setEndpoint('Callout:'+namedCredential+path);
            req.setMethod('GET');

            System.debug('request: ' + req);

            Continuation cnt = new Continuation(120);
            cnt.continuationMethod='getVistaDatiCatastaliResponse';
            cnt.addHttpRequest(req);

            return cnt;

        } catch (Exception e) {
            System.debug('Exception! Message: ' + e.getMessage());
            System.debug('Exception! StackTrace: ' + e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static Object getVistaDatiCatastaliResponse(List<String> labels, Object state) {
        VistaDatiCatastaliWrapper result = new VistaDatiCatastaliWrapper();
        
        HttpResponse response = Continuation.getResponse(labels[0]);
        System.debug('response: ' + response);
        result.status = response.getStatus();

        if('success'.equalsIgnoreCase(response.getStatus()) ){
            HDT_WS_VistaDatiCatastaliResponse parsedResp = (HDT_WS_VistaDatiCatastaliResponse)JSON.deserialize(response.getBody(), HDT_WS_VistaDatiCatastaliResponse.class);
            result.response = parsedResp;
        }
        
        return result;
    }

    class VistaDatiCatastaliWrapper{
        @AuraEnabled
        public string status;
        @AuraEnabled
        public HDT_WS_VistaDatiCatastaliResponse response;
    }
}