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
    public static List<ProcessMatrix__c> init(Order order){
        List<ProcessMatrix__c> processesList = new List<ProcessMatrix__c>();

        if (order.ServicePoint__c != null && order.IsVAS__c == false 
            && (order.VasSubtype__c == null || (order.VasSubtype__c != null && !order.VasSubtype__c.equalsIgnoreCase('Analisi Consumi')))) {//returns processes that are different from VAS
            processesList = HDT_UTL_OrderProcessAssignment.getAvailableProcesses(order);
        }

        return processesList;
    }

    @AuraEnabled
    public static String getConsumptionAnnualForVas(String orderId){
        
        try{
            String consumptionAnnual = null;
            if(orderId != null && orderId != ''){
                List<OrderItem> orderItemList = [SELECT Id,ConsumptionAnnual__c FROM OrderItem WHERE OrderId = :orderId AND Order.IsVAS__c = true AND ConsumptionAnnual__c != null WITH SECURITY_ENFORCED];
                if(!orderItemList.isEmpty() && orderItemList[0] != null){
                    consumptionAnnual = String.valueOf(orderItemList[0].ConsumptionAnnual__c);
                }
            }
            return consumptionAnnual;
        }
        catch(Exception ex){
            return null;
        }
        
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
            if(srRequest.BillingProfile__c != null)
            {
                srvReq.BillingProfile__c= srRequest.BillingProfile__c;
            }
        }
        if(srvReq.Type__c != null && srvReq.ServicePointCode__c != null && (srvReq.Type__c.containsIgnoreCase('Sconti e bonus') || srvReq.ServicePointCode__c.equalsIgnoreCase('PODPROVVISORIO')))
        {
            srvReq.Account__c = srRequest.Account__c;
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

            String recordTypeId = orderSrv.getRecordTypeIdByDeveloperName(selectedProcessObject.get('RecordTypeName__c'));

            //INIZIO SVILUPPI EVERIS
            Order newOrder = new Order();    
            //FINE SVILUPPI EVERIS

            String processType = selectedProcessObject.get('ProcessName__c');
            String processCode = selectedProcessObject.get('CasualCode__c');

            switch on selectedProcessObject.get('RecordTypeName__c') {
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
                        if(!exitingContacts.isEmpty())
                        {
                            newOrder.PreviousCustomer__c = exitingContacts[0]?.ContactId;
                        }
                        newOrder.ContractReference__c = contracts[0]?.Id;
						sapCode = contracts[0].SAPContractCode__c;
                    }
                    processType = selectedProcessObject.get('RecordTypeName__c').equalsIgnoreCase('HDT_RT_Voltura') ? 'Voltura' : 'Voltura con Switch';
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
                    newOrder.ExciseRate__c = voltureChangeQr.getExciseTranscode(tax)[0].Excise__c;
                }
                when 'HDT_RT_AttivazioneConModifica' {
                    newOrder.RequestOption__c = HDT_UTL_OrderFieldsAlignment.calculateRequestedOption(order.ImplantType__c, order.PowerRequested__c);
                }
                when 'HDT_RT_TemporaneaNuovaAtt' {
                    newOrder.ConnectionType__c = null;
                }
                when 'HDT_RT_SwitchIn' {
                    newOrder.PowerRequested__c  = order.PowerCommitted__c;
                    newOrder.WaiverRightAfterthought__c	= 'No';
                }
                /**@frpanico 2022-03-16
                 * Aggiunta Sconti Bonus
                 * Predefault Data Decorrenza 
                 * al primo giorno del mese successivo
                 */
                when 'HDT_RT_ScontiBonus'
                {
                    newOrder.EffectiveDate__c = getEffectiveDateBonus(orderId);
                }
                when 'HDT_RT_VAS'
                {
                    if(order.VASSubtype__c.equalsIgnoreCase('Analisi Consumi'))
                    {
                        newOrder.EffectiveDate__c = getEffectiveDateBonus(orderId);
                    }
                }
                when 'HDT_RT_CambioOfferte'
                {
                    if('Acqua'.equalsIgnoreCase(order.Commodity__c))
                    {
                        newOrder.EffectiveDate__c = System.Today();
                    }
                }
            }

            switch on processType {
                when 'Switch in Ripristinatorio'{
                    HDT_UTL_OrderProcessAssignment.switchInRipristinatorioAction(order);
                    newOrder.SignedDate__c = Date.today();
                    newOrder.WaiverRightAfterthought__c = 'Si';
                }
                when 'Prima Attivazione'{
                    if(order.CommodityFormula__c == 'Gas')
                    {
                        processType = 'Prima Attivazione ' + ('In Delibera'.equalsIgnoreCase(deliberate) ? 'In delibera' : 'Fuori delibera');
                        processCode = 'In Delibera'.equalsIgnoreCase(deliberate) ? 'A40' : 'A01';
                        newOrder.PressureLevel__c  = 'BP';
                    }
                    if(order.CommodityFormula__c == 'Acqua')
                    {
                        newOrder.SecurityDepositExcluded__c  = 'Y';
                        newOrder.SeasonUse__c  = 'Nessuna stagionalita';
                        newOrder.PayPurification__c  = 'No - Esente';
                        newOrder.PaySewer__c  = 'No - Esente';
                    }
                }
                when 'Connessione con Attivazione'{
                    if('Acqua'.equalsIgnoreCase(order.Commodity__c))
                    {
                        newOrder.QuotationType__c = 'Analitico';
                        newOrder.VAT__c = 'Iva 10% (Cod. 01)';
                        newOrder.PaySewer__c = 'No - Esente';
                        newOrder.PayPurification__c = 'No - Esente';
                        newOrder.ResidentDomesticHousingUnit__c = 1;
                    }
                }
            }

            newOrder.NotDisconnectabilityCustomer__c = 'No';
            newOrder.VAT__c = 
                order.CommodityFormula__c == 'Energia Elettrica' ?
                    order.SupplyType__c == 'Domestico' ? 'Iva 10% (Cod. 01)' : 'Iva 22% (Cod. 02)'
                : 'Iva 22% (Cod. 02)';
            
            if(order.CommodityFormula__c == 'Gas')
            {
                newOrder.ExciseGAS__c = (order.SupplyType__c == 'A-Domestico' || order.SupplyType__c == 'B-Condominio') ? 'Imposta Usi Domestici (Cod. G_ICD)' : 'Imposta usi non domestici iva 22% (Cod. G_ICC)';
            }

            //EVERIS: MODIFICATA LOGICA DI UPDATE PER GESTIRE I PREDEFAULT
            newOrder.Id = orderId;
            newOrder.RecordTypeId = recordTypeId;
            newOrder.Step__c = 2;
            newOrder.Deliberation__c = deliberate;
            newOrder.ProcessType__c = processType;
            newOrder.ProcessCode__c = processCode;
            newOrder.AggregateBilling__c = 'Si';
            newOrder.Phase__c = 'Bozza';
            newOrder.PressureLevel__c =  (extraParams.get('servicePointType') == 'HDT_RT_Gas') ? 'BP' : null;
            //Logica Superficie Servita Start
            newOrder.SurfaceServed__c = (extraParams.get('servicePointType') == 'HDT_RT_Gas') ? 75 : null;
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
    public static Boolean checkVasAndCommodity(Order ord, String recordTypeName){
        try {
            Boolean response = HDT_UTL_OrderProcess.checkRecordTypeForCreditCheck(recordTypeName, ord); 
            /* Commentato perchè è stata tolta la fase AttesaCC
            if (response){
                HDT_UTL_DatabaseService.updateSObject(new Order(Id = ord.Id, CreditCheckInProgress__c = true));
            } */
            return !response;
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

    @TestVisible
    private static Date getEffectiveDateBonus(String orderId)
    {
        Order currentOrder = orderQr.getRecordById(orderId);
        Date effectiveDate = System.today();
        if(currentOrder.NumeratorGroup__c != null && ((String)currentOrder.get('NumeratorGroup__c')).equalsIgnoreCase('ELPVEDM'))
        {
            effectiveDate =  (System.today().addMonths(1)).toStartOfMonth();
        }

        return effectiveDate;
    }
}