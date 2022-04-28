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

            req.sistema = 'eEnergy';
            req.caso = 'Transazionale';
            req.crmEntity = 'Order';
            req.customerType = 'CT0';
            req.activationUser = 'AccountCommercialePRM';
            req.account = 'AccountCommercialePRM';
            req.crmId = String.valueOf(o.Id).substring(0,15);
            req.userId = o.CreatedById;
            req.jobTitle = o.ChannelTransCode__c;
            req.internalCustomerId = o.Account?.CustomerCode__c;
            req.companyName = String.isNotBlank(o.Account?.FirstName__c)? o.Account.FirstName__c+' '+o.Account.LastName__c : o.Account?.LastName__c;
            req.externalCustomerId = String.isNotBlank(o.Account?.FiscalCode__c)? o.Account.FiscalCode__c : o.Account?.VATNumber__c;
            req.secondaryCustomerId = o.Account?.VATNumber__c;
            req.bpClass =  bpClass;
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
            Order o = new Order(Id = item.orderId, CreditCheckDescription__c = item.outcomeDescription);
            if (item.outcoming != null && item.outcoming){
                o.OutgoingCreditCheckResult__c = item.outcome;
            }else{
                o.IncomingCreditCheckResult__c = item.outcome;
            }
            if ('KO'.equalsIgnoreCase(item.outcome)){
                o.Phase__c = 'Credit Check KO';
            }
            ordersToUpdate.add(o);
        }
        
        if(!ordersToUpdate.isEmpty()){
            HDT_UTL_DatabaseService.updateSObject(ordersToUpdate);
        }
    }

    public class HDT_WRP_DataForUpdate{
        public String orderId;
        public String outcome;
        public String outcomeDescription;
        public Boolean outcoming;
    }
    
}
