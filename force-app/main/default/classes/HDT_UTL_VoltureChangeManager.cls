public with sharing class HDT_UTL_VoltureChangeManager {
    
    private static HDT_UTL_VoltureChangeUtilities voltureChangeUtils = new HDT_UTL_VoltureChangeUtilities();
    private static HDT_SRV_VoltureChangeManager voltureChangeSrv = new HDT_SRV_VoltureChangeManager();
    //private static String lawEightyActivityTemplate = '';
    @TestVisible
    private static String lawEightyPhase = 'In Attesa Legge 80';
    private static HDT_SRV_Order orderSrv = new HDT_SRV_Order();
    private static HDT_QR_Case caseQr = new HDT_QR_Case();

    /*
     *@frpanico 06/10/2021
     *The method takes in input an SObj and a list of extra parameters:
     * The only mandatory extraParameter is the SObject name "sobjName"
     * The method outputs an SObject cloned from the input SObject excluding indicated fields.   
     */

    public SObject cloneSObject(SObject sobj, Map<String,Object> extraParams)
    {
        String sobjName = (String)extraParams.get('sobjName');
        Map<String,Object> populatedFieldMap = sobj.getPopulatedFieldsAsMap();
        Set<String> extraExcludedFields = (Set<String>)extraParams?.get('excludedFields');
        Set<String> defaultExcludedFields = new Set<String>
        {
            'LastModifiedDate', 
            'Id', 
            'SystemModstamp', 
            'Phase__c', 
            'PhaseStory__c', 
            'Status',
            'RecordTypeId',
            'ServiceRequestID__c',
            'CreatedDate',
            'CreatedById',
            'OwnerId',
            'LastModifiedById',
            'DateSentToSII__c'
        };
        SObject newSobj = Schema.getGlobalDescribe().get(sobjName).newSObject();
        /*Assign the correct set<string> to be used for field exclusion*/
        Set<String> excludedFields = defaultExcludedFields;
        if(extraExcludedFields != null && defaultExcludedFields.addAll(extraExcludedFields))
        {
            excludedFields = defaultExcludedFields;
        }
        for(String field : populatedFieldMap.keySet())
        {
            if(!excludedFields.contains(field))
            {
                try
                {
                    newSobj.put(field,populatedFieldMap.get(field));
                }
                catch(Exception e)
                {
                    continue;
                }
            }
        }
        /* Other Defaults */
        /*@frpanico 07/10/2021*/
        /*Other defaults are cannot be used since it has to be used to clone OrderItem too*/
        /*
        newSobj.put('Phase__c','Bozza');
        newSobj.put('Status','New');
        newSobj.put('RecordTypeId', recordTypeId);
        */
        return newSobj;
    }   

    /**
     * @frpanico 12/10/2021
     * Added method that check if the account is "Business" or "Residenziale"
     * takes in input a Map<String,Object>
     * Returns in output the wrapper object
     */
    public HDT_WRP_VoltureChangeManager.HDT_WRP_AccountCheck accountCheck(Map<String,Object> accountCheckParams)
    {
        HDT_WRP_VoltureChangeManager.HDT_WRP_AccountCheck accountCheck = new HDT_WRP_VoltureChangeManager.HDT_WRP_AccountCheck();
        /* Set the accountCheckParams map to be passed to the Utils method */
        String accountType = (String)accountCheckParams.get('accountType');
        String orderId = (String)accountCheckParams.get('orderId');
        Date effectiveDate = String.isNotEmpty(String.valueOf(accountCheckParams.get('dataDecorrenza'))) 
            ? Date.valueOf(accountCheckParams.get('dataDecorrenza'))
            : System.today();
        String recess = String.valueOf(accountCheckParams.get('preavvisoRecesso'));

        /*Calculate the nextPhase and eventually create the activity*/
        switch on accountType
        {
            when 'HDT_RT_Business'
            {
                accountCheck = voltureChangeUtils.nextPhaseBusinessAccount(effectiveDate, recess, orderId);
            }
            when 'HDT_RT_Residenziale'
            {
                accountCheck.nextPhase = lawEightyPhase;
                //accountCheck.activityId = voltureChangeUtils.createActivityToOrder(orderId, true,  lawEightyActivityTemplate);
            }
        }

        return accountCheck;
    }

    public Order handleResponse(Map<String,Object> fieldsMap, Order currentOrder)
    {
        Order orderToUpdate = new Order();
        orderToUpdate.Id = currentOrder.Id;
        /* Handle Result KO */
        if(((String)fieldsMap.get('result')).equalsIgnoreCase('OK'))
        {
            /* Write text fields */
            orderToUpdate.PrecheckResultSII__c = ((String)fieldsMap.get('FASE')).equalsIgnoreCase('Amm. Precheck OK SII') ? 'OK' : 'KO';
            orderToUpdate.TecnicalPhase__c = (String)fieldsMap.get('FASE');
            orderToUpdate.CausalCode__c = (String)fieldsMap.get('CODERR');
            orderToUpdate.Description = (String)fieldsMap.get('ANNOTAZIONI');

            /**@frpanico 26/10/2021
             * Cambio Voltura - RN008 "Voltura con Switch"
            */
            if ('Amm. Precheck OK SII'.equalsIgnoreCase(orderToUpdate.TecnicalPhase__c)){
                voltureChangeSrv.handleAmmissibilityCheck(fieldsMap, currentOrder);
            }

            /*
            if(! string.isBlank((String)fieldsMap.get('VIA')) ){
                orderToUpdate.SupplyStreetName__c = (String)fieldsMap.get('VIA');
            }
            if(! string.isBlank((String)fieldsMap.get('CIV')) ){
                orderToUpdate.SupplyStreetNumber__c = (String)fieldsMap.get('CIV');
            }
            if(! string.isBlank((String)fieldsMap.get('CAP')) ){
                orderToUpdate.SupplyPostalCode__c = (String)fieldsMap.get('CAP');
            }
            if(! string.isBlank((String)fieldsMap.get('ISTAT')) ){
                orderToUpdate.SupplyCityCode__c = (String)fieldsMap.get('ISTAT');
            }
            if(! string.isBlank((String)fieldsMap.get('LOCALITA')) ){
                orderToUpdate.SupplyCity__c = (String)fieldsMap.get('LOCALITA');
            }
            if(! string.isBlank((String)fieldsMap.get('PROV')) ){
                orderToUpdate.SupplyState__c = (String)fieldsMap.get('PROV');
            }
            if(! string.isBlank((String)fieldsMap.get('NAZIONE')) ){
                orderToUpdate.SupplyCountry__c = (String)fieldsMap.get('NAZIONE');
            }
            */
            String discardReason = fieldsMap.containsKey('DES_ERR_AEEG') && String.isNotBlank((String)fieldsMap.get('DES_ERR_AEEG')) ?
                (String)fieldsMap.get('DES_ERR_AEEG') :
                (String)fieldsMap.get('TESTO_ERR');  
            orderToUpdate.DiscardReason__c = HDT_UTL_Accents.removeDiacritics(discardReason);
            orderToUpdate.HerokuPracticeCode__c = (String)fieldsMap.get('COD_PRAT_UTENTE');
            orderToUpdate.DistributorPracticeCode__c = (String)fieldsMap.get('COD_PRAT_DISTR');
            /* Date Fields */
            if( ! string.isBlank((String)fieldsMap.get('DATA_DECORRENZA_SW')) ){
                orderToUpdate.SwitchOutDate__c = voltureChangeUtils.convertDdMmYyyyList((String)fieldsMap.get('DATA_DECORRENZA_SW'));
            }
            if( ! string.isBlank((String)fieldsMap.get('DATA_DECORRENZA_VT_TIT_III')) ){

                orderToUpdate.EffectiveDate__c = voltureChangeUtils.convertDdMmYyyy((String)fieldsMap.get('DATA_DECORRENZA_VT_TIT_III'));

            }

            if(  ! string.isBlank((String)fieldsMap.get('DATA_DECORRENZA_VT_TIT_IV'))){

                orderToUpdate.EffectiveDate__c = voltureChangeUtils.convertDdMmYyyy((String)fieldsMap.get('DATA_DECORRENZA_VT_TIT_IV'));

            }
            
            // if( ! string.isBlank((String)fieldsMap.get('POTCONTRIMP')) ){
            //     orderToUpdate.PowerCommitted__c = Decimal.valueOf((String)fieldsMap.get('POTCONTRIMP'));
            // }
            // /* Number Fields */
            // if( ! string.isBlank((String)fieldsMap.get('POTDISP'))){
            //     orderToUpdate.PowerAvailable__c = Decimal.valueOf((String)fieldsMap.get('POTDISP'));
            // }
            // /* Field "TENSIONE" */
            // if( ! string.isBlank((String)fieldsMap.get('TENSIONE')) ){
            //     orderToUpdate.VoltageLevel__c = voltureChangeUtils.getTension((String)fieldsMap.get('TENSIONE'));
            // }
            
        }
        /* result KO */
        else 
        {
            orderToUpdate.TecnicalPhase__c = 'Comunicazione verso Heroku KO';
            orderToUpdate.Description = (String)fieldsMap.get('errorMessage');
            orderToUpdate.DiscardReason__c = (String)fieldsMap.get('errorMessage');

        }
        return orderToUpdate;
    }
    
    public Map<String,Object> handleAmmissibilityCheck(Map<String,Object> paramsMap, Order currentOrder)
    {
        Map<String,Object> returnMap = new Map<String,Object>();
        /* Tension fields */
        String tension = String.valueOf(paramsMap.get('TENSIONE'));
        /* Power gfields */
        String powerAvailable = String.valueOf(paramsMap.get('POTDISP'));
        String powerCommitted = String.valueOf(paramsMap.get('POTCONTRIMP'));
        /* Address fields */
        String via = String.valueOf(paramsMap.get('VIA'));
        String civico = String.valueOf(paramsMap.get('CIV'));
        String cap = String.valueOf(paramsMap.get('CAP'));
        String istat = String.valueOf(paramsMap.get('ISTAT'));
        String localita = String.valueOf(paramsMap.get('LOCALITA'));
        String provincia = String.valueOf(paramsMap.get('PROV'));
        String nazione = String.valueOf(paramsMap.get('NAZIONE'));
        /* Compose Address map for the address check */
        Map<String, String> addressCheckMap = new Map<String, String>
        {
            via => currentOrder.SupplyStreetName__c,
            civico => currentOrder.SupplyStreetNumber__c,
            cap => currentOrder.SupplyPostalCode__c,
            //istat => currentOrder.SupplyCityCode__c,
            localita => currentOrder.SupplyCity__c,
            provincia => currentOrder.SupplyState__c,
            nazione => currentOrder.SupplyCountry__c
        };

        /**@frpanico 12/11/2021
         * Updated if statements
         * If the field is not present in the response
         * the check should not be performed
         * Address check is done inside the voltureChangeUtils.addressCheck(addressCheckMap) method
         */

        String message = 'Valori non corrispondenti: ';
        List<String> errorMessage = new List<String>();
        List<String> noteList = new List<String>();
        returnMap.put('message', '');
        returnMap.put('result',true);
        /* Tension Check */
        if(String.isNotEmpty(tension) && voltureChangeUtils.getTension(tension) != currentOrder.VoltageLevel__c)
        {
            errorMessage.add('Tensione');
            noteList.add('Tensione: ' + voltureChangeUtils.getTension(tension));
        }
        /* Power Available Check */
        if(String.isNotEmpty(powerAvailable) && !voltureChangeUtils.powerCheck(powerAvailable, String.valueOf(currentOrder.PowerAvailable__c)))
        {
            errorMessage.add('Potenza Disponibile');
            noteList.add('Potenza Disponibile: ' + powerAvailable);
        }
        /* Power Committed Check */
        if(String.isNotEmpty(powerCommitted) && !voltureChangeUtils.powerCheck(powerCommitted, String.valueOf(currentOrder.PowerCommitted__c)))
        {
            errorMessage.add('Potenza Impegnata');
            noteList.add('Potenza Impegnata: ' + powerCommitted);
        }
        /* Address Check */
        if(!voltureChangeUtils.addressCheck(addressCheckMap))
        {
            errorMessage.add('Indirizzo');
            String addressVia = String.isNotBlank(via) ? via + ', ' : '';
            String addressCivico = String.isNotBlank(civico) ? civico + ', ' : '';
            String addressCap = String.isNotBlank(cap) ? cap + ', ' : '';
            String addressIstat = String.isNotBlank(istat) ? istat + ', ' : '';
            String addressLocalita = String.isNotBlank(localita) ? localita + ', ' : '';
            String addressProvincia = String.isNotBlank(provincia) ? provincia + ', ' : '';
            String addressNazione = String.isNotBlank(nazione) ? nazione + ', ' : '';
            String address = addressVia + addressCivico + addressCap + addressIstat + addressLocalita + addressProvincia + addressNazione;
            noteList.add('Indirizzo: ' + address);
        }
        /* Set the error message */
        if(!errorMessage.isEmpty())
        {
            returnMap.put('message',message + String.join(errorMessage,','));
            returnMap.put('note', String.join(noteList,'\n'));
            returnMap.put('result',false);
        }
        return returnMap;
    
    }

    /**@frpanico 25/10/2021
     * Method that enrich a single Sobject
     * Takes in input a map with following values:
     * String posizioni: serialized  List<HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoPosizioni> 
     * String configs: serialized  List<HDT_GenericDataEnrichmentTranscode__mdt>
     * SObject sobj : SObject to enrich
     * commodity : String commodity
     */
    public SObject enrichSobj(Map<String,Object> inputMap)
    {
        /* Get Input Variables */
        List<HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoPosizioni> posizioni = 
            (List<HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoPosizioni>)JSON.deserialize((String)inputMap.get('posizioni'), List<HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoPosizioni>.class);
        List<HDT_GenericDataEnrichmentTranscode__mdt> configs = 
            (List<HDT_GenericDataEnrichmentTranscode__mdt>)JSON.deserialize((String)inputMap.get('configs'), List<HDT_GenericDataEnrichmentTranscode__mdt>.class);
        SObject sobj = (SObject)inputMap.get('sobj');

        for(HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoPosizioni posizione : posizioni)
        {
            for(HDT_GenericDataEnrichmentTranscode__mdt config : configs)
            {
                if(config.SapField__c == posizione.campo && (config.Commodity__c == (String)sobj.get(config.CommodityField__c) || config.Commodity__c == 'NA'))
                {
                    sobj.put(config.SfdcField__c, handleDataEnrichmentConfig(config,posizione));
                }
            }
        }

        return sobj;
    }

    /**@frpanico 25/10/2021
     * Handle single field of the Data Enrichment Response
     * Takes as input the current "config" and the current "posizione"
     */
    @TestVisible
    private Object handleDataEnrichmentConfig(HDT_GenericDataEnrichmentTranscode__mdt config, HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoPosizioni posizione)
    {
        Object result;

        if(String.isNotEmpty(config.Method__c))
        {
            result = methodDispatcher(config, posizione);
        }
        else if(config.IsNumber__c) 
        {
            result = numberDispatcher(Integer.valueOf(config.Precision__c), posizione);
        }
        else
        {
            result = posizione.valore;
        }

        return result;
    }

    /**@frpanico 25/10/2021
     * Dispatch the Method__c field of the Generic Data Enrichment Configurations
     */
    @TestVisible
    private String methodDispatcher(HDT_GenericDataEnrichmentTranscode__mdt config, HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoPosizioni posizione)
    {
        String result = '';

        switch on config.Method__c{
            /* get a picklist value entry */
            when 'getPicklistValue'
            {
                result = voltureChangeUtils.getPicklistValue(posizione.valore, config.ObjectName__c, config.SfdcField__c);
            }
        }
        return result;
    }

    /**@frpanico 25/10/2021
     * Handle number fields from the data enrichment response
     */
    @TestVisible
    private Object numberDispatcher(Integer precision, HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoPosizioni posizione)
    {
        if(precision > 0)
        {
            Decimal decValue = Decimal.valueOf(posizione.valore);
            return decValue.setScale(precision);
        }
        else
        {
            return Integer.valueOf(posizione.valore);    
        }
    }
    /**@frpanico 01/02/2022 
     * Introduced method
     * to perform process check
     * The map contains four key/value pairs
     * ('orderNew',inserted field)
     * ('currentOrder',retrieved order)
     * ('isReading', input booleans)
     * ('isRetroactive', input booleans)
     * ('readingDate', reading date for readings)
    */
    public static HDT_WRP_VoltureChangeManager.HDT_WRP_ProcessCheck processCheck(Map<String,Object> checkMap)
    {
        String message;
        String result='OK';

        Order order = (Order) checkMap.get('orderNew');
        Order currentOrder = (Order) checkMap.get('currentOrder');
        //Boolean isVolture = (Boolean) checkMap.get('isVolture');
        Boolean isReading = (Boolean) checkMap.get('isReading');
        Boolean isRetroactive = (Boolean) checkMap.get('isRetroactive');
        Boolean isUpdateStep = (Boolean) checkMap.get('isUpdateStep');
        Date readingDate = (Date) checkMap.get('readingDate');
        String phase = currentOrder.Phase__c != null?currentOrder.Phase__c:'';
        Boolean isFromEdit = phase.equalsIgnoreCase('Ammissibilità KO') || phase.equalsIgnoreCase('Caricamento Siebel KO')?true:false;

        order.NotRegisteredMeterCase__c = order.NotRegisteredMeterCase__c!=null?order.NotRegisteredMeterCase__c:currentOrder.NotRegisteredMeterCase__c;
        order.VoltureType__c = order.VoltureType__c!=null? order.VoltureType__c: currentOrder.VoltureType__c;
        order.EffectiveDate__c = order.EffectiveDate__c!=null? order.EffectiveDate__c:currentOrder.EffectiveDate__c;
        order.RetroactiveDate__c = order.RetroactiveDate__c!=null? order.RetroactiveDate__c:currentOrder.RetroactiveDate__c;
        order.Subprocess__c = order.Subprocess__c!=null? order.Subprocess__c:currentOrder.Subprocess__c;
        
        if(order.NotRegisteredMeterCase__c == true){
                if(caseQr.getChageNonRegMeterByOrder(order.Id).size() == 0)
                {                
                    message = 'Necessario completare un Case di \'Cambio Contatore Non Registrato\'';
                    result='KO';
                }
            }
            //@frpanico check "Tipo Voltura"
            if( String.isBlank(order.VoltureType__c) )
            {
                message = 'Valorizzare campi obbligatori';
                result='KO';
            }
            /**@frpanico 31/01/2022
             * Aggiunto controllo
             * Su Voltura in Recupero
             */
            if(order.VoltureType__c.equalsIgnoreCase('In continuità_no_addebito') && !currentOrder.ServicePoint__r.CommoditySector__c.equalsIgnoreCase('Gas')){
                message = 'Per poter selezionare \"' + order.VoltureType__c + '\" è necessario un punto di fornitura Gas';
                result='KO';
            }
            /**@frpanico 31/01/2022
             * Aggiunto controllo se
             * In continuita_no_addebito
             * La voltura deve essere gas
             */
            if( order.VoltureType__c.equalsIgnoreCase('Recupero') && order.EffectiveDate__c >= orderSrv.addBusinessDay(System.today(),3))
            {
                message = 'Per poter selezionare \"' + order.VoltureType__c + '\" è necessario inserire una data decorrenza antecedente al 31/08/2015';
                result='KO';
            }
            /* Check Tipo Voltura "In Continuita"/"Recupero" ammesso solo se marcatura entrante/uscente e' "Persona Fisica"/"Persona Giuridica" */
            if(order.VoltureType__c.containsIgnoreCase('In Continuità'))
            {
                if(currentOrder.PreviousCustomer__r.Account.CustomerMarking__c != currentOrder.Account.CustomerMarking__c || !currentOrder.Account.CustomerMarking__c.containsIgnoreCase('Persona Fisica'))
                {
                    message = 'Per Voltura \"' + order.VoltureType__c + '\", entrambi i clienti (uscente ed entrante) devono essere \"Persone Fisiche\"';
                    result='KO';
                }
            }
            else if( order.VoltureType__c.equalsIgnoreCase('Incorporazione societaria') )
            {
                if(currentOrder.PreviousCustomer__r.Account.RecordType.DeveloperName != currentOrder.Account.RecordType.DeveloperName
                    || !currentOrder.Account.RecordType.DeveloperName.containsIgnoreCase('HDT_RT_Business'))
                {
                    message = 'Per Voltura \"' + order.VoltureType__c + '\", entrambi i clienti (uscente ed entrante) devono essere \"Persone Giuridiche\"';
                    result='KO';
                }
            }
            //@frpanico check "Data Decorrenza"
            /**@frpanico 12/11/2021
             * Update check VoltureType "Recupero" the date has been changed to 2015/08/31
             */
            if(isUpdateStep != null && isUpdateStep == true &&  order.EffectiveDate__c != null && !isFromEdit)
            {
                if(!currentOrder.ServicePoint__r.CommoditySector__c.equalsIgnoreCase('Acqua') && order.EffectiveDate__c < orderSrv.addBusinessDay(System.today(),3))
                {
                    if(!(FeatureManagement.checkPermission('HDT_CP_VolturaRetroattiva')))
                    {
                        message = 'Impossibile inserire una data inferiore a 3 gg lavorativi';
                        result='KO';
                    }
                    else if( order.VoltureType__c == 'Recupero' && order.EffectiveDate__c > Date.newInstance(2015, 08, 31))
                    {
                        message = 'Per Voltura di tipo \"Recupero\" è necessario inserire una data antecedente al 31/08/2015';
                        result='KO';
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
                //AF inserito per ribaltare campi da Reading__c a Order
                if(currentOrder.ServicePoint__r.CommoditySector__c.equalsIgnoreCase('Gas')){
                    HDT_QR_SelfReadings qrReading = new HDT_QR_SelfReadings();
                    try {
                        Reading__c selfRead = qrReading.getReading('Order',order.Id,'Gas','ReadingValueMeter__c,ReadingSerialNumberCorrector__c,ReadingValueCorrector__c');
                        order.ReadingValueMeter__c = selfRead.ReadingValueMeter__c;
                        order.ReadingValueCorrector__c = selfRead.ReadingValueCorrector__c;
                        order.ReadingSerialNumberCorrector__c = selfRead.ReadingSerialNumberCorrector__c;
                    } catch (Exception ex) {
                        //no record
                    }
                }
                
                order.ReadingCustomerDate__c = readingDate;
            }

        HDT_WRP_VoltureChangeManager.HDT_WRP_ProcessCheck wrp = new HDT_WRP_VoltureChangeManager.HDT_WRP_ProcessCheck(result,message,(SObject)order);
        return wrp;
    }
    /**@frpanico 2022-05-16
     * Annullamento Voltura Tecnica a Seguito di Annullmento SwitchIn
     * Defect 3112
     */
    public static void cancelTechnicalVolture(List<Order> switchOrders)
    {
        Set<String> orderIds = new Set<String>();
        Map<Id, String> orderMapPhase = new Map<Id, String>();
        for(Order switchOrder: switchOrders)
        {    
            if(switchOrder.ProcessType__c != null && switchOrder.Phase__c != null && 
                !((String)switchOrder.get('ProcessType__c')).equalsIgnoreCase('Switch in Gas') && !((String)switchOrder.get('Phase__c')).equalsIgnoreCase('Annullato'))
            {
                continue;
            }
            orderIds.add(switchOrder.Id);
        }
        for(Order o : switchOrders)
        {
            if(orderMapPhase.get(o.Id) == null && orderIds.contains(o.Id))
            {
                orderMapPhase.put(o.Id, o.Phase__c);
            }
        }
        /* If OrderIds are empty 
        * exits the methos to prevent
        * querying unwanted
        */
        if(orderIds.isEmpty())
        {
            return;
        }
        List<Case> techincalVoltures = [SELECT Id, Phase__c,Status, Order__c FROM Case WHERE Type = 'Voltura Tecnica' AND Order__c IN :orderIds WITH SECURITY_ENFORCED];
        if(!techincalVoltures.isEmpty())
        {
            for(Case c : techincalVoltures)
            {
                /* Check aggiuntivo per assicurarsi che l'order sia effettivamente in fase annullato */
                if(c.Order__c != null && orderMapPhase.get(c.Order__c) != null && orderMapPhase.get(c.Order__c).equalsIgnoreCase('Annullato'))
                {
                    c.Phase__c = 'Annullato';
                    c.Status = 'Closed';
                    c.CancellationNote__c = 'Annullato a seguito di annullamento Switch correlato in fase ' + orderMapPhase.get(c.Order__c);
                }
            }
            HDT_UTL_DatabaseService.updateSObject(techincalVoltures);
        }
    }

}