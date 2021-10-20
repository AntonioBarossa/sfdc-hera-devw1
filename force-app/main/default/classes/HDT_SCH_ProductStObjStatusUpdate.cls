public inherited sharing class HDT_SCH_ProductStObjStatusUpdate implements Schedulable {

    /*
    * @Author: Salvatore A. Sarà 20/10/2021
    * Risoluzione "Local variable is declared and-or assigned but not used"
    * La variabile serve a contenere l'id restituito dall'esecuzione del batch 
    */
    @SuppressWarnings('PMD.UnusedLocalVariable')
    public void execute(SchedulableContext ctx){
        HDT_BA_ProductStObjStatusUpdate executeBatch = new HDT_BA_ProductStObjStatusUpdate();
        /*
            @Author: Davide Viola - 19/10/2021
            Description: PMD -> Commentata variabile non utilizzata.
        */
        /*Id batchId = */Database.executeBatch(executeBatch);
    }

}