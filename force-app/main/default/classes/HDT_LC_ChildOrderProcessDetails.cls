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

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @description Update order process step
    * @param Order order
    * @param Decimal step
    * @param String objectApiName
    * @param SObject objectToUpdate
    */

    public static void createActivityAccise(boolean flagAccise,boolean flagVat,String orderId,String accountId){

        Order o = new Order();
        o.id = orderId;
        o.FacilitationExcise__c = flagAccise;
        o.VATfacilitationFlag__c = flagVat;
        orderSrv.updateRecord(o);
        RecordType rc= rctype.getRecordType('HDT_RT_AttivitaGestionali', 'wrts_prcgvr__Activity__c');
        String res = '';
        ID recTypeId;
        if(rc !=null){
            recTypeId= rc.Id;
        }
        wrts_prcgvr__Activity__c activity= new wrts_prcgvr__Activity__c(order__c = orderId, Account__c= accountId, RecordTypeId= recTypeId, Type__c= 'Iva e Accise da validare');
        System.debug(activity);
        activitySrv.createRecord(activity);
        
    }

    @AuraEnabled
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
            Order oldOrder = orderQr.getRecordById(order.Id);
            //Commentato finche non viene creato campo a DM
            if(order.NotRegisteredMeterCase__c != null && order.NotRegisteredMeterCase__c == true){
                if(caseQr.getChageNonRegMeterByOrder(order.Id).size() == 0){                
                    throw new AuraHandledException('Necessario completare un Case di \'Cambio Contatore Non Registrato\'');
                }
            } else if(order.EffectiveDate__c != null){

                if(order.EffectiveDate__c < orderSrv.addBusinessDay(System.today(),3)){

                    if(!(FeatureManagement.checkPermission('HDT_CP_VolturaRetroattiva'))){

                        throw new AuraHandledException('Impossibile inserire una data inferiore a 3 gg lavorativi');

                    } else{
                        
                        order.RetroactiveDate__c = order.EffectiveDate__c;
                        order.Subprocess__c = 'Retroattiva';

                    }
                } else {

                    order.RetroactiveDate__c = null;
                    order.Subprocess__c = 'Standard';

                }

            } else if(isReading != null && isReading == true && isRetroactive != null && isRetroactive == false){

                order.Subprocess__c = 'Con Autolettura';

            } else if(order.VoltureType__c != null && (order.VoltureType__c.containsIgnoreCase('In Continuità') || order.VoltureType__c.containsIgnoreCase('Recupero'))
                && oldOrder.ServicePoint__r.CommoditySector__c.containsIgnoreCase('Energia Elettrica')){
                    throw new AuraHandledException('Impossibile selezionare il valore \"' + order.VoltureType__c + '\"');
            } //else if((order.VoltureType__c == null || order.VoltureType__c == '') && (order.Step__c == 4 || order.Step__c == 8)){
            //         throw new AuraHandledException('Valorizzare Campi Obbligatori');
            // }

            if(readingDate != null && (isReading != null && isReading == true)){

                order.ReadingCustomerDate__c = readingDate;

            }if(order.VoltureType__c != null && String.isBlank(order.VoltureType__c)){
                throw new AuraHandledException('Valorizzare campi obbligatori');
            }
        }
        //FINE SVILUPPI EVERIS CHECK VOLTURA 

        exeChecks(order);

        orderSrv.updateRecord(order);
    }

    private static void exeChecks(Order order){
        //Check RequestOption__c (Opzione di Distribuzione) START
        if(order.ImplantType__c != null && order.PowerCommitted__c != null){
            orderSrv.checkReadAccess('RequestOption__c');
            Order oldOrder = orderQr.getRecordById(order.Id);

            String calculatedRequestOption = HDT_UTL_OrderFieldsAlignment.calculateRequestedOption(oldOrder.ImplantType__c, oldOrder.PowerCommitted__c);

            if (calculatedRequestOption != oldOrder.RequestOption__c) {
                throw new AuraHandledException('Il campo Opzione di Distribuzione e stato cambiato');
            }
        } else if(order.RequestOption__c != null){
            orderSrv.checkReadAccess('RequestOption__c');
            Order oldOrder = orderQr.getRecordById(order.Id);

            if (order.RequestOption__c != '' && oldOrder.RequestOption__c != null && order.RequestOption__c != oldOrder.RequestOption__c) {
                throw new AuraHandledException('Il campo Opzione di Distribuzione e stato cambiato');
            }
        }
        //Check RequestOption__c (Opzione di Distribuzione) END
    }



   
    /**
    * @description 
    * @author federico.defelice@webresults.it | 01-08-2021 
    * @param ord 
    * @return string 
    **/
    @AuraEnabled
    public static string getQuoteTypeMtd(Order ord){
        system.debug(ord);
        String quoteType;
        try {
            List<HDT_CalcoloPreventivi__mdt> metas;

            if(ord.ProcessCode__c=='PN1'){
                //ConnessioneConAttivazione
                metas= [SELECT QuotationType__c FROM HDT_CalcoloPreventivi__mdt WHERE Type__c='QuotationType' AND ProcessCode__c=:ord.ProcessCode__c WITH SECURITY_ENFORCED] ;
                quoteType= metas[0].QuotationType__c; 
                return quoteType;
            }

            String checkPrPc= getPrPc(ord);
            String powerRange=HDT_UTL_QuoteManagement.getRangeValue(ord.PowerRequested__c);

            Boolean isDispatcherInMtd= HDT_UTL_QuoteManagement.checkLocalDispatcher(ord.ServicePoint__r.Distributor__r.Name);
            String distributor = isDispatcherInMtd ? 'InRete' : 'ExtraRete';
                            

            system.debug('RequestPhase '+ord.RequestPhase__c);
            system.debug('ConnectionType__c '+ord.ConnectionType__c);
            system.debug('ProcessCode__c '+ord.ProcessCode__c);
            system.debug('VendDistr__c '+distributor);
            system.debug('PowerRequested__c '+ord.PowerRequested__c);
            system.debug('PowerAvailable__c '+ ord.PowerAvailable__c);
            system.debug('EnergyUseCase__c '+ord.UseTypeEnergy__c);
            system.debug('PowerRange__c '+powerRange);
            system.debug('ComparePowReq__c '+checkPrPc);

            
            if(ord.ProcessCode__c!='PN1'){            
                metas = [SELECT QuotationType__c FROM HDT_CalcoloPreventivi__mdt 
                    WHERE Type__c='QuotationType'
                        AND RequestPhase__c =:ord.RequestPhase__c AND ConnectionType__c=:ord.ConnectionType__c 
                        AND ProcessCode__c=:ord.ProcessCode__c AND VendDistr__c =:distributor 
                        AND ( EnergyUseCase__c= :ord.UseTypeEnergy__c OR EnergyUseCase__c='')
                        AND PowerRange__c=:powerRange AND ComparePowReq__c=:checkPrPc
                    WITH SECURITY_ENFORCED
                    ORDER BY EnergyUseCase__c DESC
                ];
            }
            if(!metas.isEmpty()){
                quoteType= metas[0].QuotationType__c;     
            }
        } catch (Exception e) {
            system.debug(e.getStackTraceString()+' at line '+e.getLineNumber());
            system.debug(e.getMessage()+' '+e.getCause());
            throw new AuraHandledException(e.getMessage());
        }
        return quoteType;
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