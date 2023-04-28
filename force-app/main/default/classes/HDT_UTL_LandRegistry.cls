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
        Id rtIdPraticaTARI = Schema.SObjectType.LandRegistry__c.getRecordTypeInfosByDeveloperName().get('HDT_RT_DatiCatastali_PraticaTARI').getRecordTypeId();

        list<LandRegistry__c> praticaData = new list<LandRegistry__c>();
        if(caseId != null) praticaData = qrClass.getPraticaTARILandRegistryByCaseIds(new list<Id> {caseId});
        else if(orderId != null) praticaData = qrClass.getPraticaTARILandRegistryByOrderIds(new list<Id> {orderId});
        system.debug('praticaData1: ' + JSON.serialize(praticaData));
        if(!praticaData.isEmpty()) return praticaData;

        list<LandRegistry__c> lndRgTable = new list<LandRegistry__c>();
        list<LandRegistry__c> originData = qrClass.getTARILandRegistryByServicePointIds(new list<Id> {servicePointId});
        Map<String, Id> cityData = getCities(originData);
        for(LandRegistry__c curOriginRecord : originData){
            LandRegistry__c resultLr;
            resultLR = curOriginRecord.clone(false, true, false, false);
            resultLR.RecordTypeId = rtIdPraticaTARI;
            resultLR.ServicePoint__c = null;
            resultLR.CodeMissingRegistryData__c = 
                new Set<String>{'1', '2'}.contains(resultLR.CodeMissingRegistryData__c) ? 
                resultLR.CodeMissingRegistryData__c : null;
            resultLR.RegistryCityLookup__c = !String.isBlank(curOriginRecord.RegistryCity__c) ? cityData.get(curOriginRecord.RegistryCity__c.toLowerCase()) : null;
            resultLR.LegalCityLookup__c = !String.isBlank(curOriginRecord.LegalCity__c) ? cityData.get(curOriginRecord.LegalCity__c.toLowerCase()) : null;
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

    private static Map<String, Id> getCities(list<LandRegistry__c> originData){
        Set<String> cityNames  = new Set<String>();
        for(LandRegistry__c lr : originData){
            if(STRING.isNotBlank(lr?.LegalCity__c))   cityNames.add(lr.LegalCity__c);
            if(STRING.isNotBlank(lr?.RegistryCity__c))   cityNames.add(lr.LegalCity__c);
        }
        Map<String, Id> returnMap = new Map<String, Id>();

        for(CityTechnicalData__c cityData :  [   SELECT Id, CadastralCity__c, CityCode__c, Province__c 
                                                FROM CityTechnicalData__c 
                                                WHERE Name IN :cityNames
                                                WITH SECURITY_ENFORCED ]
        ){
            returnMap.put(cityData.CadastralCity__c.toLowerCase(), cityData.Id);
        }
        return returnMap;
    }
    
    @AuraEnabled
    public static list<CadastralCategories__c> getCadastralCategories() {     
	    list<CadastralCategories__c> cdCategories = [ SELECT Id, Category__c, Description__c FROM CadastralCategories__c WITH SECURITY_ENFORCED];
        return cdCategories;
    }
    
    @AuraEnabled
    public static list<CityTechnicalData__c> getCities() {        
	    list<CityTechnicalData__c> cities = [   SELECT Id, CadastralCity__c, CityCode__c, Province__c 
                                                FROM CityTechnicalData__c 
                                                WHERE CadastralCity__c != null 
                                                    AND CityCode__c != null
                                                    AND Province__c != null
                                                WITH SECURITY_ENFORCED 
                                                ORDER BY CadastralCity__c ASC];
        return cities;
    }

    @AuraEnabled(cacheable=true)
    public static list<CityTechnicalData__c> getCadastralRecord(Id cadastralRecordId) {        
	    list<CityTechnicalData__c> cities = [   SELECT Id, CadastralCity__c, CityCode__c, Province__c 
                                                FROM CityTechnicalData__c 
                                                WHERE 
                                                    Id=:cadastralRecordId
                                                    AND CadastralCity__c != null 
                                                    AND CityCode__c != null
                                                    AND Province__c != null
                                                WITH SECURITY_ENFORCED 
        ];
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
                request.put('contratto', cn[0].SAPContractCode__c);
            }
			System.debug('sobjectType: ' + sobjectType);    
 			System.debug('request.body: ' + request.get('impianto'));
            
            HTTPRequest req = new HTTPRequest();
            req.setHeader('Content-type', 'application/json');
            req.setBody(JSON.serialize(request));
            req.setEndpoint('Callout:'+namedCredential+path);
            req.setMethod('POST');

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
        System.debug('>>getVistaDatiCatastaliResponse - response: ' + response);
        System.debug('>>getVistaDatiCatastaliResponse - response.body: ' + JSON.serializePretty(response.getBody()));
        HDT_WS_VistaDatiCatastaliResponse parsedResp = new HDT_WS_VistaDatiCatastaliResponse();
        if(response.getBody() != null){
            parsedResp = (HDT_WS_VistaDatiCatastaliResponse)JSON.deserialize(response.getBody(), HDT_WS_VistaDatiCatastaliResponse.class);
            result.status = parsedResp.status;
            if('success'.equalsIgnoreCase(parsedResp.status)){
                if(parsedResp.data.testata != null){
                    result.status = parsedResp.data.testata.esito;
                    result.message = parsedResp.data.testata.messaggio;
                }
                result.rows = parsedResp.data.posizioni;
            }
            if('failed'.equalsIgnoreCase(parsedResp.status)){
                result.status = 'KO';
                result.message = 'Errore tecnico';
            }
        }
        
        return result;
    }

    class VistaDatiCatastaliWrapper{
        @AuraEnabled
        public string status;
        @AuraEnabled
        public string message;
        @AuraEnabled
        public List<HDT_WS_VistaDatiCatastaliResponse.HDT_WRP_PosizioniResponseObject> rows;
    }
}