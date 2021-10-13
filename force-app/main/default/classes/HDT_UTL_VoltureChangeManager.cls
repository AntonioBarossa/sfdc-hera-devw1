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
            try
            {
                newSobj.put(field,populatedFieldMap.get(field));
            }
            catch(Exception e)
            {
                continue;
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


}
