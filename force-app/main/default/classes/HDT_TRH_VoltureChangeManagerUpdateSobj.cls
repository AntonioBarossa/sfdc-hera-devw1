/**@frpanico 19/10/2021
 * Trigger Handler class for the HDT_VoltureChangeManagerSobj trigger
 */
public with sharing class HDT_TRH_VoltureChangeManagerUpdateSobj extends HDT_TRH_TriggerHandler {


    public override void afterInsert(){
        this.myMethod();
    }


    /**@frpanico 19/10/2021
     * The method runs through platform events HDT_PEV_VoltureChangeManagerUpdateSObj on trigger.new
     * deserialize the sobject from the field SerializedSobj__c and add it to the List<SObject>
     * Update the List<Sobject>
     */
    public void myMethod()
    {
        if(Trigger.new != null && Trigger.new.size() > 0)
        {
            List<HDT_PEV_VoltureChangeManagerUpdateSObj__e> platformEvents =(List<HDT_PEV_VoltureChangeManagerUpdateSObj__e>)Trigger.new;
            List<SObject> sobjectList = new List<SObject>();
            /**@frpanico 28/02/2022
             * Since the Order's trigger happens to run multiple time
             * On the same Record
             * A duplicate prevention has been enabled
             */
            Set<Id> idToUpdate = new Set<Id>();
            for(HDT_PEV_VoltureChangeManagerUpdateSObj__e singleEvent : platformEvents)
            {
                SObject sobj = (SObject)JSON.deserialize(singleEvent.SerializedSobj__c, SObject.class);
                if(!(idToUpdate.contains((String)sobj.get('Id'))))
                {
                    idToUpdate.add((String)sobj.get('Id'));
                    sobjectList.add(sobj);
                }
            }
            if(sobjectList.size() > 0)
            {
                HDT_UTL_DatabaseService.updateSObject(sobjectList);
            }
        }

        return;
    }

}
