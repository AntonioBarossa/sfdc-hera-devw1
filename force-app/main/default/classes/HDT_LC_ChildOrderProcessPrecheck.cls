/**
 * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
 * @date 06/02/2021
 * @description HDT_LC_ChildOrderProcessPrecheck.cls - Class that holds methods that are called from hdtChildOrderProcessPrecheck.js
 * @history Inserire Nome Cognome – Data Modifica – Descrizione della modifica
 */
public inherited sharing class HDT_LC_ChildOrderProcessPrecheck {

    private static HDT_QR_Order orderQr = new HDT_QR_Order();
    private static HDT_SRV_Order orderSrv = new HDT_SRV_Order();
    private static HDT_UTL_Order orderUtl = new HDT_UTL_Order();
    private static HDT_QR_ServicePoint servicePointQr = new HDT_QR_ServicePoint();
    private static HDT_SRV_ServicePoint servicePointSrv = new HDT_SRV_ServicePoint();

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @date 06/02/2021
     * @description Get List of process options
     * @return List<Map<String,List<SObject>>>
     */
    @AuraEnabled
    public static List<Map<String,String>> getOptions(){
        List<Map<String,String>> options = new List<Map<String,String>>(); 

        List<Schema.RecordTypeInfo> recordTypes = Order.SObjectType.getDescribe().getRecordTypeInfos();
        for (Schema.RecordTypeInfo recordType : recordTypes) {
            if (recordType.getDeveloperName() != 'HDT_RT_Default' && recordType.getDeveloperName() != 'Master' && recordType.getDeveloperName() != 'HDT_RT_Default' && recordType.getDeveloperName() != 'HDT_RT_OrderDossier') {
                Map<String,String> singleOption = new Map<String,String>();
                singleOption.put('Id', recordType.getRecordTypeId());
                singleOption.put('Label', recordType.getName());
                singleOption.put('DeveloperName', recordType.getDeveloperName());
                options.add(singleOption);
            }
        }

        return options;
    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @date 06/02/2021
     * @description Handle actions on "Avanti" click
     * @param orderId
     * @param String selectedProcess - selected process for child order
     * @param String deliberate
     */
    @AuraEnabled
    public static void next(Order order,String orderId, String selectedProcess, String deliberate, Map<String,String> extraParams){

        system.debug('extraParams: ' + extraParams);
        
        String recordTypeId = orderSrv.getRecordTypeIdByDeveloperName(selectedProcess);

        //INIZIO SVILUPPI EVERIS
        Order newOrder = new Order();    
        //FINE SVILUPPI EVERIS

        String processType = null;

        switch on selectedProcess {
            when 'HDT_RT_VAS'{
                processType = 'VAS';
            }
            when 'HDT_RT_ScontiBonus' {

                if(getServicePointTypeFromOrder(orderId) == 'HDT_RT_Ele') {
                    processType = 'Aggiunta Sconti o Bonus VAS Ele';
                } else if(getServicePointTypeFromOrder(orderId) == 'HDT_RT_Gas'){
                    processType = 'Aggiunta Sconti o Bonus VAS Gas';
                }

            }
            when 'HDT_RT_Subentro' {
                if (extraParams.get('servicePointType') == 'HDT_RT_Ele') {
                    processType = 'Subentro Ele';
                } else if(extraParams.get('servicePointType') == 'HDT_RT_Gas') {
                    processType = 'Subentro Gas';
                }
            }
            when 'HDT_RT_SwitchIn' {
                if (extraParams.get('servicePointType') == 'HDT_RT_Ele') {
                    processType = 'Switch in Ele';
                } else if(extraParams.get('servicePointType') == 'HDT_RT_Gas') {
                    processType = 'Switch in Gas';
                }
            }
            when 'HDT_RT_Attivazione' {
                if (deliberate == 'In Delibera') {
                    processType = '	Prima Attivazione In delibera';
                } else if(deliberate == 'Fuori delibera') {
                    processType = 'Prima Attivazione Fuori delibera';
                }
            }
            when 'HDT_RT_AttivazioneConModifica' {
                processType = 'Prima Attivazione con modifica';
            }
            //INIZIO SVILUPPI EVERIS
            when 'HDT_RT_Voltura'{

                newOrder.ProcessType__c = 'Voltura';
                newOrder.Id = orderId;
                newOrder.Step__c = 2;
                newOrder.RecordTypeId = recordTypeId;
                newOrder.Deliberation__c = deliberate;
                newOrder.Phase__c = 'Bozza';
                newOrder.AccountId = order.AccountId;
                newOrder.ServicePoint__c = order.ServicePoint__c;
                newOrder.ContractId = order.ContractId;
                newOrder.Subprocess__c = 'Standard';
                newOrder = orderUtl.enrichOrder(newOrder);
                orderSrv.updateRecord(newOrder);



            }
            //FINE SVILUPPI EVERIS
        }


        

        orderSrv.updateRecord(new Order(
            Id = orderId,
            RecordTypeId = recordTypeId,
            Step__c = 2,
            Deliberation__c = deliberate, 
            ProcessType__c = processType,
            Phase__c = 'Bozza' //Everis: Aggiunto update fase
        ));
    }

    private static String getServicePointTypeFromOrder(String orderId) {
        orderSrv.checkReadAccess('ContractReference__r.ServicePoint__c');
        Order order = orderQr.getRecordById(orderId);

        servicePointSrv.checkReadAccess('RecordType.DeveloperName');
        List<ServicePoint__c> servicePointList = servicePointQr.getRecordById(order.ContractReference__r.ServicePoint__c, 'RecordType.DeveloperName');

        return servicePointList[0].RecordType.DeveloperName;
    }
}