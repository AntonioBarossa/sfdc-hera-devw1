/**@frpanico 19/10/2021
 * Trigger for the platform event HDT_PEV_VoltureChangeManagerUpdateSObj__e
 * Runs in after insert
 */
trigger HDT_VoltureChangeManagerUpdateSobjEvt on HDT_PEV_VoltureChangeManagerUpdateSObj__e (after insert) 
{
    //new HDT_TRH_VoltureChangeManagerUpdateSobj().myMethod();
    /*
        @Author: Francesco Vitiello - 09/11/2021
        Description: Modifica per aggiunta estensione TriggerHandler
    */
    HDT_TRH_VoltureChangeManagerUpdateSobj myClass = new HDT_TRH_VoltureChangeManagerUpdateSobj();
    myClass.run();
}