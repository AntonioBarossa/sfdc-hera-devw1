public with sharing class HDT_UTL_VoltureChangeManager {
    
    /*
     *@frpanico 06/10/2021
     *The method takes in input an SObj and a list of extra parameters:
     * A string 'recordTypeId' with the recordTypeId for the new Sobject to be created
     * A set<String> of fields apiName to be excluded
     * The method outputs an SObject cloned from the input SObject excluding indicated fields.   
     */

    public SObject cloneSObject(SObject sobj, Map<String,Object> extraParams)
    {
        SObject newSobj;
        /*@frpanico 07/10/2021*/
        /*Since it has to be used for orderItems too this extra params is unnecessary*/
        /*String recordTypeId = (String)extraParams.get('recordTypeId');*/
        Map<String,Object> populatedFieldMap = sobj.getPopulatedFieldsAsMap();
        Set<String> extraExcludedFields = (Set<String>)extraParams.get('excludedFields');
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

}
