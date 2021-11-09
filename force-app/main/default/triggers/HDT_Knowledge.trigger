trigger HDT_Knowledge on Knowledge__kav (before update, after update) {
    
    //HDT_TRH_Knowledge myUpdateHandler = new HDT_TRH_Knowledge();
    //myUpdateHandler.handleUpdate();
    /*
        @Author: Francesco Vitiello - 08/11/2021
        Description: Modifica per aggiunta estensione TriggerHandler
    */
    HDT_TRH_Knowledge myClass = new HDT_TRH_Knowledge();
    myClass.run();
}