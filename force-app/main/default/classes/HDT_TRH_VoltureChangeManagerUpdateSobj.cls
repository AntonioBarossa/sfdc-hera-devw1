/**@frpanico 19/10/2021
 * Trigger Handler class for the HDT_VoltureChangeManagerSobj trigger
 */
public with sharing class HDT_TRH_VoltureChangeManagerUpdateSobj {

    /**@frpanico 19/10/2021
     * The method runs through platform events HDT_PEV_VoltureChangeManagerUpdateSObj on trigger.new
     * deserialize the sobject from the field SerializedSobj__c and add it to the List<SObject>
     * Update the List<Sobject>
     */
    public void run()
    {
        if(Trigger.new != null && Trigger.new.size() > 0)
        {
            List<HDT_PEV_VoltureChangeManagerUpdateSObj__e> platformEvents =(List<HDT_PEV_VoltureChangeManagerUpdateSObj__e>)Trigger.new;
            List<SObject> sobjectList = new List<SObject>();
            for(HDT_PEV_VoltureChangeManagerUpdateSObj__e singleEvent : platformEvents)
            {
                SObject sobj = (SObject)JSON.deserialize(singleEvent.SerializedSobj__c, SObject.class);
                sobjectList.add(sobj);
            }
            if(sobjectList.size() > 0)
            {
                HDT_UTL_DatabaseService.updateSObject(sobjectList);
            }
        }

        return;
    }

}
