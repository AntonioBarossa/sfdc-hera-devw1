public with sharing class HDT_UTL_CreditCheck {
    private final static List<String> FIELDS_FOR_QUERY = new List<String>{
        'Id',
        'VasSubtype__c',
        'IsVAS__c',
        'ContractReference__c',
        'ChannelTransCode__c',
        'CreatedById',
        'OrderReferenceNumber',
        'Catalog__c',
        'Market__c',
        'ProcessType__c',
        'SalesCompany__c',
        'RecordType.DeveloperName',
        'AccountId',
        'Account.CustomerMarking__c',
        'Account.CustomerCode__c',
        'Account.FirstName__c',
        'Account.LastName__c',
        'Account.FiscalCode__c',
        'Account.VATNumber__c',
        'Account.Category__c',
        'Account.CustomerType__c',
        'ServicePoint__c',
        'ServicePoint__r.CommoditySector__c',
        'ServicePoint__r.SupplyPostalCode__c',
        'ServicePoint__r.SupplyProvince__c',
        'ServicePoint__r.SupplyCity__c',
        'ServicePoint__r.SupplyStreetName__c',
        'ServicePoint__r.Account__c',
        'ServicePoint__r.AnnualConsumption__c',
        'ServicePoint__r.Account__r.FiscalCode__c',
        'ServicePoint__r.Account__r.VATNumber__c',
        'ServicePoint__r.Account__r.CustomerCode__c',
        'ServicePoint__r.Account__r.RecordType.DeveloperName'

    };

    
    public static HDT_WS_CreditCheckRequest createRequestFromOrderId(String orderId){
        HDT_WS_CreditCheckRequest req;
        if (String.isNotBlank(orderId)){
            Order o = (Order)HDT_QR_GenericQuery.getGenericRecords(String.join(FIELDS_FOR_QUERY, ','), 'Order', 'Id =\''+String.escapeSingleQuotes(orderId)+'\'')[0];
            req = createRequestFromOrder(o);
        }
        return req;
    }

    public static HDT_WS_CreditCheckRequest createRequestFromOrder(Order o){
        HDT_WS_CreditCheckRequest req;
        if (o != null && HDT_UTL_OrderProcess.checkRecordTypeForCreditCheck(o.RecordType.DeveloperName, o)){
            req = new HDT_WS_CreditCheckRequest();
            String bpClass = null;
            
            if (String.isNotBlank(o.Account?.CustomerMarking__c) && Pattern.matches('[D][0-9][ ]+[-][ ]+[a-z A-Z]+', o.Account.CustomerMarking__c)){
                bpClass = o.Account.CustomerMarking__c.replaceFirst('[D][0-9][ ]+[-][ ]+','');
            }else if (o.Account != null && String.isNotBlank(o.Account.CustomerMarking__c)){
                bpClass = o.Account.CustomerMarking__c;
            }
            
                 
            HDT_WS_CreditCheckRequest.HDT_WRP_InputWrapperDetail iwd = new HDT_WS_CreditCheckRequest.HDT_WRP_InputWrapperDetail();
            if('Energia Elettrica'.equalsIgnoreCase(o.ServicePoint__r.CommoditySector__c)){
                iwd.commodity = 'ENERGIAELETTRICA';
            }
            if('Gas'.equalsIgnoreCase(o.ServicePoint__r.CommoditySector__c)){
                iwd.commodity = 'GAS';
            }
            if (o.IsVAS__c){
                iwd.annualConsumption = HDT_LC_ChildOrderProcessPrecheck.getConsumptionAnnualForVas(o.Id); 
            }else if(o.ServicePoint__r?.AnnualConsumption__c != null){
                iwd.annualConsumption = String.valueOf(o.ServicePoint__r.AnnualConsumption__c);
            }       
            
            List<HDT_WS_CreditCheckRequest.HDT_WRP_InputWrapperDetail> l = new List<HDT_WS_CreditCheckRequest.HDT_WRP_InputWrapperDetail>();
            l.add(iwd);
            String separator =  String.isBlank(o.Account?.CustomerCode__c)? ',':' ';
            req.sistema = 'eEnergy';
            req.caso = 'Transazionale';
            req.crmEntity = 'Order';
            req.customerType = 'CT0';
            req.activationUser = 'AccountCommercialePRM';
            req.account = 'AccountCommercialePRM';
            req.crmId = String.valueOf(o.Id).substring(0,15);
            req.userId = o.CreatedById;
            req.jobTitle = o.ChannelTransCode__c;
            req.internalCustomerId = o.Account != null?String.valueOf(o.Account.Id).substring(7,15):'';
            req.companyName = String.isNotBlank(o.Account?.FirstName__c)? o.Account.FirstName__c+separator+o.Account.LastName__c : o.Account?.LastName__c;
            req.externalCustomerId = String.isNotBlank(o.Account?.FiscalCode__c)? o.Account.FiscalCode__c : o.Account?.VATNumber__c;
            req.secondaryCustomerId = o.Account?.VATNumber__c;
            /**
             * FIX TK 914861C
             * Description: Atos ha richiesto di inviare la marcatura per esteso. In precedenza veniva inviata la marcatura AS-IS Siebel.
             * Azioni: Commentata riga 96 e aggiunta riga 97
             * **/
            //req.bpClass =  bpClass;
            req.bpClass = o.Account?.CustomerMarking__c;
            req.bpCategory = o.Account?.Category__c;
            req.bpType = o.Account?.CustomerType__c;
            req.operation =  o.ProcessType__c;
            req.companyGroup = o.SalesCompany__c;
            req.market = o.Market__c;
            req.offerType = o.Catalog__c;
            req.details = l;

            if(!'HDT_RT_VAS'.equalsIgnoreCase(o.RecordType?.DeveloperName)  ){
                req.address = o.ServicePoint__r.SupplyStreetName__c;
                req.municipality = o.ServicePoint__r.SupplyCity__c;
                req.district = o.ServicePoint__r.SupplyProvince__c;
                req.postCode = o.ServicePoint__r.SupplyPostalCode__c;
            }            
            
            
            if(('HDT_RT_Subentro'.equalsIgnoreCase(o.RecordType.DeveloperName)  || 'HDT_RT_Voltura'.equalsIgnoreCase(o.RecordType.DeveloperName)  || checkOutcomingVolturaWithSwitch(o) ) && (o.AccountId != o.ServicePoint__r?.Account__c) ){
                String fiscalData='';
                if('HDT_RT_Residenziale'.equalsIgnoreCase(o.ServicePoint__r?.Account__r?.RecordType?.DeveloperName)){
                    fiscalData = o.ServicePoint__r?.Account__r?.FiscalCode__c;
                }else if(o.ServicePoint__r?.Account__r?.VATNumber__c != null){
                    fiscalData = o.ServicePoint__r?.Account__r?.VATNumber__c;
                }
                
                
                req.bpAlternative = o.ServicePoint__r?.Account__r?.CustomerCode__c;
                req.alternativeCustomerId = fiscalData;
            }
            
        }
        return req;
    }
    

    @TestVisible
    private static Boolean checkOutcomingVolturaWithSwitch(Order ord){
        return ('HDT_RT_VolturaConSwitch'.equalsIgnoreCase(ord.RecordType.DeveloperName) && ord.ServicePoint__r?.Account__c != null);
    }

    public static void updateOrder(List<HDT_WRP_DataForUpdate> ordersData){
        List<Order> ordersToUpdate = new List<Order>();
        
        for (HDT_WRP_DataForUpdate item : ordersData){
            item.outcomeDescription = (String.isNotBlank(item.outcomeDescription) && item.outcomeDescription.length() > 255) ?
            item.outcomeDescription.subString(0,255) : item.outcomeDescription;
            Order o = new Order(Id = item.orderId, CreditCheckDescription__c = item.outcomeDescription, CreditCheckInProgress__c = false);
            if (item.outcoming != null && item.outcoming){
                o.OutgoingCreditCheckResult__c = item.outcome;
                o.IncomingCreditCheckResult__c = null;
            }else{
                o.IncomingCreditCheckResult__c = item.outcome;
                o.OutgoingCreditCheckResult__c = null;
            }
            /* if ('KO'.equalsIgnoreCase(item.outcome)){
                o.Phase__c = 'Credit Check KO';
            } */
            ordersToUpdate.add(o);
        }
        
        if(!ordersToUpdate.isEmpty()){
            HDT_UTL_DatabaseService.updateSObject(ordersToUpdate);
        }
    }

    public static Boolean managedErrorCode(String errorCode){
        List<HDT_CreditCheckExcludedCode__mdt> codiceErroriGestiti = HDT_QR_GenericQuery.getGenericRecords('Label', 'HDT_CreditCheckExcludedCode__mdt', 'ErrorCode__c = \''+errorCode+ '\' AND IsActive__c = true');
        return !codiceErroriGestiti.isEmpty();
    }

    public static Boolean skipTriggerDuringCall(List<Order> newOrderList, Map<Id,Order> oldOrderMap){
        if (newOrderList.size() == 1 && newOrderList[0].CreditCheckInProgress__c && !oldOrderMap.get(newOrderList[0].Id).CreditCheckInProgress__c) {
            return true;
        }
        return false;
    }

    public static Map<SObject,SObject> verifyCreditCheckStatus(List<Order> newOrderList, Map<Id,Order> oldOrderMap){
        Map<SObject,SObject> mapOrderNotSkipCreditCheck = new Map<SObject,SObject>();
        Map<String,Set<String>> warningStatusMap = getWarnigStatusCreditCheck();
        for (Order newOrder : newOrderList){
            Order oldOrder = oldOrderMap.get(newOrder.Id);
            if (oldOrder.EffectiveDate__c != null && newOrder.EffectiveDate__c ==null){
                newOrder.EffectiveDate__c = oldOrder.EffectiveDate__c;
            }
            if (!setCreditCheckOnSinglOrder(newOrder, oldOrder,warningStatusMap.containsKey(newOrder.RecordTypeId)? warningStatusMap.get(newOrder.RecordTypeId) : warningStatusMap.get('FOR_ALL'))){
                mapOrderNotSkipCreditCheck.put(newOrder,oldOrderMap.get(newOrder.Id));
            }
        }
        return mapOrderNotSkipCreditCheck;
    }

    @SuppressWarnings('PMD.AvoidDebugStatements')
    public static void insertCalloutLog(String request, String response){
        try{
            String description = 'request: \n'+request+'\n\n\n\nresponse:\n'+response;
            wrts_prcgvr__Log__c calloutLog = new wrts_prcgvr__Log__c();
            calloutLog.wrts_prcgvr__Code__c = String.valueof(system.now().format('yyyyMMddHHmmssSSS'));
            calloutLog.wrts_prcgvr__Message__c = 'CALLOUT - CreditCheck Evaluations';
            calloutLog.wrts_prcgvr__Level__c = 'ERROR';
            calloutLog.wrts_prcgvr__Description__c = String.isNotBlank(description) && description.length() > 32768 ? description.substring(0,32768) : description;
            HDT_UTL_DatabaseService.insertSObject(calloutLog);
        }catch (Exception e){
            System.debug(LoggingLevel.ERROR, e.getMessage()+ ' line: '+ e.getLineNumber() );
        }
        
    }

    private static Map<String,Set<String>> getWarnigStatusCreditCheck(){
        Map<String,Set<String>> warningStatusMap = new Map<String,Set<String>>();
        for (HDT_WarningStatusList__mdt status : HDT_WarningStatusList__mdt.getAll().values()){
            if (status.IsActive__c && String.isNotBlank(status.SendingPhase__c)){
                String key = getKeyFromStatus(status);
                if (String.isBlank(key)){
                    continue;
                } 
                if (!warningStatusMap.containsKey(key)){
                    warningStatusMap.put(key, new Set<String>());
                }
                warningStatusMap.get(key).add(status.SendingPhase__c.toUpperCase());
            }
        }
        return warningStatusMap;
    }

    private static Boolean setCreditCheckOnSinglOrder(Order newOrder, Order oldOrder,Set<String> warningStatusList){
        Boolean creditCheckManage = false;
        String oldPhase = oldOrder?.Phase__c;
        String rtDeveloperName = Schema.SObjectType.Order.getRecordTypeInfosById().get(newOrder.RecordTypeId).getDeveloperName();
        Boolean changePhase = String.isNotBlank(newOrder.Phase__c) ? !newOrder.Phase__c.equalsIgnoreCase(oldPhase) : String.isNotBlank(oldPhase);
        DateTime nowDateTime = DateTime.now();
        if ( changePhase && warningStatusList.contains(newOrder.Phase__c?.toUpperCase())
            && HDT_UTL_OrderProcess.checkRecordTypeForCreditCheck(rtDeveloperName, newOrder)
            && (newOrder.CreditCheckInProgress__c || 'KO'.equalsIgnoreCase(newOrder.IncomingCreditCheckResult__c) || 'KO'.equalsIgnoreCase(newOrder.OutgoingCreditCheckResult__c))){
                String newPhase = newOrder.CreditCheckInProgress__c? 'Attesa Credit Check' : 'Credit Check KO';
                newOrder.Phase__c = newPhase;
                newOrder.PhaseStory__c = !String.isBlank(oldOrder?.PhaseStory__c) 
                        ? oldPhase+'@@'+newPhase+'@@'+nowDateTime.getTime()+'@@A||'+oldOrder?.PhaseStory__c
                        : oldPhase+'@@'+newPhase+'@@'+nowDateTime.getTime()+'@@A||';
                creditCheckManage = true;

        }
        return creditCheckManage;
    }

    private static String getKeyFromStatus(HDT_WarningStatusList__mdt status){
        try{
            return String.isBlank(status.RecordTypeDev__c) ? 'FOR_ALL' : (String)Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get(status.RecordTypeDev__c).getRecordTypeId();
        }catch (Exception e){
            return '';
        }
    }

    

    public class HDT_WRP_DataForUpdate{
        public String orderId;
        public String outcome;
        public String outcomeDescription;
        public Boolean outcoming;

        public Boolean isEmpty(){
            return String.isEmpty(this.orderId);
        }
    }
    
}