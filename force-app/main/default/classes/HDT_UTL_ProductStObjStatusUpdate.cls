public inherited sharing class HDT_UTL_ProductStObjStatusUpdate {
    
    public static void scheduleJob(){
        HDT_SCH_ProductStObjStatusUpdate jobToSched = new HDT_SCH_ProductStObjStatusUpdate();
        // Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
        String sch = '0 0 3 ? * 1,2,3,4,5,6,7';
        String jobID = System.schedule('Product2 Status Update', sch, jobToSched);
    }

}