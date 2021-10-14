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

    /**@frpanico 12/10/2021
     * The method takes in inptu orderId and isRequired to create the Activity
     * Returns the activityId
     * Method actually not necessary since the activity is always created on phase change
     */
    /*
    public String createActivityToOrder(String orderId, Boolean isRequired, String templateName)
    {
        List<wrts_prcgvr__ActivityTemplate__c> activityTemplate = voltureChangeQr.getActivityTemplate(templateName);
        wrts_prcgvr__Activity__c activity = new wrts_prcgvr__Activity__c();
        activity.wrts_prcgvr__ActivityTemplate__c = activityTemplate[0]?.Id;
        activity.wrts_prcgvr__Description__c = templateName;
        activity.wrts_prcgvr__IsRequired__c	= isRequired;
        activity.Order__c = orderId;
        activity.Type__c = templateName;

        HDT_UTL_DatabaseService.insertSObject(activity);

        return activity.Id;
    }
    */

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

}
