public with sharing class HDT_UTL_VoltureChangeManager {
    
    private static HDT_UTL_VoltureChangeUtilities voltureChangeUtils = new HDT_UTL_VoltureChangeUtilities();
    //private static String lawEightyActivityTemplate = '';
    @TestVisible
    private static String lawEightyPhase = 'In Attesa Legge 80';

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
            'LastModifiedById'
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
        /* Write text fields */
        orderToUpdate.TecnicalPhase__c = (String)fieldsMap.get('FASE');
        orderToUpdate.CausalCode__c = (String)fieldsMap.get('CODERR');
        orderToUpdate.Description = (String)fieldsMap.get('ANNOTAZIONI');
        orderToUpdate.SupplyStreetName__c = (String)fieldsMap.get('VIA');
        orderToUpdate.SupplyStreetNumber__c = (String)fieldsMap.get('CIV');
        orderToUpdate.SupplyPostalCode__c = (String)fieldsMap.get('CAP');
        orderToUpdate.SupplyCityCode__c = (String)fieldsMap.get('ISTAT');
        orderToUpdate.SupplyCity__c = (String)fieldsMap.get('LOCALITA');
        orderToUpdate.SupplyState__c = (String)fieldsMap.get('PROV');
        orderToUpdate.SupplyCountry__c = (String)fieldsMap.get('NAZIONE');
        orderToUpdate.DiscardReason__c = (String)fieldsMap.get('DES_ERR_AEEG');
        orderToUpdate.HerokuPracticeCode__c = (String)fieldsMap.get('COD_PRAT_UTENTE');
        orderToUpdate.DistributorPracticeCode__c = (String)fieldsMap.get('COD_PRAT_DISTR');
        /* Date Fields */
        orderToUpdate.SwitchOutDate__c = fieldsMap.get('DATA_DECORRENZA_SW') != null
            ? Date.valueOf((String)fieldsMap.get('DATA_DECORRENZA_SW'))
            : null;   
        orderToUpdate.EffectiveDate__c = fieldsMap.get('DATA_DECORRENZA_VT_TIT_III') != null
            ? Date.valueOf((String)fieldsMap.get('DATA_DECORRENZA_VT_TIT_III'))
            : null;
        orderToUpdate.EffectiveDate__c = fieldsMap.get('DATA_DECORRENZA_VT_TIT_IV') != null 
            ? Date.valueOf((String)fieldsMap.get('DATA_DECORRENZA_VT_TIT_IV'))
            : null;
        /* Number Fields */
        orderToUpdate.PowerCommitted__c = fieldsMap.get('POTCONTRIMP') != null 
            ? Decimal.valueOf((String)fieldsMap.get('POTCONTRIMP'))
            : null;
        orderToUpdate.PowerAvailable__c = fieldsMap.get('POTDISP') != null 
            ? Decimal.valueOf((String)fieldsMap.get('POTDISP'))
            : null;
        /* Field "TENSIONE" */
        orderToUpdate.VoltageLevel__c = fieldsMap.get('TENSIONE') != null 
            ? voltureChangeUtils.getTension((String)fieldsMap.get('TENSIONE'))
            : null;
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
            istat => currentOrder.SupplyCityCode__c,
            localita => currentOrder.SupplyCity__c,
            provincia => currentOrder.SupplyState__c,
            nazione => currentOrder.SupplyCountry__c
        };

        /* Tension Check */
        if(voltureChangeUtils.getTension(tension) != currentOrder.VoltageLevel__c)
        {
            returnMap.put('message', 'Valori tensione non corrispondenti');
            returnMap.put('result', false);
            return returnMap;
        }
        /* Power Available Check */
        if(!voltureChangeUtils.powerCheck(powerAvailable, String.valueOf(currentOrder.PowerAvailable__c)))
        {
            returnMap.put('message', 'Valori Potenza Disponibile non corrispondenti');
            returnMap.put('result', false);
            return returnMap;
        }
        /* Power Committed Check */
        if(!voltureChangeUtils.powerCheck(powerCommitted, String.valueOf(currentOrder.PowerCommitted__c)))
        {
            returnMap.put('message', 'Valori Potenza Impegnata non corrispondenti');
            returnMap.put('result', false);
            return returnMap;
        }
        /* Address Check */
        if(!voltureChangeUtils.addressCheck(addressCheckMap))
        {
            returnMap.put('message', 'Indirizzi non corrispondenti');
            returnMap.put('result', false);
            return returnMap;
        }
        returnMap.put('message', '');
        returnMap.put('result','');
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

}
