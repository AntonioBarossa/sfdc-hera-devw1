public inherited sharing class HDT_UTL_ProductStObjStatusUpdate {
    /*
    * @Author: Salvatore A. Sarà 19/10/2021
    * Risoluzione "Local variable is declared and-or assigned but not used"
    */
    @SuppressWarnings('PMD.UnusedLocalVariable')
    public static void scheduleJob(){
        HDT_SCH_ProductStObjStatusUpdate jobToSched = new HDT_SCH_ProductStObjStatusUpdate();
        // Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
        String sch = '0 0 3 ? * 1,2,3,4,5,6,7';
        String jobId = System.schedule('Product2 Status Update', sch, jobToSched);
    }

}