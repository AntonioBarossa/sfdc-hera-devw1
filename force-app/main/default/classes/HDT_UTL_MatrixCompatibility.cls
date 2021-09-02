/**
 * @author Sabina Levonja (sabina.levonja@dunegroup.it)
 * @date 12/07/2021
 * @description Class that holds methods for Matrix Compatibility 
 */

public inherited sharing class HDT_UTL_MatrixCompatibility {

        
    @AuraEnabled
    public static Map<String,Object> checkCompatibilitySales(Map<String,Object> servReq, Boolean isPostSales){
        try {
            System.debug(servReq);
            Map<String,Object> resMap = new Map<String,Object>();
            List<ServiceRequest__c> srList = new List<ServiceRequest__c>();
            ServiceRequest__c srRequest = new ServiceRequest__c();
            srRequest.ServicePointCode__c = String.valueOf(servReq.get('servicePointCode')); 
            srRequest.Status__c = 'Bozza';
            srRequest.Order__c = String.valueOf(servReq.get('order'));
            srRequest.CommoditySector__c = String.valueOf(servReq.get('commoditySector'));
            srRequest.Type__c = String.valueOf(servReq.get('type')); 
            if(servReq.get('servicePoint') != null){
                srRequest.ServicePoint__c = String.valueOf(servReq.get('servicePoint'));
            }else{
                srRequest.Account__c = String.valueOf(servReq.get('account'));
                srRequest.BillingProfile__c = String.valueOf(servReq.get('billingProfile'));
            }
            if(servReq.get('isBillableVas')!=null){
                Boolean isBillableVas=Boolean.valueOf(servReq.get('isBillableVas'));
                String searchVas = isBillableVas? 'Vas Billabile' : 'Vas Non Billabile';
                servReq.put('processType', searchVas);
            }


            if(servReq.get('processType') != null){
                if(isPostSales!= null &&isPostSales){
                    srRequest.ProcessType__c= getProcessType(String.valueOf(servReq.get('processType')), 'Case', String.valueOf(servReq.get('commoditySector')));
                }else{
                    srRequest.ProcessType__c= getProcessType(String.valueOf(servReq.get('processType')), 'Order', String.valueOf(servReq.get('commoditySector')));
                }
            }

            ServiceRequest__c sReq = HDT_SRV_ServiceRequest.createRecord(srRequest);
            System.debug(srRequest);
            wrts_prcgvr.ObjectCompatibility_1_0.CheckResult result = checkCompatibility(sReq);
            System.debug(result);
            if(isPostSales== null){
                HDT_SRV_ServiceRequest.deleteRecord(sReq);
            }
            //list of incompatible records
            resMap.put('ServiceRequest', srRequest);
            if(!result.incompatibilities.isEmpty()){
                resMap.put('compatibility', getIncompatibilityMessage((ServiceRequest__c[])result.incompatibilities));
                if(isPostSales!= null &&isPostSales){
                    try {
                        List<ServiceRequest__c> srToDeletes = [SELECT ID FROM ServiceRequest__c WHERE Status__c = 'Annullato' AND ServicePointCode__c =: sReq.ServicePointCode__c];
                        for(ServiceRequest__c srToDelete : srToDeletes){
                            HDT_SRV_ServiceRequest.deleteRecord(srToDelete);
                        }
                    } catch (Exception err) {
                        System.debug(err.getMessage());
                    }
                    sReq.Status__c = 'Annullato';
                    srList.add(sReq);
                    HDT_SRV_ServiceRequest.updateRecord(srList);
                }
            }else{
                resMap.put('compatibility', '');
            }
            
            return resMap;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String checkCompatibilityPostSales(Case cs){
        try {
            String compatibility='';
            ServiceRequest__c srvRequest= new ServiceRequest__c();
            srvRequest.Case__c= cs.Id;
            srvRequest.ServicePointCode__c= cs.PODPDRFormula__c;
            srvRequest.Status__c= getStatus(cs.Status,'Case');
            srvRequest.CommoditySector__c= cs.CommodityFormula__c;
            srvRequest.Type__c= 'Case';
            if(cs.ServicePoint__c != null){
                srvRequest.ServicePoint__c= cs.ServicePoint__c;
            }else{
                srvRequest.Account__c= cs.AccountId;
                srvRequest.BillingProfile__c= cs.BillingProfile__c;
            }
            srvRequest.ProcessType__c= getProcessType(cs.Type, 'Case', cs.CommodityFormula__c);
            ServiceRequest__c sReq = HDT_SRV_ServiceRequest.createRecord(srvRequest);
            wrts_prcgvr.ObjectCompatibility_1_0.CheckResult result = checkCompatibility(sReq);
            //list of incompatible records
            if(!result.incompatibilities.isEmpty()){
                compatibility = getIncompatibilityMessage((ServiceRequest__c[])result.incompatibilities);
                HDT_SRV_ServiceRequest.deleteRecord(sReq);
            }
                
            return compatibility;   
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static wrts_prcgvr.ObjectCompatibility_1_0.CheckResult checkCompatibility(ServiceRequest__c srRequest){
        try {
            wrts_prcgvr.Interfaces_1_0.IObjectCompatibilityInt objectCompatibility =
            (wrts_prcgvr.Interfaces_1_0.IObjectCompatibilityInt) wrts_prcgvr.VersionManager.newClassInstance('ObjectCompatibility');
            //API call

            wrts_prcgvr.ObjectCompatibility_1_0.CheckResult result =
            (wrts_prcgvr.ObjectCompatibility_1_0.CheckResult)
            objectCompatibility.check(new Map<String,Object>{
            'sObject' => srRequest
            });
            return result;
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    public static String getIncompatibilityMessage(ServiceRequest__c[] incomps){
        Set<Id> conflictIds = new Set<Id>();
        Set<String> conflicts = new Set<String>();

        ServiceRequest__c[] incompatibilities= (ServiceRequest__c[])incomps;
        for(ServiceRequest__c c : incompatibilities){
            conflictIds.add(c.Id);
        }
        for(ServiceRequest__c s : [SELECT Id,Case__c, Order__c, Order__r.OrderNumber, Case__r.CaseNumber,Type__c FROM ServiceRequest__c WHERE Id IN :conflictIds]) {
            if(s.Type__c=='Case'){
                if(s.Case__c != null){
                    conflicts.add(s.Case__r.CaseNumber);
                }
            }else{
                if(s.Order__c != null){
                    conflicts.add(s.Order__r.OrderNumber);
                }
            }
        }
        if(conflicts.isEmpty()){
            conflicts.add('Attenzione! Non è possibile avanzare. Esiste un processo Bloccante!');
        }
        System.debug('conflicts: '+ conflicts);

        String[] conflictsString = new List<String>(conflicts);
        return String.join(conflictsString, ', ');
    }

    public static String getStatus(String status, String type){
        String sts='';
        if(type == 'Case'){
            switch on status {
                when 'New' {
                    sts = 'Bozza';
                }when 'In Lavorazione' {
                    sts = 'In Lavorazione';
                }when 'Sequenzializzato' {
                    sts = 'Sequenzializzato';
                }when 'Closed' {
                    sts = 'Chiuso';
                }
            }
        }else{
            switch on status {
                when 'Draft' {
                    sts = 'Bozza';
                }when 'In Lavorazione' {
                    sts = 'In Lavorazione';
                }when 'Activated' {
                    sts = 'Chiuso';
                }when 'Completed' {
                    sts = 'Completato';
                }when 'Annullato' {
                    sts = 'Annullato';
                }when 'Sequenzializzato' {
                    sts = 'Sequenzializzato';
                }
            } 
        }
        
        return sts;
    }

    private static String getProcessType(String pType, String type, String commoditySector){
        String processType='';
        List<HDT_MatrixCompatibilityMap__mdt> mdtList= HDT_QR_MatrixCompatibilityMap.getProcessTypeMap(pType.trim(),type);
        if(mdtList.size()==1){
            processType = mdtList[0].ServiceRequestType__c;
        }else if(mdtList.size()>1){
            for(HDT_MatrixCompatibilityMap__mdt m: mdtList){
                if(m.CommoditySector__c == commoditySector){
                    processType = m.ServiceRequestType__c;
                }
            }
        }
        return processType;
    }
}
