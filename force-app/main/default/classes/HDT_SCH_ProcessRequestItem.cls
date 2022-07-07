public without sharing class HDT_SCH_ProcessRequestItem implements Schedulable {
    //private static HDT_UTL_Constants constantsUtl = new HDT_UTL_Constants();--montors fix

    public void execute(SchedulableContext ctx){

        new HDT_SRV_ProcessRequestItem().execute();

        //--montors fix
        //List<MassiveLoaderRequest__c> listmsr = [SELECT Id FROM MassiveLoaderRequest__c WHERE Status__c=:constantsUtl.MASSIVLOADER_STATUS_INATTESAlAVORAZIONE  WITH SECURITY_ENFORCED  ORDER BY CreatedDate DESC LIMIT 10  ];
        //if (listmsr!=null && listmsr.size()>0 ) {
        //    HDT_BA_ProcessRequestItem processReq = new HDT_BA_ProcessRequestItem(listmsr.get(0).id); 
        //    Database.executeBatch(processReq,1);
        //}
    }
}