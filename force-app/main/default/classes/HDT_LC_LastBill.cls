public with sharing class HDT_LC_LastBill {
    public HDT_LC_LastBill() {

    }

    @AuraEnabled
    public static string getData(String accountCode, String mode, String kpiId){
        Map<String,String> result = new Map<String,String>();
        List<KpiTracking__c> kpiList = new List<KpiTracking__c>();
        String amount;
        String billNumber;
        Datetime expiredDate;
        String billStatus;
        String commodity;
        Date lastUpdate;
        Date now = Date.today();
        if(String.isNotBlank(kpiId)){
            kpiList = HDT_UTL_KpiTracking.getKpiRecord(kpiId);
            if (kpiList != null && kpiList.size()>0) {
                lastUpdate = kpiList[0].LastBillLastUpdate__c;
                amount = String.valueOf(kpiList[0].LastBillAmount__c);
                billNumber = kpiList[0].LastBillNumber__c;
                expiredDate = (Datetime) kpiList[0].LastBillExpirationDate__c;
                commodity = kpiList[0].LastBillCommodity__c;
                billStatus = kpiList[0].LastBillPaymentStatus__c;

                System.debug('>>>> lastUpdate ' + lastUpdate);

                if(lastUpdate != null && lastUpdate.isSameDay(now)){
                    result.put('outcome', 'OK'); 
                    result.put('amount', amount); 
                    result.put('billNumber', billNumber);
                    result.put('expiredDate', expiredDate.format('dd/MM/yyyy'));
                    result.put('billStatus', billStatus);
                    result.put('commodity', commodity);
                    result.put('callws', 'false');
                }else {
                    result.put('callws', 'true');
                    //result = getDataFromSap(accountCode);
                    //if(result.get('outcome') == 'OK'){
                    //    updateKpiTracking(result,kpiId);
                    //}
                }
            }else {
                result.put('outcome', 'KO'); 
                result.put('message', 'Non è stato possibile accedere all\'Estratto conto del cliente');  
            }
        }else {
            result.put('outcome', 'KO'); 
            result.put('message', 'Non è stato possibile accedere all\'Estratto conto del cliente'); 
        }
        System.debug(JSON.serialize(result));
        return JSON.serialize(result);
        //verifico se esiste il KPI Tracking
        //se esiste controllo la data
        //se today prendo valori dal kpi
        //se se > today richiamo ws
    }

    @AuraEnabled
    public static string updateKpiTracking(String result, String kpiId){
        String resultUpdate = '';
        try{
            Map<String,String> mapping = (Map<String,String>)JSON.deserialize(result, Map<String,String>.class);
            updateKpiTracking(mapping, kpiId);
            resultUpdate = 'OK';
        } catch (Exception ex){
            resultUpdate = 'ERROR ' + ex.getMessage();
        }

        return resultUpdate;
    }

    private static void updateKpiTracking(Map<String,String> mapping, String kpiId){
        KpiTracking__c recordKpi = new KpiTracking__c();
        recordKpi.Id = kpiId;
        recordKpi.LastBillLastUpdate__c = Date.today();
        recordKpi.LastBillCommodity__c = mapping.get('commodity');
        recordKpi.LastBillPaymentStatus__c = mapping.get('billStatus');
        recordKpi.LastBillExpirationDate__c = formatDate(mapping.get('expiredDate'));
        recordKpi.LastBillNumber__c = mapping.get('billNumber');
        recordKpi.LastBillAmount__c = Double.valueOf(mapping.get('amount'));

        System.debug('>>>>>> ' + String.valueOf(recordKpi));

        HDT_UTL_KpiTracking.updateKpiRecord(recordKpi);
    }
    private static Date formatDate(String inputDate){
        if(inputDate==null || String.isBlank(inputDate)) return null;
        List<String> listString = inputDate.split('/');
        String gg = listString[0];
        String mm = listString[1];
        String yyyy = listString[2];
        return Date.valueOf(yyyy+'-'+mm+'-'+gg);
    }

    // Action method
    @AuraEnabled(continuation=true cacheable=true)
    public static Object startRequest(String accountCode, String mode, String kpiId) {

        Map<String,String> result = new Map<String,String>();
        Map<String,String> commodity = new Map<String,String>();
        String namedCredential = '';
        //HDT_WS_MulesoftCaller.HDT_WRP_HttpObj httpObj = HDT_LC_AccountStatementCtrlUtility.setHttpObject('EC', '');
        //namedCredential = String.valueOf(httpObj.endPoint);

        List<HDT_TabConfiguration__mdt> endPointMdt;
        endPointMdt = HDT_QR_AccountStatement.getTabConfigurationMetaData(endPointMdt, 'EC');
        String body = generateBodyForWebService(accountCode);
        //HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow bodyWrapper = new HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow();
        //Datetime now = Datetime.now();
        //Datetime start = now.addMonths(-24);
        //// REQUEST VISTA RATE HOME
        //bodyWrapper.applicativo = 'ML';
        //bodyWrapper.aggregazione = '03';
        //bodyWrapper.loginId = '0-1';
        //bodyWrapper.dataFine = now.format('dd/MM/yyyy');
        //bodyWrapper.dataInizio = start.format('dd/MM/yyyy');
        //bodyWrapper.tipoTransazione = 'EC2';
        //bodyWrapper.tipoEstrattoConto = 'ORDINARIO';
        //bodyWrapper.codiceCliente = accountCode;
//
        //String body = JSON.serialize(bodyWrapper, true);
        //System.debug('HDT_SRV_AccountInstallmentsCheck: request body = ' + body);

        // Create continuation. Argument is timeout in seconds.
        Continuation con = new Continuation(40);
        // Set callback method
        con.continuationMethod = 'processResponse';
        // Set state
        con.state = kpiId;
        // Create callout request
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endPointMdt[0].EndpointService__c);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        
        req.setbody(body);
        req.setTimeout(120000);

        System.debug('>>> ' + String.valueOf(req));

        // Add callout request to continuation
        con.addHttpRequest(req);
        // Return the continuation
        return con;
    }
    
    // Callback method
    @AuraEnabled(cacheable=true)
    public static String processResponse(List<String> labels, Object state) {
        System.debug('processResponse - labels: ' + labels);
        System.debug('processResponse - state: ' + state);
        HttpResponse response = Continuation.getResponse(labels[0]);
        Integer statusCode = response.getStatusCode();
        Map<String,String> result = new Map<String,String>();
        Map<String,String> commodity = new Map<String,String>();
        
        //CAUSA DI ERRORE - TODO: FIX TEST
        Map<String, Object> responseBodyMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        System.debug('HDT_SRV_AccountInstallmentsCheck: parsed response body = ' + JSON.serialize(responseBodyMap));
        if (responseBodyMap.containsKey('data')) {
            List<Object> dataObj = (List<Object>) responseBodyMap.get('data');
            if(dataObj.size() > 0){
                Map<String, Object> singleObjMap = (Map<String, Object>) dataObj[0];
                List<Object> secondoLivelloList = (List<Object>) singleObjMap.get('secondoLivelloInformativo');
                for(Object single : secondoLivelloList){
                    Map<String, Object> secondLevelObjMap = (Map<String, Object>) single;
                    String singleCommodity = (String) secondLevelObjMap.get('settoreMerceologico');
                    if(String.isNotBlank(singleCommodity)){
                        commodity.put(singleCommodity, 'true');
                    }
                }
                Double residuo = 0.0;
                residuo = Double.valueOf(singleObjMap.get('residuo'));
                result.put('outcome', 'OK'); 
                result.put('amount', (String) singleObjMap.get('importo')); 
                result.put('billNumber', (String) singleObjMap.get('numeroFattura'));
                result.put('expiredDate', (String) singleObjMap.get('dataScadenza'));
                //se residuo è 0 pagato
                if(residuo > 0 || residuo < 0){
                    result.put('billStatus', 'NON PAGATA');    
                }else {
                    result.put('billStatus', 'PAGATA'); 
                }
                result.put('commodity', JSON.serialize(commodity));
            }else {
                result.put('outcome', 'KO'); 
                result.put('message', 'Non sono presenti bollette recenti. Per maggiori dettagli accedi all\'Estratto Conto del Cliente'); 
            }
        }else {
            result.put('outcome', 'KO'); 
            result.put('message', 'Non sono presenti bollette recenti. Per maggiori dettagli accedi all\'Estratto Conto del Cliente');
        }

        return JSON.serialize(result);
    }

    @AuraEnabled
    public static Object getLastBillDataFromSap(String accountCode){

        String jsonObjString = '';
 
        HDT_WS_MulesoftCaller.HDT_WRP_HttpObj httpObj = HDT_LC_AccountStatementCtrlUtility.setHttpObject('EC', '');
        String body = generateBodyForWebService(accountCode);

        HDT_WS_MulesoftCaller.HDT_WRP_Response responseCtrl = HDT_WS_MulesoftCaller.retrieveDataCtrl(body, httpObj);
        Map<String, Object> responseBodyMap = (Map<String, Object>) JSON.deserializeUntyped(responseCtrl.body);
        System.debug('Parsed response body = ' + JSON.serialize(responseBodyMap));

        if (responseBodyMap.containsKey('data')) {
            List<Object> dataObj = (List<Object>) responseBodyMap.get('data');
            if(dataObj.size() > 0){
                Map<String, Object> singleObjMap = (Map<String, Object>) dataObj[0];
                String billNumber = (String)singleObjMap.get('numeroFattura');
                String dataEmissione = (String)singleObjMap.get('dataEmissione');
                List<String> dateArray = dataEmissione.split('/');
                String companyCode = HDT_SRV_ComunicationsSearchList.getCompanyCodeHelper((String) singleObjMap.get('societa'));

                JSONGenerator gen = JSON.createGenerator(true);
                gen.writeStartObject();
                gen.writeStringField('billNumber', billNumber.replaceAll('^0+', ''));
                gen.writeStringField('channel', 'CRM');
                gen.writeStringField('date', dateArray[2] + '-' + dateArray[1] + '-' + dateArray[0]);
                gen.writeStringField('documentType', 'Bollette');
                gen.writeStringField('company', companyCode);
                gen.writeEndObject();
                jsonObjString = gen.getAsString();

            }

        }

        return jsonObjString;

    }

    private static String generateBodyForWebService(String accountCode){

        HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow bodyWrapper = new HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow();
        
        Datetime now = Datetime.now();
        Datetime start = now.addMonths(-24);
        
        bodyWrapper.applicativo = 'ML';
        bodyWrapper.aggregazione = '03';
        bodyWrapper.loginId = '0-1';
        bodyWrapper.dataFine = now.format('dd/MM/yyyy');
        bodyWrapper.dataInizio = start.format('dd/MM/yyyy');
        bodyWrapper.tipoTransazione = 'EC2';
        bodyWrapper.tipoEstrattoConto = 'ORDINARIO';
        bodyWrapper.codiceCliente = accountCode;

        String body = JSON.serialize(bodyWrapper, true);
        System.debug('Request body = ' + body);

        return body;
    }

    /*private static Map<String,String> getDataFromSap(String accountCode){
        Map<String,String> result = new Map<String,String>();
        Map<String,String> commodity = new Map<String,String>();
        HDT_WS_MulesoftCaller.HDT_WRP_HttpObj httpObj = HDT_LC_AccountStatementCtrlUtility.setHttpObject('EC', '');

        HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow bodyWrapper = new HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow();
        Datetime now = Datetime.now();
        Datetime start = now.addMonths(-24);
        // REQUEST VISTA RATE HOME
        bodyWrapper.applicativo = 'ML';
        bodyWrapper.aggregazione = '03';
        bodyWrapper.loginId = '0-1';
        bodyWrapper.dataFine = now.format('dd/MM/yyyy');
        bodyWrapper.dataInizio = start.format('dd/MM/yyyy');
        bodyWrapper.tipoTransazione = 'EC2';
        bodyWrapper.tipoEstrattoConto = 'ORDINARIO';
        bodyWrapper.codiceCliente = accountCode;

        String body = JSON.serialize(bodyWrapper, true);
        System.debug('HDT_SRV_AccountInstallmentsCheck: request body = ' + body);
        HDT_WS_MulesoftCaller.HDT_WRP_Response responseCtrl = HDT_WS_MulesoftCaller.retrieveDataCtrl(body, httpObj);
        Map<String, Object> responseBodyMap = (Map<String, Object>) JSON.deserializeUntyped(responseCtrl.body);
        System.debug('HDT_SRV_AccountInstallmentsCheck: parsed response body = ' + JSON.serialize(responseBodyMap));
        if (responseBodyMap.containsKey('data')) {
            List<Object> dataObj = (List<Object>) responseBodyMap.get('data');
            if(dataObj.size() > 0){
                Map<String, Object> singleObjMap = (Map<String, Object>) dataObj[0];
                List<Object> secondoLivelloList = (List<Object>) singleObjMap.get('secondoLivelloInformativo');
                for(Object single : secondoLivelloList){
                    Map<String, Object> secondLevelObjMap = (Map<String, Object>) single;
                    String singleCommodity = (String) secondLevelObjMap.get('settoreMerceologico');
                    if(String.isNotBlank(singleCommodity)){
                        commodity.put(singleCommodity, 'true');
                    }
                }
                Double residuo = 0.0;
                residuo = Double.valueOf(singleObjMap.get('residuo'));
                result.put('outcome', 'OK'); 
                result.put('amount', (String) singleObjMap.get('totaleCopertina')); 
                result.put('billNumber', (String) singleObjMap.get('numeroFattura'));
                result.put('expiredDate', (String) singleObjMap.get('dataScadenza'));
                //se residuo è 0 pagato
                if(residuo > 0){
                    result.put('billStatus', 'NON PAGATA');    
                }else {
                    result.put('billStatus', 'PAGATA'); 
                }
                result.put('commodity', JSON.serialize(commodity));
            }else {
                result.put('outcome', 'KO'); 
                result.put('message', 'Non sono presenti bollette recenti. Per maggiori dettagli accedi all\'Estratto Conto del Cliente'); 
            }
        }else {
            result.put('outcome', 'KO'); 
            result.put('message', 'Non sono presenti bollette recenti. Per maggiori dettagli accedi all\'Estratto Conto del Cliente');
        }
        return result;
    }*/

}