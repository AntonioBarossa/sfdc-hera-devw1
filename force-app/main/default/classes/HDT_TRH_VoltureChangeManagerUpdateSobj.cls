public with sharing class HDT_TRH_VoltureChangeManagerUpdateSobj {

    public void run()
    {
        if(Trigger.new != null && Trigger.new.size() > 0)
        {
            List<HDT_PEV_VoltureChangeManagerUpdateSObj__e> platformEvents =(List<HDT_PEV_VoltureChangeManagerUpdateSObj__e>)Trigger.new;
            List<SObject> sobjectList;
            for(HDT_PEV_VoltureChangeManagerUpdateSObj__e singleEvent : platformEvents)
            {
                sobjectList.add((SObject)JSON.deserialize(singleEvent.SerializedSobj__c, SObject.class));
            }
            if(sobjectList.size() > 0)
            {
                HDT_UTL_DatabaseService.updateSObject(sobjectList);
            }
        }

        return;
    }

}
