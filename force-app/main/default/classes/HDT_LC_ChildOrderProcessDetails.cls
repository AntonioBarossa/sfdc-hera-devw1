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
    public static void updateProcessStep(Order order,
        //INIZIO SVILUPPI EVERIS 
        Boolean isVolture,
        Boolean isRetroactive,
        Boolean isReading,
        Date readingDate){
        //FINE SVILUPPI EVERIS

        System.debug('updateProcessStep: ' + order);
        System.debug('isVolture: '+isVolture);

        //INIZIO SVILUPPI EVERIS CHECK VOLTURA
        if(isVolture != null && isVolture == true){
            // Order oldOrder = orderQr.getRecordById(order.Id);
            //@frpanico check "Cambio contatore non registrato"
            if(order.NotRegisteredMeterCase__c != null && order.NotRegisteredMeterCase__c == true)
            {
                if(caseQr.getChageNonRegMeterByOrder(order.Id).size() == 0)
                {                
                    throw new AuraHandledException('Necessario completare un Case di \'Cambio Contatore Non Registrato\'');
                }
            }
            //@frpanico check "Tipo Voltura"
            if(order.VoltureType__c != null && String.isBlank(order.VoltureType__c))
            {
                throw new AuraHandledException('Valorizzare campi obbligatori');
            }
            //@frpanico check "Data Decorrenza"
            if(order.EffectiveDate__c != null)
            {
                if(order.EffectiveDate__c < orderSrv.addBusinessDay(System.today(),3))
                {
                    if(!(FeatureManagement.checkPermission('HDT_CP_VolturaRetroattiva')))
                    {
                        throw new AuraHandledException('Impossibile inserire una data inferiore a 3 gg lavorativi');
                    }
                    else if(order.VoltureType__c != null && order.VoltureType__c == 'Recupero' && order.EffectiveDate__c > Date.newInstance(2015, 10, 31))
                    {
                        throw new AuraHandledException('Per Voltura di tipo \"Recupero\" è necessario inserire una data antecedente al 31/10/2015');
                    }
                    else
                    {    
                        order.RetroactiveDate__c = order.EffectiveDate__c;
                        order.Subprocess__c = 'Retroattiva';
                    }
                } 
                else 
                {
                    order.RetroactiveDate__c = null;
                    order.Subprocess__c = 'Standard';
                }
            } 
            //@frpanico check "Voltura con Autolettura"
            if(isReading != null && isReading == true && isRetroactive != null && isRetroactive == false)
            {
                order.Subprocess__c = 'Con Autolettura';
            }
            //@frpanico valorizzazione "Data Lettura"
            if(readingDate != null && (isReading != null && isReading == true))
            {
                order.ReadingCustomerDate__c = readingDate;
            }
        }
        //FINE SVILUPPI EVERIS CHECK VOLTURA 

        // Date tempStart = order.TemporaryConnectionStartDate__c;
        // Date tempEnd = order.TemporaryConnectionEndDate__c;
        // Boolean tempDate = tempEnd < tempStart;

        if(order.TemporaryConnectionStartDate__c != null 
        && order.TemporaryConnectionEndDate__c != null
        && order.TemporaryConnectionEndDate__c < order.TemporaryConnectionStartDate__c){
            throw new AuraHandledException('La data fine connessione temporanea non puo essere precedente alla data inizio!');
        }

        exeChecks(order);

        orderSrv.updateRecord(order);
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
        try {
            List<HDT_CalcoloPreventivi__mdt> metas;

            if(ord.recordType.DeveloperName=='HDT_RT_ConnessioneConAttivazione'){
                //ConnessioneConAttivazione
                metas= [SELECT QuotationType__c, OperationCode__c FROM HDT_CalcoloPreventivi__mdt WHERE Type__c='QuotationType' AND ProcessCode__c=:ord.ProcessCode__c AND RT__c='HDT_RT_ConnessioneConAttivazione' WITH SECURITY_ENFORCED] ;
                wrp.quoteType= metas[0].QuotationType__c; 
                wrp.quoteCode=formatCode(metas[0].OperationCode__c); 
                system.debug(metas);
                return wrp;
            }

            String checkPrPc= getPrPc(ord);
            Decimal power = ord.PowerRequested__c != null ? ord.PowerRequested__c : ord.PowerAvailable__c;
            String powerRange=HDT_UTL_QuoteManagement.getRangeValue(power);

            Boolean isDispatcherInMtd= HDT_UTL_QuoteManagement.checkLocalDispatcher(ord.ServicePoint__r.Distributor__r.Name);
            String distributor = isDispatcherInMtd ? 'InRete' : 'ExtraRete';
                            

            system.debug('RequestPhase '+ord.RequestPhase__c);
            system.debug('ConnectionType__c '+ord.ConnectionType__c);
            system.debug('ProcessCode__c '+ord.ProcessCode__c);
            system.debug('VendDistr__c '+distributor);
            system.debug('PowerRequested__c '+ord.PowerRequested__c);
            system.debug('PowerAvailable__c '+ ord.PowerAvailable__c);
            system.debug('VoltageLevel__c '+ ord.VoltageLevel__c);
            system.debug('PowerCommitted__c '+ ord.PowerCommitted__c);
            system.debug('EnergyUseCase__c '+ord.UseTypeEnergy__c);
            system.debug('PowerRange__c '+powerRange);
            system.debug('ComparePowReq__c '+checkPrPc);
            system.debug('RT '+ord.recordType.DeveloperName);

            if(ord.recordType.DeveloperName=='HDT_RT_TemporaneaNuovaAtt'){
                system.debug('if1 ok');
                metas = [SELECT QuotationType__c, OperationCode__c FROM HDT_CalcoloPreventivi__mdt 
                    WHERE Type__c='QuotationType'
                        AND ProcessCode__c=:ord.ProcessCode__c AND VendDistr__c =:distributor AND VoltageLevel__c =:ord.VoltageLevel__c
                        AND ( EnergyUseCase__c= :ord.UseTypeEnergy__c OR EnergyUseCase__c='')
                        AND PowerRange__c=:powerRange AND ComparePowReq__c=:checkPrPc AND RT__C =:ord.recordType.DeveloperName
                    WITH SECURITY_ENFORCED
                    ORDER BY EnergyUseCase__c NULLS LAST
                ];
            }else if(ord.recordType.DeveloperName=='HDT_RT_AttivazioneConModifica'){
                system.debug('if2 ok');
                metas = [SELECT QuotationType__c, OperationCode__c FROM HDT_CalcoloPreventivi__mdt 
                    WHERE Type__c='QuotationType'
                        AND RequestPhase__c =:ord.RequestPhase__c AND ConnectionType__c=:ord.ConnectionType__c 
                        AND ProcessCode__c=:ord.ProcessCode__c AND VendDistr__c =:distributor AND VoltageLevel__c =:ord.VoltageLevel__c
                        AND ( EnergyUseCase__c= :ord.UseTypeEnergy__c OR EnergyUseCase__c='')
                        AND PowerRange__c=:powerRange AND ComparePowReq__c=:checkPrPc AND RT__C =:ord.recordType.DeveloperName
                    WITH SECURITY_ENFORCED
                    ORDER BY EnergyUseCase__c NULLS LAST
                ];
            }
            system.debug(metas);
            if(!metas?.isEmpty()){
                wrp.quoteType= metas[0].QuotationType__c;  
                // Integer code = Integer.valueOf(metas[0].OperationCode__c);
                wrp.quoteCode=formatCode(metas[0].OperationCode__c);        
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
    //EVERIS
}