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
    private static HDT_QR_Contract contractQr = new HDT_QR_Contract();

    @AuraEnabled
    public static List<HDT_UTL_OrderProcessAssignment.HDT_WRP_Process> init(Order order){
        system.debug('Keltin: ' + order);
        system.debug('Keltin2: ' + HDT_UTL_OrderProcessAssignment.getAvailableProcesses(order));
        return HDT_UTL_OrderProcessAssignment.getAvailableProcesses(order);
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
    public static void next(Order order,String orderId, Map<String,String> selectedProcessObject, String deliberate, Map<String,String> extraParams){

        system.debug('extraParams: ' + extraParams);
        
        String recordTypeId = orderSrv.getRecordTypeIdByDeveloperName(selectedProcessObject.get('recordType'));

        //INIZIO SVILUPPI EVERIS
        Order newOrder = new Order();    
        //FINE SVILUPPI EVERIS

        String processType = selectedProcessObject.get('processType');
        String processCode = selectedProcessObject.get('processCode');

        switch on selectedProcessObject.get('recordType') {
            when 'HDT_RT_VAS'{
                processType = 'VAS';
            }
            //INIZIO SVILUPPI EVERIS
            when 'HDT_RT_Voltura'{
                List<Contract> contracts = contractQr.getContractFromServicePoint(newOrder.ServicePoint__c);
                processType = 'Voltura';
                newOrder.Subprocess__c = 'Standard';
                processCode = extraParams.get('servicePointType') == 'HDT_RT_Ele'? 'VT1' : 'VTG';
                newOrder.EffectiveDate__c = orderSrv.addBusinessDay(System.today(), 3);
                newOrder.ContractReference__c = contracts.size() > 0 
                    ? contracts[0].Id
                    : null;
                //newOrder = orderUtl.enrichOrder(newOrder);
                //orderSrv.updateRecord(newOrder);
            }
            //FINE SVILUPPI EVERIS
        }

        switch on processType {
            when 'Switch in Ripristinatorio	'{
                HDT_UTL_OrderProcessAssignment.switchInRipristinatorioAction(order);
            }
        }

        //EVERIS: MODIFICATA LOGICA DI UPDATE PER GESTIRE I PREDEFAULT
        newOrder.Id = orderId;
        newOrder.RecordTypeId = recordTypeId;
        newOrder.Step__c = 2;
        newOrder.Deliberation__c = deliberate;
        newOrder.ProcessType__c = processType;
        newOrder.ProcessCode__c = processCode;
        newOrder.Phase__c = 'Bozza';

        orderSrv.updateRecord(newOrder);
        //EVERIS 
    }

    private static String getServicePointTypeFromOrder(String orderId) {
        orderSrv.checkReadAccess('ContractReference__r.ServicePoint__c');
        Order order = orderQr.getRecordById(orderId);

        servicePointSrv.checkReadAccess('RecordType.DeveloperName');
        List<ServicePoint__c> servicePointList = servicePointQr.getRecordById(order.ContractReference__r.ServicePoint__c, 'RecordType.DeveloperName');

        return servicePointList[0].RecordType.DeveloperName;
    }
}