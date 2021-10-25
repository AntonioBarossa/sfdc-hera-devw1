/**@frpanico 12/10/2021
 * Class for small utilities methods
 */
public with sharing class HDT_UTL_VoltureChangeUtilities {
    
    private static HDT_QR_VoltureChangeManager voltureChangeQr = new HDT_QR_VoltureChangeManager();
    //private static String waitingActivityTemplate = '';
    @TestVisible
    private static String waitingPhase = '';
    @TestVisible
    private static String communicationPhase = 'Comunicazione verso Heroku';
    @TestVisible
    private static Integer btLimit = 10;
    @TestVisible
    private static Integer mtLimit = 20;
    @TestVisible
    private static Integer atLimit = 30;
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
    public String getTension(Integer tensionNumberValue)
    {
        return tensionNumberValue <= btLimit ? 'BT' /* If Tension value lower than bt limit : BT */ 
            : (btLimit < tensionNumberValue && tensionNumberValue <= mtLimit)
                ? 'MT' /* If tension value between btLimit and mtLimit : MT */
                : tensionNumberValue > mtLimit 
                    ? 'AT' : ''; /* If thension value greater than mtLimit: AT */
    }

    /**@frpanico 21/10/2021
     * Added method to check for the power band
     * takes in input the power in decimal
     * return a string with the power band
     */
    public String getPowerBand(Decimal power)
    {
        return power <= lowerThreshold ? 'Fascia 1' : power > lowerThreshold && power <= higherThreshold ? 'Fascia 2' : 'Fascia 3';
    }

    /**@frpanico 21/10/2021
     * Method that takes in input the "expected" and "actual" power in decimal
     * Returns true if the two power bands are equals
     */
    public Boolean powerCheck(Decimal powerExpected, Decimal powerActual)
    {
        return getPowerBand(powerExpected) == getPowerBand(powerActual);
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
        Map<String, Object> resultMap = new Map<String,Object>();
        /* Rate Declarations */
        String aliquotaIva = String.isNotEmpty((String)toUpdateRates.get('VAT__c')) ? (String)toUpdateRates.get('VAT__c') : (String)currentRates.get('VAT__c');
        String aliquotaAccise = String.isNotEmpty((String)toUpdateRates.get('ExciseEle__c')) ? (String)toUpdateRates.get('ExciseEle__c') : (String)currentRates.get('ExciseEle__c');
        String addizionaleRegionale = String.valueOf(currentRates.get('RegionalAdditional__c'));
        /* If one of the fields are empty, empty all fields */
        if(String.isEmpty(aliquotaIva) || String.isEmpty(aliquotaAccise) || String.isEmpty(addizionaleRegionale))
        {
            resultMap.put('VAT__c', '');
            resultMap.put('ExciseEle__c', '');
            resultMap.put('ExciseRate__c', 0);
            resultMap.put('RegionalAdditional__c', 0);
        }
        /* Else populate all fields with their values and calculate the excise rate */
        else
        {
            resultMap.put('VAT__c', aliquotaIva);
            resultMap.put('ExciseEle__c', aliquotaAccise);
            resultMap.put('ExciseRate__c', voltureChangeQr.getExciseTranscode(aliquotaAccise)[0].Excise__c);
            resultMap.put('RegionalAdditional__c', Decimal.valueOf(addizionaleRegionale));
        }
        return resultMap;
    }
}
