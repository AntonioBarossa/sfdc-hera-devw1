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
    private static HDT_QR_VoltureChangeManager  voltureChangeQr = new HDT_QR_VoltureChangeManager();
    private static HDT_QR_AnagAlignment regionalAdditionalQr = new HDT_QR_AnagAlignment();

    @AuraEnabled
    public static List<HDT_UTL_OrderProcessAssignment.HDT_WRP_Process> init(Order order){
        List<HDT_UTL_OrderProcessAssignment.HDT_WRP_Process> processesList = new List<HDT_UTL_OrderProcessAssignment.HDT_WRP_Process>();

        if (order.ServicePoint__c != null) {//returns processes that are different from VAS
            processesList = HDT_UTL_OrderProcessAssignment.getAvailableProcesses(order);
        }

        return processesList;
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
    public static String next(Order order,String orderId, Map<String,String> selectedProcessObject, String deliberate, Map<String,String> extraParams, ServiceRequest__c srRequest){

        String compatibility='';
        ServiceRequest__c srvReq = new ServiceRequest__c();
        srvReq.ServicePointCode__c= srRequest.ServicePointCode__c;
        srvReq.Status__c= srRequest.Status__c;
        srvReq.Order__c= srRequest.Order__c;
        srvReq.CommoditySector__c= srRequest.CommoditySector__c;
        srvReq.Type__c= srRequest.Type__c;
        if(srRequest.ServicePoint__c != null){
            srvReq.ServicePoint__c= srRequest.ServicePoint__c;
        }else{
            srvReq.Account__c= srRequest.Account__c;
            srvReq.BillingProfile__c= srRequest.BillingProfile__c;
        }
        srvReq.ProcessType__c= srRequest.ProcessType__c;
        HDT_SRV_ServiceRequest.createRecord(srvReq);
        wrts_prcgvr.ObjectCompatibility_1_0.CheckResult result = HDT_UTL_MatrixCompatibility.checkCompatibility(srvReq);
        
        if(!result.incompatibilities.isEmpty()){
            compatibility = HDT_UTL_MatrixCompatibility.getIncompatibilityMessage((ServiceRequest__c[])result.incompatibilities);
            HDT_SRV_ServiceRequest.deleteRecord(srvReq);
        }
        if(compatibility == '' || compatibility == order.OrderNumber){
            system.debug('extraParams: ' + extraParams);

            String recordTypeId = orderSrv.getRecordTypeIdByDeveloperName(selectedProcessObject.get('recordType'));

            //INIZIO SVILUPPI EVERIS
            Order newOrder = new Order();    
            //FINE SVILUPPI EVERIS

            String processType = selectedProcessObject.get('processType');
            String processCode = selectedProcessObject.get('processCode');

            switch on selectedProcessObject.get('recordType') {
                //INIZIO SVILUPPI EVERIS
                when 'HDT_RT_Voltura', 'HDT_RT_VolturaConSwitch'
                {
                    String sapCode = '';
                    //@frpanico predefault "Processo", "Sottoprocesso", "Tipo Voltura", "Codice Causale", "Data Decorrenza", "Contratto", "Codice Contratto"
                    List<Contract> contracts = contractQr.getContractFromServicePoint(order.ServicePoint__c);
                    System.debug('Condition ' + !contracts.isEmpty());
                    if(!contracts.isEmpty())
                    {
                        List<AccountContactRelation> exitingContacts = voltureChangeQr.getContactInfosByAccountId(contracts[0].AccountId);
                        newOrder.PreviousCustomer__c = exitingContacts[0]?.ContactId;
                        newOrder.ContractReference__c = contracts[0]?.Id;
						sapCode = contracts[0].SAPContractCode__c;
                    }
                    processType = selectedProcessObject.get('recordType').equalsIgnoreCase('HDT_RT_Voltura') ? 'Voltura' : 'Voltura con Switch';
                    newOrder.Subprocess__c = 'Standard';
                    newOrder.VoltureType__c = 'Ordinaria';
                    processCode = extraParams.get('servicePointType') == 'HDT_RT_Ele'? 'VT1' : 'VTG';
                    newOrder.EffectiveDate__c = orderSrv.addBusinessDay(System.today(), 3);
                    newOrder.SapContractCode__c = sapCode;
                    newOrder.Id = orderId;
                    //@frpanico "Chiamata Arricchimento Dati" per ulteriori predefault
                    callDataEnrichment(order.SAPImplantCode__c,sapCode,JSON.serialize(newOrder));
                    //newOrder = orderUtl.enrichOrder(newOrder);
                    //orderSrv.updateRecord(newOrder);
                    String tax = order.CommodityFormula__c == 'Energia Elettrica' ? newOrder.ExciseEle__c : newOrder.ExciseGAS__c;
                    String city = order.SupplyCity__c;
                    String region = '';
                    newOrder.RegionalAdditional__c = regionalAdditionalQr.findRegionalAdditional(tax, city, region);
                    newOrder.ExciseRate__c = order.CommodityFormula__c == 'Energia Elettrica' ? voltureChangeQr.getExciseTranscode(tax)[0].Excise__c : null;
                }
                when 'HDT_RT_AttivazioneConModifica' {
                    newOrder.RequestOption__c = HDT_UTL_OrderFieldsAlignment.calculateRequestedOption(order.ImplantType__c, order.PowerRequested__c);
                }
                when 'HDT_RT_TemporaneaNuovaAtt' {
                    newOrder.ConnectionType__c = null;
                }
            }

            switch on processType {
                when 'Switch in Ripristinatorio'{
                    HDT_UTL_OrderProcessAssignment.switchInRipristinatorioAction(order);
                    newOrder.SignedDate__c = Date.today();
                    newOrder.WaiverRightAfterthought__c = 'Si';
                }
                when 'Prima Attivazione'{
                    processType = 'Prima Attivazione ' + ('In Delibera'.equalsIgnoreCase(deliberate) ? 'In delibera' : 'Fuori delibera');
                    processCode = 'In Delibera'.equalsIgnoreCase(deliberate) ? 'A40' : 'A01';
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

            //Logica Superficie Servita Start
            newOrder.SurfaceServed__c = (extraParams.get('servicePointType') == 'HDT_RT_Gas' && selectedProcessObject.get('recordType') != 'HDT_RT_Voltura') ? 75 : null;
            //Logica Superficie Servita End
            orderSrv.updateRecord(newOrder);
            //EVERIS 
        }
        return compatibility;

    }
    
    @TestVisible
    private static String getServicePointTypeFromOrder(String orderId) {
        orderSrv.checkReadAccess('ContractReference__r.ServicePoint__c');
        Order order = orderQr.getRecordById(orderId);

        servicePointSrv.checkReadAccess('RecordType.DeveloperName');
        List<ServicePoint__c> servicePointList = servicePointQr.getRecordById(order.ContractReference__r.ServicePoint__c, 'RecordType.DeveloperName');

        return servicePointList[0].RecordType.DeveloperName;
    }
	/**@frpanico 26/10/2021
     * Modified method
     * Instead of hardcoding and handling each single field of the response  
     * An handler method is called
     */
    @TestVisible
    @Future(Callout = true)
    private static void callDataEnrichment(String servicePointCode, String contractCode, String newOrderSerialized)
    {
        Order newOrder = (Order)JSON.deserialize(newOrderSerialized, Order.class);
        Order orderToUpdate = new Order();
        orderToUpdate.Id = newOrder.Id;
        HDT_SRV_VoltureChangeManager voltureChangeSrv = new HDT_SRV_VoltureChangeManager();
        List<Order> orderList = new List<Order>();
        try
        {
            String serializedResponse = HDT_WS_ArricchimentoDatiTemp.submitRequest(servicePointCode, contractCode);
            List<HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoPosizioni> positions = new List<HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoPosizioni>();
            positions = (List<HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoPosizioni>)
                    JSON.deserialize(serializedResponse, List<HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoPosizioni>.class);
            
            Map<String,List<Object>> inputMap = new Map<String, List<Object>>
            {
                'posizioni' => positions,
                'sobjList' => new List<Order>{orderToUpdate}
            };

             orderList = voltureChangeSrv.handleResponseDataEnrichment(inputMap);

        } catch(Exception e){
            System.debug(LoggingLevel.DEBUG, 'Error');
        } 

        HDT_UTL_DatabaseService.updateSObject(orderList);
    }

    @AuraEnabled
    public static Boolean checkVasAndCommodity(String parentOrdId){
        try {
            List<Order> childOrders = orderQr.getChildOrdersByParentId(parentOrdId);

            Order ordCommodity = new Order();
            Order vasOrd = new Order();

            if (childOrders.size() > 1) {
                for (Order ord : childOrders) {
                    if (ord.RecordType.DeveloperName != 'HDT_RT_VAS') {
                        ordCommodity = ord;
                    } else {
                        vasOrd.Id = ord.Id;
                    }
                }

                if (vasord.Id != null) {
                    vasOrd.IncomingCreditCheckResult__c = ordCommodity.IncomingCreditCheckResult__c;
                    vasOrd.OutgoingCreditCheckResult__c = ordCommodity.OutgoingCreditCheckResult__c;
                    vasOrd.CreditCheckDescription__c = ordCommodity.CreditCheckDescription__c;
                    orderSrv.updateRecord(vasOrd);
                }
            }

            return childOrders.size() > 1 ? true : false;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<String, Object> checkContendibilita(Order order){

        try {
            return HDT_SRV_QservHandler.handler(order);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}