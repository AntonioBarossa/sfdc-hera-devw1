/**@frpanico 19/10/2021
 * Trigger for the platform event HDT_PEV_VoltureChangeManagerUpdateSObj__e
 * Runs in after insert
 */
trigger HDT_VoltureChangeManagerSObj on HDT_PEV_VoltureChangeManagerUpdateSObj__e (after insert) 
{
    new HDT_TRH_VoltureChangeManagerUpdateSobj().run();
}