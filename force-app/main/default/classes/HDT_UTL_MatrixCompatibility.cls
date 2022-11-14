/**
 * @author Sabina Levonja (sabina.levonja@dunegroup.it)
 * @date 12/07/2021
 * @description Class that holds methods for Matrix Compatibility 
 */

public inherited sharing class HDT_UTL_MatrixCompatibility {

    /**
    * @author Sabina Levonja (sabina.levonja@dunegroup.it)
    * @date 12/07/2021
    * @description check compatibility for sales and postsales processes
    * @param Map<String,Object> servReq - the map object containing data for the ServiceRequest__c 
    * @param Boolean isPostSales - the boolean used for the postsale process
    */   
    @AuraEnabled
    public static Map<String,Object> checkCompatibilitySales(Map<String,Object> servReq, Boolean isPostSales){
        try {
            Map<String,Object> resMap = new Map<String,Object>();
            List<ServiceRequest__c> srList = new List<ServiceRequest__c>();
            
            ServiceRequest__c srRequest = new ServiceRequest__c();
            srRequest.ServicePointCode__c = String.valueOf(servReq.get('servicePointCode'));
            srRequest.Status__c = 'Bozza';
            srRequest.Order__c = String.valueOf(servReq.get('order'));
            srRequest.CommoditySector__c = String.valueOf(servReq.get('commoditySector'));
            srRequest.Type__c = String.valueOf(servReq.get('type'));
            if(srRequest.Type__c.equalsIgnoreCase('Case') && String.isNotBlank(srRequest.ServicePointCode__c))
            {
                // FAP: Questa query potrebbe essere non più necessaria se il parametro servReq.get('servicePoint') viene sempre valorizzato da selezione fornitura
                List<ServicePoint__c> sp = [SELECT Id FROM ServicePoint__c WHERE ServicePointCode__c = :srRequest.ServicePointCode__c WITH SECURITY_ENFORCED];
                if(!sp.isEmpty())
                {
                    servReq.put('servicePoint', sp[0].Id);
                }
            }
            if(servReq.get('servicePoint') != null){
                srRequest.ServicePoint__c = String.valueOf(servReq.get('servicePoint'));
            }else{
                srRequest.Account__c = String.valueOf(servReq.get('account'));
                srRequest.BillingProfile__c = String.valueOf(servReq.get('billingProfile'));
            }
            if( servReq.get('processType') != null && servReq.get('isBillableVas')!=null && !(String.valueOf(servReq.get('processType')).containsIgnoreCase('Aggiunta Sconti o Bonus VAS'))){
                Boolean isBillableVas=Boolean.valueOf(servReq.get('isBillableVas'));
                String searchVas = isBillableVas? 'Vas Billabile' : 'Vas Non Billabile';
                servReq.put('processType', searchVas);
            }
            if( servReq.get('processType') != null && String.valueOf(servReq.get('processType')).containsIgnoreCase('Aggiunta Sconti o Bonus VAS') || 
                (String.isNotBlank(srRequest.ServicePointCode__c) && srRequest.ServicePointCode__c.equalsIgnoreCase('PODPROVVISORIO')))
            {
                srRequest.Account__c = String.valueOf(servReq.get('account'));
            }


            if(servReq.get('processType') != null){
                if(isPostSales!= null &&isPostSales){
                    srRequest.ProcessType__c= getProcessType(String.valueOf(servReq.get('processType')), 'Case', String.valueOf(servReq.get('commoditySector')));
                }else{
                    srRequest.ProcessType__c= getProcessType(String.valueOf(servReq.get('processType')), 'Order', String.valueOf(servReq.get('commoditySector')));
                }
            }
            if(isPostSales== true && srRequest.ProcessType__c != null){
                List<ServiceRequest__c> srvCheck = HDT_QR_ServiceRequest.getServiceRequestsSameServicePoint(srRequest.ServicePointCode__c,srRequest.ProcessType__c);
                if(srvCheck != null && !srvCheck.isEmpty()){
                    HDT_SRV_ServiceRequest.deleteRecord(srvCheck[0]);
                }
            }

            ServiceRequest__c sReq = HDT_SRV_ServiceRequest.createRecord(srRequest);
            System.debug(srRequest);
            wrts_prcgvr.ObjectCompatibility_1_0.CheckResult result = checkCompatibility(sReq);
            System.debug(result);
            Boolean skipDelete = (String)servReq.get('isMassive') != null? true:false;
            if(isPostSales== null && !((String)servReq.get('processType')).equalsIgnoreCase('Switch in Fittizio') && !skipDelete){
                HDT_SRV_ServiceRequest.deleteRecord(sReq);
            }
            //list of incompatible records
            resMap.put('ServiceRequest', srRequest);
            if(!result.incompatibilities.isEmpty()){
                resMap.put('compatibility', getIncompatibilityMessage((ServiceRequest__c[])result.incompatibilities));
                if(isPostSales!= null && isPostSales){
                    try {
                        List<ServiceRequest__c> srToDeletes = new List<ServiceRequest__c>();
                        if(String.isNotBlank(sReq.ServicePointCode__c)){
                            srToDeletes = HDT_QR_ServiceRequest.getCanceledServiceRequests(sReq.ServicePointCode__c);
                        }else if(String.isNotBlank(sReq.ServicePoint__c)) {
                            srToDeletes = HDT_QR_ServiceRequest.getCanceledServiceRequestsBySpId(sReq.ServicePoint__c);
                        }               
                        HDT_SRV_ServiceRequest.deleteRecord(srToDeletes);
                    } catch (Exception err) {
                        System.debug(err.getMessage());
                    }
                    sReq.Status__c = 'Annullato';
                    srList.add(sReq);
                    HDT_SRV_ServiceRequest.updateRecord(srList);
                }else if(isPostSales!= null && !isPostSales && skipDelete){
                    HDT_SRV_ServiceRequest.deleteRecord(sReq);
                }
            }else{
                resMap.put('compatibility', '');
            }
            
            return resMap;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @author Sabina Levonja (sabina.levonja@dunegroup.it)
    * @date 12/07/2021
    * @description check compatibility for postsales processes
    * @param Case cs - the Case is used to get the data for the ServiceRequest__c 
    */
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
            system.debug('mio test *****'+srvRequest.ProcessType__c);
            ServiceRequest__c sReq = HDT_SRV_ServiceRequest.createRecord(srvRequest);
            wrts_prcgvr.ObjectCompatibility_1_0.CheckResult result = checkCompatibility(sReq);
            //list of incompatible records
            if(!result.incompatibilities.isEmpty()){
                compatibility = getIncompatibilityMessage((ServiceRequest__c[])result.incompatibilities);
                HDT_SRV_ServiceRequest.deleteRecord(sReq);
            }
                
            return compatibility;   
        }catch (Exception e) {
            throw e;
        }
    }

    /**
    * @author Sabina Levonja (sabina.levonja@dunegroup.it)
    * @date 12/07/2021
    * @description check compatibility for ServiceRequest__c
    * @param ServiceRequest__c srRequest  
    */
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
    
    /**
    * @author Sabina Levonja (sabina.levonja@dunegroup.it)
    * @date 12/07/2021
    * @description get Incompatibilities
    * @param ServiceRequest__c[] incomps - the blocking ServiceRequests  
    */
    public static String getIncompatibilityMessage(ServiceRequest__c[] incomps){
        Set<Id> conflictIds = new Set<Id>();
        Set<String> conflicts = new Set<String>();

        ServiceRequest__c[] incompatibilities= (ServiceRequest__c[])incomps;
        for(ServiceRequest__c c : incompatibilities){
            conflictIds.add(c.Id);
        }
        List<ServiceRequest__c> srvRequests= HDT_QR_ServiceRequest.getServiceRequestByOrderCaseIds(conflictIds,'Id');
        for(ServiceRequest__c s : srvRequests) {
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

    /**
    * @author Sabina Levonja (sabina.levonja@dunegroup.it)
    * @date 12/07/2021
    * @description map the status
    * @param String status 
    * @param String type - type is Case or Order 
    */
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

    
    /**
    * @author Sabina Levonja (sabina.levonja@dunegroup.it)
    * @date 12/07/2021
    * @description map the processType using the metadata
    * @param String pType - pType is the processType of the Case or Order
    * @param String type - type is Case or Order 
    * @param String commoditySector  
    */
    public static String getProcessType(String pType, String type, String commoditySector){
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