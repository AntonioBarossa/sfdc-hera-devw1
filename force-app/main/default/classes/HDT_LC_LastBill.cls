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
                if(lastUpdate != null && lastUpdate.isSameDay(now)){
                    result.put('outcome', 'OK'); 
                    result.put('amount', amount); 
                    result.put('billNumber', billNumber);
                    result.put('expiredDate', expiredDate.format('dd/MM/yyyy'));
                    result.put('billStatus', billStatus);
                    result.put('commodity', commodity);
                }else {
                    result = getDataFromSap(accountCode);
                    if(result.get('outcome') == 'OK'){
                        updateKpiTracking(result,kpiId);
                    }
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
    private static void updateKpiTracking(Map<String,String> mapping, String kpiId){
        KpiTracking__c recordKpi = new KpiTracking__c();
        recordKpi.Id = kpiId;
        recordKpi.LastBillLastUpdate__c = Date.today();
        recordKpi.LastBillCommodity__c = mapping.get('commodity');
        recordKpi.LastBillPaymentStatus__c = mapping.get('billStatus');
        recordKpi.LastBillExpirationDate__c = formatDate(mapping.get('expiredDate'));
        recordKpi.LastBillNumber__c = mapping.get('billNumber');
        recordKpi.LastBillAmount__c = Double.valueOf(mapping.get('amount'));
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
    private static Map<String,String> getDataFromSap(String accountCode){
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
                result.put('amount', (String) singleObjMap.get('importo')); 
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
    }
}
