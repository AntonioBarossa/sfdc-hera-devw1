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

    public static List<List<String>> predefaultRatecategories = new List<List<String>>{
        new List<String>{'Disconnectable__c','No','ACANTINC00', 'ACINTERNO0', 'ACPUBNDIS0', 'ACSUBDIST0', 'ACANTIN000', 'ACTANTINC0'}, //altrimenti Si
        new List<String>{'NotDisconnectabilityCustomer__c','Si','ACANTINC00', 'ACINTERNO0', 'ACPUBNDIS0', 'ACSUBDIST0', 'ACANTIN000', 'ACTANTINC0'}, // deve sempre essere al contrario di Disconnectable__c
        //new List<String>{'SecurityDepositExcluded__c','Y','AITBNDOME0','AITMNDOME0'},
        new List<String>{'Cohabitation__c','N','ACDOMRESP0','ACPROMISC0'},
        new List<String>{'NotResidentDomesticHousingUnit__c','1','ACDOMNR000'},
        new List<String>{'ResidentDomesticHousingUnit__c','1','ACDOMRESP0'},
        new List<String>{'NotDomesticHousingUnit__c','1','ACANTINC00','ACAUNOPOT0','ACINTERNO0','ACPOZZI000','ACPUBNDIS00','ACPUBNDIS0','ACSUBDIST0','ACAUGENER0','ACANTIN000','ACPUBDIS00','ACPISPUB00','AITBAGRIC0','AITBNDOME0','AITMINDAP0','AITMINDBP0','AITMNDOME0'},
        new List<String>{'RealEstateUnit__c','1','ACAGRICO00','ACAGRIZOO0','ACANTINC00','ACARTCOMM0','ACAUNOPOT0','ACDOMNR000','ACDOMRESP0','ACINDSTR00','ACINTERNO0','ACPOZZI000','ACPUBNDIS0','ACPUBNDIS0','ACSUBDIST0','ACAUGENER0','ACZOOTECN0','APSCARPRO0','ACAUGRUNI0','ACAUGRUNC0','ACANTIN000','ACPISPUB00','ACTANTINC0','AITBAGRIC0','AITBNDOME0','AITMINDAP0','AITMINDBP0','AITMNDOME0'},
        new List<String>{'AgriculturalHousingUnit__c','1','ACAGRICO00'},
        new List<String>{'CommercialHousingUnit__c','1','ACARTCOMM0','ACAUGRUNC0'},
        new List<String>{'IndustrialHousingUnit__c','1','ACINDSTR00','ACAUGRUNI0'},
        new List<String>{'ZootechnicalHousingUnit__c','1','ACAGRIZOO0','ACZOOTECN0'}/* ,
        new List<String>{'SeasonUse__c','Nessuna stagionalita','ACAGRICO00','ACAUNOPOT0','ACINDSTR00','ACINTERNO0','ACPOZZI000','ACPROMISC0','ACAUGRUNI0','ACPROMIBI0','ACTANTINC0','AITBAGRIC0','AITMINDAP0','AITMINDBP0','AITMNDOME0'} */
    };

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
    public static string getProcessDriver(Order order)
    {
        try
        {
            return  HDT_UTL_OrderProcessAssignment.getProcessDriver(order);
        }
        catch(Exception e)
        {
            return '';
        }
    
    }

    @AuraEnabled
    public static String getConsumptionAnnualForVas(String orderId){
        
        try{
            String consumptionAnnual = null;
            if(orderId != null && orderId != ''){
                List<OrderItem> orderItemList = [SELECT Id,ConsumptionAnnualVAS__c FROM OrderItem WHERE OrderId = :orderId AND Order.IsVAS__c = true AND ConsumptionAnnualVAS__c != null WITH SECURITY_ENFORCED];
                if(!orderItemList.isEmpty() && orderItemList[0] != null){
                    consumptionAnnual = String.valueOf(orderItemList[0].ConsumptionAnnualVAS__c);
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

        List<SObject> objToUpdate = new List<SObject>();
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
                    processCode = extraParams.get('servicePointType') == 'HDT_RT_Ele'? 'VT1' : processCode;
                    processCode = extraParams.get('servicePointType') == 'HDT_RT_Gas'? 'VTG' : processCode;
                    processCode = extraParams.get('servicePointType') == 'HDT_RT_Acqua'? 'MA1' : processCode;
                    newOrder.EffectiveDate__c = processCode!= 'MA1'?orderSrv.addBusinessDay(System.today(), 3):System.today();
                    newOrder.SapContractCode__c = sapCode;
                    newOrder.Id = orderId;
                    //@frpanico "Chiamata Arricchimento Dati" per ulteriori predefault
                    if( !'Acqua'.equalsIgnoreCase(order.CommodityFormula__c) && !'Teleriscaldamento'.equalsIgnoreCase(order.CommodityFormula__c) ){
                        callDataEnrichment(order.SAPImplantCode__c,sapCode,JSON.serialize(newOrder));
                    }
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
                    if ( 'Switch in Ripristinatorio'.equalsIgnoreCase(processType) ) {
                        HDT_UTL_OrderProcessAssignment.switchInRipristinatorioAction(order);
                        newOrder.SignedDate__c = Date.today();
                        newOrder.WaiverRightAfterthought__c = 'Si';
                    }
                }
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
            }

            newOrder.Disconnectable__c = 'Si';
            newOrder.NotDisconnectabilityCustomer__c = 'No';
            newOrder.VAT__c = 'Iva 22% (Cod. 02)';
            newOrder.AggregateBilling__c = 'Si';
        
            switch on order.CommodityFormula__c {
                when 'Acqua' {
                    //Inizio: Predefault valido per tutti i processi
                    List<Contract> contractsList = contractQr.getContractFromServicePoint(order.ServicePoint__c);
                    newOrder.ContractReference__c = !contractsList.isEmpty()? contractsList[0]?.Id : null;
                    AmministrazioneSottotipologiaUso__c ammSubType = HDT_SRV_DataEnrichmentPostSales.handleSubType( order.SalesCompany__c, order.RateCategory__c );
                    List<ServicePoint__c> updatedServicePoint = servicePointQr.getRecordById( order.ServicePoint__c , 'Ato__c,PayPurification__c,PaySewer__c' );
                    newOrder.UseSubCategory__c = ammSubType?.SottotipologiaUso__c;
                    newOrder.IntendedUse__c = ammSubType?.IntendedUse__c;
                    newOrder.ContractExpenses__c = 'Nessuno Sconto';
                    newOrder.SecurityDepositExcluded__c = 'N';
                    newOrder.ATO__c = updatedServicePoint[0].ATO__c;
                    newOrder.VAT__c = 'Iva 10% (Cod. 01)';
                    newOrder.PayPurification__c = updatedServicePoint[0].PayPurification__c;
                    newOrder.PaySewer__c = updatedServicePoint[0].PaySewer__c;
                    newOrder.AggregateBilling__c = 'No';
                    newOrder.EffectiveDate__c = System.Today();
                    newOrder.SeasonUse__c = 'Nessuna stagionalita';
                    //Fine: Predefault valido per tutti i processi

                    //Inizio: Predefault secondo Processo
                    switch on processType {
                        when 'Prima Attivazione'{
                            //newOrder.SecurityDepositExcluded__c  = 'Y';
                            newOrder.SeasonUse__c  = 'Nessuna stagionalita';
                            if( '1106-Cantiere'.equalsIgnoreCase(order.ImplantType__c) || '1108-Irriguo'.equalsIgnoreCase(order.ImplantType__c) ){
                                newOrder.PayPurification__c = 'No - Esente';
                                newOrder.PaySewer__c = 'No - Esente';
                            }
                            else{
                                newOrder.PayPurification__c = 'Si - Paga';
                                newOrder.PaySewer__c = 'Si - Paga';
                            }
                        }
                        when 'Connessione con Attivazione'{
                            //vuoto perchè E1 non riuscirebbe a generare il plico
                            newOrder.QuotationType__c = '';
                            if( '1106-Cantiere'.equalsIgnoreCase(order.ImplantType__c) || '1108-Irriguo'.equalsIgnoreCase(order.ImplantType__c) ){
                                newOrder.PayPurification__c = 'No - Esente';    //logica presente solo per RT Prima Attivazione e Connessione Con Attivazione
                                newOrder.PaySewer__c = 'No - Esente';           //per gli altri i valori sono presi da Arricchimento come da BPP
                            }
                            else{
                                newOrder.PayPurification__c = 'Si - Paga';
                                newOrder.PaySewer__c = 'Si - Paga';
                            }
                        }
                        when 'Aggiunta Attacco con Attivazione'{
                            newOrder.PerformanceType__c = 'Aggiunta Attacco';
                            if( '1106-Cantiere'.equalsIgnoreCase(order.ImplantType__c) || '1108-Irriguo'.equalsIgnoreCase(order.ImplantType__c) ){
                                newOrder.PayPurification__c = 'No - Esente';
                                newOrder.PaySewer__c = 'No - Esente';
                            }
                            else{
                                newOrder.PayPurification__c = 'Si - Paga';
                                newOrder.PaySewer__c = 'Si - Paga';
                            }
                        }
                        when 'Cambio Offerta'{
                            newOrder.ContractExpenses__c = 'Nessun Addebito';
                        }
                        when 'Voltura'{
                            newOrder.ContractExpenses__c = 'Mortis Causa'.equalsIgnoreCase(newOrder.VoltureType__c) ? 'Nessun Addebito' : 'Nessuno Sconto' ;
                        }
                        when 'Subentro'{
                            newOrder.SeasonUse__c  = 'Nessuna stagionalita';
                        }
                    }
                    //Fine: Predefault secondo Processo

                    //Inizio: Predefault secondo RateCategory
                    for (List<String> fieldToPredefault : predefaultRatecategories) {
                        if( fieldToPredefault.contains(order.RateCategory__c) ){
                            String defaultValue = fieldToPredefault.get(1);
                            if (defaultValue.isNumeric()){
                                newOrder.put( fieldToPredefault.get(0), Integer.valueof(defaultValue) );
                            } 
                            else {
                                newOrder.put( fieldToPredefault.get(0), defaultValue );
                            }
                        }
                    }
                    
                }
                when 'Energia Elettrica' {
                    newOrder.VAT__c = order.SupplyType__c == 'Domestico' ? 'Iva 10% (Cod. 01)' : 'Iva 22% (Cod. 02)';
                }
                when 'Gas' {
                    newOrder.ExciseGAS__c = (order.SupplyType__c == 'A-Domestico' || order.SupplyType__c == 'B-Condominio') ? 'Imposta Usi Domestici (Cod. G_ICD)' : 'Imposta usi non domestici iva 22% (Cod. G_ICC)';
                    newOrder.PressureLevel__c = 'BP';
                    //Logica Superficie Servita Start
                    newOrder.SurfaceServed__c = 75;
                    //Logica Superficie Servita End
                    if( 'Prima Attivazione'.equalsIgnoreCase(processType)  ) {
                        processType = 'Prima Attivazione ' + ('In Delibera'.equalsIgnoreCase(deliberate) ? 'In delibera' : 'Fuori delibera');
                        processCode = 'In Delibera'.equalsIgnoreCase(deliberate) ? 'A40' : 'A01';
                        newOrder.PressureLevel__c  = 'BP';
                    }
                }
            }

            newOrder.Id = orderId;
            newOrder.RecordTypeId = recordTypeId;
            newOrder.Step__c = 2;
            newOrder.Deliberation__c = deliberate;
            newOrder.ProcessType__c = processType;
            newOrder.ProcessCode__c = processCode;
            newOrder.Phase__c = 'Bozza';

            objToUpdate.add(newOrder);
            HDT_UTL_DatabaseService.updateSObject(objToUpdate);
            
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
            List<SObject> myOrd = HDT_QR_GenericQuery.getGenericRecords('Id', 'Order', 'Id = \''+ord.Id+'\' AND CreditCheckInProgress__c = false AND IncomingCreditCheckResult__c = null AND OutgoingCreditCheckResult__c = null');
            if (myOrd.isEmpty()){
                return true;
            }
            
            if (response){
                myOrd[0].put('CreditCheckInProgress__c',true);
                HDT_UTL_DatabaseService.updateSObject(myOrd);
            }
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