/**
 * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
 * @date 13/02/2021
 * @description HDT_LC_ChildOrderProcessDetails.cls - Class that holds methods that are called from hdtChildOrderProcessDetails.js
 * @history Inserire Nome Cognome – Data Modifica – Descrizione della modifica
 */
public inherited sharing class HDT_LC_ChildOrderProcessDetails {
    
    private static HDT_QR_Order orderQr = new HDT_QR_Order();
    private static HDT_SRV_Order orderSrv = new HDT_SRV_Order();
    private static HDT_SRV_ServicePoint servicePointSrv= new HDT_SRV_ServicePoint();
    private static HDT_SRV_BillingProfile billingProfileSrv = new HDT_SRV_BillingProfile();
    private static HDT_SRV_Account accountSrv = new HDT_SRV_Account();
    private static HDT_QR_Case caseQr = new HDT_QR_Case();
    private static HDT_QR_RecordType rctype = new  HDT_QR_RecordType();
    private static HDT_SRV_ActivityCustom activitySrv = new HDT_SRV_ActivityCustom();
    private static HDT_QR_ContentDocumentLink contDocLinkQr = new HDT_QR_ContentDocumentLink();
    private static HDT_QR_VoltureChangeManager voltureChangeQr = new HDT_QR_VoltureChangeManager();

    @AuraEnabled
    public static Map<String,Object> init(String id){
        Map<String,Object> result = new Map<String,Object>();

        User user = HDT_QR_UserQueries.getCurrentUser(UserInfo.getUserId());

        result.put('loginChannel', user.LoginChannel__c);

        return result;
    }


    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @description Update order process step
    * @param Order order
    * @param Decimal step
    * @param String objectApiName
    * @param SObject objectToUpdate
    */
    @AuraEnabled
    public static void createActivityAccise(boolean flagAccise,boolean flagVat,String orderId,String accountId){
        System.debug('******');
        Order o = new Order();
        o.id = orderId;
        o.FacilitationExcise__c = flagAccise;
        o.VATfacilitationFlag__c = flagVat; 
        orderSrv.updateRecord(o);
        RecordType rc= rctype.getRecordType('HDT_RT_AttivitaGestionali', 'wrts_prcgvr__Activity__c');
        // String res = '';
        ID recTypeId;
        if(rc !=null){
            recTypeId= rc.Id;
        }
        wrts_prcgvr__Activity__c activity= new wrts_prcgvr__Activity__c(order__c = orderId, Account__c= accountId, RecordTypeId= recTypeId, Type__c= 'Iva e Accise da validare');
        System.debug(activity);
        activitySrv.createRecord(activity);
        
    }

    @AuraEnabled
    @SuppressWarnings('PMD.AvoidDeeplyNestedIfStmts')
    public static void updateProcessStep(SObject order,
        //INIZIO SVILUPPI EVERIS 
        Boolean isVolture,
        Boolean isRetroactive,
        Boolean isReading,
        Boolean isUpdateStep,
        Date readingDate){
        //FINE SVILUPPI EVERIS
        
        System.debug('updateProcessStep: ' + order);
        System.debug('isVolture: '+isVolture);
        
        if(order.getSObjectType().getDescribe().getName() == 'Order')
        {
            Order orderToUpdate = (Order) order;

            Order currentOrder = new Order();

            /* Query the currentOrder */
            currentOrder = voltureChangeQr.getOrderInfosById(order.Id)[0];
                    
            Map<string,Object> inputs = new Map<string,Object>();
            inputs.put('orderNew',orderToUpdate);
            inputs.put('currentOrder',currentOrder);
            inputs.put('isVolture',isVolture);
            inputs.put('isRetroactive',isRetroactive);
            inputs.put('isReading',isReading);
            inputs.put('isUpdateStep',isUpdateStep);
            inputs.put('readingDate',readingDate);

            //INIZIO SVILUPPI EVERIS CHECK VOLTURA
            if(isVolture != null && isVolture == true)
            {
                HDT_WRP_VoltureChangeManager.HDT_WRP_ProcessCheck checks = HDT_UTL_VoltureChangeManager.processCheck(inputs);
                if(checks.result != 'OK'){
                    throw new AuraHandledException(checks.message);
                }else{
                    orderToUpdate = (Order)checks.sobj;
                }

            }
            /* Aggiunto Controllo per verificare che in fase di lavorazione 
            scarto l'operatore inserisca i dati del precedente intestatario*/
            if(currentOrder.IsTechnicalTransfer__c && 'Amm. Precheck KO SII'.equalsIgnoreCase(currentOrder.Phase__c))
            {
                HDT_WRP_VoltureChangeManager.HDT_WRP_TransferCheck trCheck = new HDT_WRP_VoltureChangeManager.HDT_WRP_TransferCheck();

                trCheck.firstName = String.isBlank(orderToUpdate.PreviousHolderFirstName__c) ? 
                    (String.isBlank(currentOrder.PreviousHolderFirstName__c) ? '' : currentOrder.PreviousHolderFirstName__c) : orderToUpdate.PreviousHolderFirstName__c;
                trCheck.lastName = String.isBlank(orderToUpdate.PreviousHolderLastName__c) ? 
                    (String.isBlank(currentOrder.PreviousHolderLastName__c) ? '' : currentOrder.PreviousHolderLastName__c) : orderToUpdate.PreviousHolderLastName__c;
                trCheck.fiscalCode = String.isBlank(orderToUpdate.PreviousHolderFiscalCode__c) ? 
                    (String.isBlank(currentOrder.PreviousHolderFiscalCode__c) ? '' : currentOrder.PreviousHolderFiscalCode__c) : orderToUpdate.PreviousHolderFiscalCode__c;
                trCheck.vatNumber = String.isBlank(orderToUpdate.PreviousHolderVatNumber__c) ? 
                    (String.isBlank(currentOrder.PreviousHolderVatNumber__c) ? '' : currentOrder.PreviousHolderVatNumber__c) : orderToUpdate.PreviousHolderVatNumber__c;
                trCheck.companyName = String.isBlank(orderToUpdate.PreviousHoldeCompanyName__c) ? 
                    (String.isBlank(currentOrder.PreviousHoldeCompanyName__c) ? '' : currentOrder.PreviousHoldeCompanyName__c) : orderToUpdate.PreviousHoldeCompanyName__c;
                HDT_WRP_VoltureChangeManager.HDT_WRP_ProcessCheck innerCheck = checkTechnicalTransfer(trCheck);
                if(String.isNotBlank(innerCheck.result))
                {
                    throw new AuraHandledException(check.message);
                }
            }
            if(orderToUpdate.TemporaryConnectionStartDate__c != null 
            && orderToUpdate.TemporaryConnectionEndDate__c != null
            && orderToUpdate.TemporaryConnectionEndDate__c <= orderToUpdate.TemporaryConnectionStartDate__c)
            {
                throw new AuraHandledException('La data fine connessione temporanea non puo essere precedente alla data inizio!');
            }

            if((currentOrder.RecordType.DeveloperName == 'HDT_RT_ScontiBonus' || (currentOrder.VasSubtype__c != null && currentOrder.VasSubtype__c.equalsIgnoreCase('Analisi Consumi')))&& orderToUpdate.EffectiveDate__c != null )
            {
                if(((String)currentOrder.get('NumeratorGroup__c')).equalsIgnoreCase('ELPVEDM') && orderToUpdate.EffectiveDate__c.day() != 1)
                {
                    throw new AuraHandledException('La data decorrenza deve essere popolata con il primo giorno del mese');
                }
            }
            exeChecks(orderToUpdate);

            orderSrv.updateRecord(orderToUpdate);
        }
        if(order.getSObjectType().getDescribe().getName() == 'OrderItem')
        {
            OrderItem ordItem = (OrderItem) order;
            Order orderToUpdate = new Order();
            Decimal step = Decimal.valueOf(String.valueOf(ordItem.Description));
            List<SObject> sobjListToUpdate = new List<SObject>();
            System.debug('OrderItem: ' + JSON.serialize(ordItem));
            List<OrderItem> currentOrderItem = [SELECT OwnerAC__c, DwellingType__c, OccupantsNumber__c, Surface__c,SBQQ__QuoteLine__c FROM OrderItem WHERE Id = :ordItem.Id WITH SECURITY_ENFORCED];
            SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c();
            quoteLine.Id = currentOrderItem[0].SBQQ__QuoteLine__c;
            quoteLine.OwnerAC__c = ordItem.OwnerAC__c != null ? ordItem.OwnerAC__c : currentOrderItem[0].OwnerAC__c;
            quoteLine.DwellingType__c = ordItem.DwellingType__c != null ? ordItem.DwellingType__c : currentOrderItem[0].DwellingType__c;
            quoteLine.OccupantsNumber__c = ordItem.OccupantsNumber__c != null ? ordItem.OccupantsNumber__c : currentOrderItem[0].OccupantsNumber__c;
            quoteLine.Surface__c = ordItem.Surface__c != null ? ordItem.Surface__c : currentOrderItem[0].Surface__c;
            orderToUpdate.Id = ordItem.OrderId;
            orderToUpdate.Step__c = step;
            ordItem.Description = '';
            sobjListToUpdate.add(orderToUpdate);
            sobjListToUpdate.add(ordItem);
            sobjListToUpdate.add(quoteLine);
            HDT_UTL_DatabaseService.updateSObject(sobjListToUpdate);
        }
        
    }

    /* Wrapper Method */
    @AuraEnabled
    public static void updateProcessStep(Order order, 
    Boolean isVolture,
    Boolean isRetroactive,
    Boolean isReading,
    Date readingDate){

        Boolean isUpdateStep = false;
        updateProcessStep(order, isVolture, isRetroactive, isReading, isUpdateStep, readingDate);

    }

    private static void exeChecks(Order order){
        //Check RequestOption__c (Opzione di Distribuzione) START
        if(order.RecordType.DeveloperName != 'HDT_RT_TemporaneaNuovaAtt' && order.ImplantType__c != null && order.PowerCommitted__c != null){
            orderSrv.checkReadAccess('RequestOption__c');
            Order oldOrder = orderQr.getRecordById(order.Id);

            String calculatedRequestOption = HDT_UTL_OrderFieldsAlignment.calculateRequestedOption(oldOrder.ImplantType__c, oldOrder.PowerCommitted__c);

            if (calculatedRequestOption != oldOrder.RequestOption__c) {
                throw new AuraHandledException('Il campo Opzione di Distribuzione e stato cambiato');
            }
        } else if(order.RecordType.DeveloperName != 'HDT_RT_TemporaneaNuovaAtt' && order.RequestOption__c != null){
            orderSrv.checkReadAccess('RequestOption__c');
            Order oldOrder = orderQr.getRecordById(order.Id);

            if (order.RequestOption__c != '' && oldOrder.RequestOption__c != null && order.RequestOption__c != oldOrder.RequestOption__c) {
                throw new AuraHandledException('Il campo Opzione di Distribuzione e stato cambiato');
            }
        }
        //Check RequestOption__c (Opzione di Distribuzione) END

        //Check iva e accise docs START
        if (order.VATfacilitationFlag__c || order.FacilitationExcise__c) {
            List<ContentDocumentLink> docsIvaAccise = contDocLinkQr.getRecordsByEntityAndContentDocumentDescription(order.Id, 'ivaAccise');

            if (docsIvaAccise.isEmpty()) {
                throw new AuraHandledException('Caricare documento per iva e accise');
            }
        }
        //Check iva e accise docs END
    }


    
   
    /**
    * @description 
    * @author federico.defelice@webresults.it | 01-08-2021 
    * @param ord 
    * @return string 
    **/
    @AuraEnabled
    public static HDT_WRP_QuoteType getQuoteTypeMtd(Order ord){
        system.debug(ord);
        HDT_WRP_QuoteType wrp = new HDT_WRP_QuoteType();
        String recordTypeDevName = Schema.getGlobalDescribe().get('Order').getDescribe().getRecordTypeInfosById().get((String)ord.get('RecordTypeId')).getDeveloperName();
        try {
            List<QuoteManagement__c> metas;

            if(recordTypeDevName=='HDT_RT_ConnessioneConAttivazione'){
                //ConnessioneConAttivazione
                metas= [SELECT QuoteType__c, OperationCode__c FROM QuoteManagement__c WHERE CausalCode__c=:ord.ProcessCode__c AND Operation_type__c='HDT_RT_ConnessioneConAttivazione' WITH SECURITY_ENFORCED] ;
                wrp.quoteType= metas[0].QuoteType__c; 
                wrp.quoteCode=formatCode( Decimal.ValueOf(metas[0].OperationCode__c) ); 
                system.debug(metas);
                return wrp;
            }

            String checkPrPc= getPrPc(ord);
            Decimal power = ord.PowerRequested__c != null ? ord.PowerRequested__c : ord.PowerAvailable__c;
            String powerRange=HDT_UTL_QuoteManagement.getRangeValue(power);

            Boolean isDispatcherInMtd= HDT_UTL_QuoteManagement.checkLocalDispatcher(ord.DistributorFormula__c);
            String distributor = isDispatcherInMtd ? 'InRete' : 'ExtraRete';
                            

            system.debug(LoggingLevel.DEBUG,'RequestPhase '+ord.RequestPhase__c);
            system.debug(LoggingLevel.DEBUG,'ConnectionType__c '+ord.ConnectionType__c);
            system.debug(LoggingLevel.DEBUG,'ProcessCode__c '+ord.ProcessCode__c);
            system.debug(LoggingLevel.DEBUG,'VendDistr__c '+distributor);
            system.debug(LoggingLevel.DEBUG,'PowerRequested__c '+ord.PowerRequested__c);
            system.debug(LoggingLevel.DEBUG,'PowerAvailable__c '+ ord.PowerAvailable__c);
            system.debug(LoggingLevel.DEBUG,'VoltageLevel__c '+ ord.VoltageLevel__c);
            system.debug(LoggingLevel.DEBUG,'PowerCommitted__c '+ ord.PowerCommitted__c);
            system.debug(LoggingLevel.DEBUG,'EnergyUseCase__c '+ord.UseTypeEnergy__c);
            system.debug(LoggingLevel.DEBUG,'PowerRange__c '+powerRange);
            system.debug(LoggingLevel.DEBUG,'ComparePowReq__c '+checkPrPc);
            system.debug(LoggingLevel.DEBUG,'RT '+recordTypeDevName);

            if(recordTypeDevName=='HDT_RT_TemporaneaNuovaAtt'){
                system.debug('if1 ok');
                metas = [SELECT QuoteType__c, OperationCode__c FROM QuoteManagement__c 
                    WHERE CausalCode__c=:ord.ProcessCode__c AND VendDist__c =:distributor AND VoltageRequired__c =:ord.VoltageLevel__c
                        AND ( EnergyUseType__c= :ord.UseTypeEnergy__c OR EnergyUseType__c='')
                        AND PowerRequired__c=:powerRange AND (ComparePotRi__c=:checkPrPc OR ComparePotRi__c='') AND Operation_type__c =:recordTypeDevName
                    WITH SECURITY_ENFORCED
                    ORDER BY EnergyUseType__c NULLS LAST
                ];
            }else if(recordTypeDevName=='HDT_RT_AttivazioneConModifica'){
                system.debug('if2 ok');
                metas = [SELECT QuoteType__c, OperationCode__c FROM QuoteManagement__c 
                    WHERE RequestedPhase__c =:ord.RequestPhase__c AND ConnectionType__c=:ord.ConnectionType__c 
                        AND CausalCode__c=:ord.ProcessCode__c AND VendDist__c =:distributor AND VoltageRequired__c =:ord.VoltageLevel__c
                        AND ( EnergyUseType__c= :ord.UseTypeEnergy__c OR EnergyUseType__c='')
                        AND PowerRequired__c=:powerRange AND (ComparePotRi__c=:checkPrPc OR ComparePotRi__c= '' ) AND Operation_type__c =:recordTypeDevName
                    WITH SECURITY_ENFORCED
                    ORDER BY EnergyUseType__c NULLS LAST
                ];
            }
            system.debug(metas);
            if(!metas?.isEmpty()){
                wrp.quoteType= metas[0].QuoteType__c;  
                // Integer code = Integer.valueOf(metas[0].OperationCode__c);
                wrp.quoteCode=formatCode( Decimal.ValueOf(metas[0].OperationCode__c) );        
            }
        } catch (Exception e) {
            system.debug(e.getStackTraceString()+' at line '+e.getLineNumber());
            system.debug(e.getMessage()+' '+e.getCause());
            throw new AuraHandledException(e.getMessage());
        }
        return wrp;
    }

    /**
    * @description 
    * @author federico.defelice@webresults.it | 29-07-2021 
    * @param ord 
    * @return String 
    **/
    private static String getPrPc(Order ord){
        if(ord.PowerRequested__c != null && ord.PowerCommitted__c != null ){
            if(ord.PowerRequested__c > ord.PowerCommitted__c){
                return 'MAG';
            }else if (ord.PowerRequested__c < ord.PowerCommitted__c){
                return 'MIN';
            }
        }
        return '';
    }

    private static String formatCode(Decimal floatCode){
        Integer code = Integer.valueOf(floatCode);
        return code<10? '0'+code : ''+code;
    }


    public class HDT_WRP_QuoteType{
        @AuraEnabled public String quoteType {get;set;}
        @AuraEnabled public String quoteCode {get;set;}
    }


    // @START Alessio Murru Credit Check 07.06.21   
    @AuraEnabled
    public static Order retrieveOrderCreditCheck(String idOrder){
        try {
            return [SELECT Id, IncomingCreditCheckResult__c, OutgoingCreditCheckResult__c, CreditCheckDescription__c
                    FROM Order 
                    WHERE Id = :idOrder
                    WITH SECURITY_ENFORCED];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    // @END Alessio Murru Credit Check 07.06.21   

    //EVERIS
    @AuraEnabled
    public static Integer voltureEffectiveDateCheck(Date effectiveDate){

        Integer successResult = 1;
        Integer failResult = 0;
        Integer result;

        if(effectiveDate < orderSrv.addBusinessDay(System.today(),3) && (FeatureManagement.checkPermission('HDT_CP_VolturaRetroattiva'))){
            result = successResult;
        } else {
            result = failResult;
        }

        return result;

    }

    @AuraEnabled
    public static Order getDates(String recordId){
        Order ord = new Order();
        ord = orderQr.getDates(recordId);

        return ord;
    }
    
    @AuraEnabled
    public static boolean isPreventivo(Order ord){
        
        boolean result;
        List<Order> ords = [SELECT QuotationType__c FROM Order WHERE Id =:ord.Id WITH SECURITY_ENFORCED];
        return result = ( !ords.isEmpty() && ords[0].QuotationType__c != null && !String.isBlank(ords[0].QuotationType__c) )? true:false;

    }
    @AuraEnabled
    public static Boolean checkPermissionSet(){


        if(FeatureManagement.checkPermission('HDT_CP_EnableMUC')){
            return true;
        } 

        return false;

    }

    public static HDT_WRP_VoltureChangeManager.HDT_WRP_ProcessCheck checkTechnicalTransfer(HDT_WRP_VoltureChangeManager.HDT_WRP_TransferCheck trCheck)
    {
        HDT_WRP_VoltureChangeManager.HDT_WRP_ProcessCheck result = new HDT_WRP_VoltureChangeManager.HDT_WRP_ProcessCheck('','');

        String koPers = 'KO_PERSONA_FISICA';
        //String koComp = 'KO_AZIENDA';

        if(String.isBlank(trCheck.firstName) || String.isBlank(trCheck.lastName) || String.isBlank(trCheck.fiscalCode))
        {
            result.result = koPers;
        }
        if(String.isNotBlank(trCheck.companyName) && String.isNotBlank(trCheck.vatNumber))
        {
            if(String.isNotBlank(result.result))
            {
                result.result = '';
            }
        }

        if(String.isNotBlank(result.result))
        {
            result.message = 'Valorizzare i dati del precedente intestatario';
        }

        return result;
    }

}