/*Author: Edoardo Zanatta
* Date: 18/01/2022
*/

public with sharing class HDT_SCH_SendOrderToSii implements Schedulable{

    public void execute(SchedulableContext ctx) {
        HDT_BA_SendOrderToSii batch = new HDT_BA_SendOrderToSii();
        Database.executebatch(batch, 100);
    }
}
