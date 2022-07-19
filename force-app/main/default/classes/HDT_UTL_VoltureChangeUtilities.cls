/**@frpanico 12/10/2021
 * Class for small utilities methods
 */
public with sharing class HDT_UTL_VoltureChangeUtilities {
    
    private static HDT_QR_VoltureChangeManager voltureChangeQr = new HDT_QR_VoltureChangeManager();
    //private static String waitingActivityTemplate = '';
    @TestVisible
    private static String waitingPhase = 'Pratica In Attesa';
    @TestVisible
    private static String communicationPhase = 'Comunicazione verso Heroku';
    @TestVisible
    private static Integer btLimit = 1000;
    @TestVisible
    private static Integer mtLimit = 30000;
    /**@frpanico 12/11/2021
     * field not used but can be used if other threshold are included (e.g. AAT)
     */
    @TestVisible
    private static Integer atLimit = 150000;
    @TestVisible
    private static Decimal lowerThreshold = 10.0;
    @TestVisible
    private static Decimal higherThreshold = 30.0;


    /**
     * @frpanico 06/10/2021
     * Added method with @Future to update the record that calls the ProcessClick Action
     * The method takes in input the serialized order
     * Deserialize and update the input order. 
     */
    @Future
    public static void updateOrderFuture(String serializedOrder)
    {
        Order currentOrder = (Order) JSON.deserialize(serializedOrder, Order.class);
        HDT_UTL_DatabaseService.updateSObject(currentOrder);
    }

    /*@frpanico 12/10/2021
     * Calculate next phase for business account
     * Takes in input "Data Decorrenza", "Preavviso di recesso" and "Order Id"
     */
    public HDT_WRP_VoltureChangeManager.HDT_WRP_AccountCheck nextPhaseBusinessAccount(Date effectiveDate, String recess, String orderId)
    {
        HDT_WRP_VoltureChangeManager.HDT_WRP_AccountCheck accountCheck = new HDT_WRP_VoltureChangeManager.HDT_WRP_AccountCheck();

        if(effectiveDate > System.today() || String.isNotEmpty(recess))
        {
            accountCheck.nextPhase = waitingPhase;
            //accountCheck.activityId = createActivityToOrder(orderId, true, waitingActivityTemplate);
        }
        else
        {
            accountCheck.nextPhase = communicationPhase;
            //accountCheck.activityId = '';
        }

        return accountCheck;
    }

    /**@frpanico 14/10/2021 
     * Method that takes the response as input 
     * Returns a Map<String,Object> containing fileds from response
     */
    public Map<String,Object> getFieldsMap(wrts_prcgvr.MRR_1_0.MultiResponse mrrObj)
    {
        Map<String,Object> fieldsMap = new Map<String,Object>();
        for(wrts_prcgvr.MRR_1_0.Field field : mrrObj.responses[0].objects[0].fields)
        {
            fieldsMap.put(field.name, field.value);
        }
        return fieldsMap;
    }

    /**@frpanico 14/10/2021
     * Method that takes in input the tension number returned from the response
     * Returns the string value for the VoltageLevel__c field
     */
    @TestVisible
    private String getTension(Integer tensionNumberValue)
    {
        return tensionNumberValue > 0 && tensionNumberValue < btLimit ? 'BT' /* If Tension value lower than bt limit : BT */ 
            : (btLimit <= tensionNumberValue && tensionNumberValue < mtLimit)
                ? 'MT' /* If tension value between btLimit and mtLimit : MT */
                : tensionNumberValue > mtLimit 
                    ? 'AT' : ''; /* If thension value greater than mtLimit: AT */
    }

    /**@frpanico 26/10/2021
     * Helper method for the get tension to make the Integer.valueOf fails in case of empty string
     */
    public String getTension(String tensionString)
    {
        Integer tensionNumberValue;
        try
        {
            tensionNumberValue = Integer.valueOf(tensionString);
        }
        catch(Exception e)
        {
            tensionNumberValue = -1;
        }
        return getTension(tensionNumberValue);
    } 

    /**@frpanico 21/10/2021
     * Added method to check for the power band
     * takes in input the power in decimal
     * return a string with the power band
     */
    private String getPowerBand(Decimal power)
    {
        return power < 0 ? '' : power <= lowerThreshold ? 'Fascia 1' : power > lowerThreshold && power <= higherThreshold ? 'Fascia 2' : 'Fascia 3';
    }
    /**@frpanico 26/10/2021
     * Helper method for the getPowerBand to make the Decimal.valueOf fails in case of empty string
    */
    public String getPowerBand(String powerString)
    {
        Decimal power;
        try
        {
            power = Decimal.valueOf(powerString);
        }
        catch(Exception e)
        {
            power = -1;
        }
        return getPowerBand(power);
    } 

    /**@frpanico 21/10/2021
     * Method that takes in input the "expected" and "actual" power as strings
     * Returns true if the two power bands are equals
     */
    public Boolean powerCheck(String powerExpected, String powerActual)
    {
        return getPowerBand(powerExpected) == getPowerBand(powerActual);
    }

    /**#@frpanico 25/10/2021
     * Method that performs the Address check
     * Takes in input a Map<String,String>
     * if a key differs from its value 
     * the loop ends and false is returned
     * true is returned otherwise
     * If the field is empty the check should not be performed
     */
    public Boolean addressCheck(Map<String,String> checkMap)
    {
        Boolean result = true;
        for(String field : checkMap.keySet())
        {
            if(String.isNotEmpty(checkMap.get(field)) && field != checkMap.get(field))
            {   
                result = false;
                break;
            }
        }
        return result;
    }

    /**@frpanico 21/10/2021
     * Method that creates an activity object
     * Takes in input the activity template name
     * Returns a wrts_prcgvr__Activity__c object
     */
    public wrts_prcgvr__Activity__c createActivity(String templateName)
    {
        wrts_prcgvr__Activity__c activity = new wrts_prcgvr__Activity__c();
        List<wrts_prcgvr__ActivityTemplate__c> activityTemplates = voltureChangeQr.getActivityTemplateByName(templateName);
        if(activityTemplates.size() > 0)
        {
            activity.wrts_prcgvr__ActivityTemplate__c = activityTemplates[0].Id;
            activity.CausalError__c = templateName;
            activity.wrts_prcgvr__Description__c = templateName;
            activity.Type__c = templateName;
            activity.wrts_prcgvr__IsRequired__c = true;

        }
        return activity;
    }

    /**@frpanico 25/10/2021
     * Method that checks if "Aliquota Iva", "Aliquota Accise" and "Addizionale Regionale" are populated
     * If one of the fields are not populate 
     * "Aliquota Iva" becomes blank
     * "Aliquota Accise" and "Addizionale Regionale" become 0
     */
    public Map<String,Object> checkRates(Map<String,Object> currentRates, Map<String,Object> toUpdateRates)
    {   

        String fieldAliquotaAccise =  String.valueOf(currentRates.get('Commodity__c')).equalsIgnoreCase('Gas') ? 'ExciseGAS__c' : 'ExciseEle__c';
        Map<String, Object> resultMap = new Map<String,Object>();
        /* Rate Declarations */
        String aliquotaIva = String.isNotEmpty((String)toUpdateRates.get('VAT__c')) ? (String)toUpdateRates.get('VAT__c') : (String)currentRates.get('VAT__c');
        String aliquotaAccise = String.isNotEmpty((String)toUpdateRates.get(fieldAliquotaAccise)) ? (String)toUpdateRates.get(fieldAliquotaAccise) : (String)currentRates.get(fieldAliquotaAccise);
        String addizionaleRegionale = String.valueOf(currentRates.get('RegionalAdditional__c'));
        /* If one of the fields are empty, empty all fields */
        if(String.isEmpty(aliquotaIva) || String.isEmpty(aliquotaAccise) || String.isEmpty(addizionaleRegionale))
        {
            resultMap.put('VAT__c', '');
            resultMap.put(fieldAliquotaAccise, '');
            resultMap.put('ExciseRate__c', 0);
            resultMap.put('RegionalAdditional__c', 0);
        }
        /* Else populate all fields with their values and calculate the excise rate */
        else
        {
            resultMap.put('VAT__c', aliquotaIva);
            resultMap.put(fieldAliquotaAccise, aliquotaAccise);
            resultMap.put('ExciseRate__c', voltureChangeQr.getExciseTranscode(aliquotaAccise)[0].Excise__c);
            resultMap.put('RegionalAdditional__c', Decimal.valueOf(addizionaleRegionale));
        }
        return resultMap;
    }

    /**@frpanico 25/10/2021
     * return the picklist value given a condition, an objectName and a fieldName
     * Check for the exception case of the "E_IMPOST" value
     */
    public String getPicklistValue(String condition, String objectName, String fieldName)
    {
        String result = '';

        if(condition.equalsIgnoreCase('E_IMPOST'))
        {
            condition = 'Imposta usi domestici';
        }
        List<PicklistEntry> entryListEle =
        ((SObject) (Type.forName('Schema.' + objectName).newInstance())).getSobjectType().getDescribe().fields.getMap().get(fieldName).getDescribe().getPicklistValues();
        for(PicklistEntry entry : entryListEle){
            // Per non matchare il testo 10% se condition = 10
            if(entry.getValue().containsIgnoreCase(condition + '%')){
                continue;
            }
            if(entry.getValue().containsIgnoreCase(condition)){
                result = entry.getValue();
            }
        }
        
        return result;
    }

    public Date convertDdMmYyyy(String ddmmyyyy)
    {
        List<String> listToConvert = ddmmyyyy.split('/');
        return Date.newInstance(Integer.valueOf(listToConvert[2]), Integer.valueOf(listToConvert[1]), Integer.valueOf(listToConvert[0]));
    }
    public Date convertDdMmYyyyList(String ddmmyyyyList)
    {
        List<String> dateList = ddmmyyyyList.split(',');
        if(!dateList.isEmpty())
        {
            return convertDdMmYyyy(dateList[dateList.size() - 1]);
        }
        return null;
    }
}
