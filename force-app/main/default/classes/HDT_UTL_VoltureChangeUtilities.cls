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

    public String getPowerBand(Decimal power)
    {
        return power <= lowerThreshold ? 'Fascia 1' : power > lowerThreshold && power <= higherThreshold ? 'Fascia 2' : 'Fascia 3';
    }

    public Boolean powerCheck(Decimal powerExpected, Decimal powerActual)
    {
        return getPowerBand(powerExpected) == getPowerBand(powerActual);
    }

}
