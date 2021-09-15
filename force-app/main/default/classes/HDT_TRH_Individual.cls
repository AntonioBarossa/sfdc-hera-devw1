/**
* @author Sabina Levonja (sabina.levonja@dunegroup.it)
* @date 04/06/21
* @description HDT_TRH_Individual
* @history Sabina Levonja – 04/06/21 – created class
*/
public inherited sharing class HDT_TRH_Individual extends HDT_TRH_TriggerHandler{

    public override void beforeInsert(){
        System.debug('HDT_TRH_Individual.beforeInsert');
        HDT_UTL_CompanyOwner.feedCompanyOwner(trigger.new);
        // List<Individual> listIndividual =trigger.new;
        
        // for (Individual temp : listIndividual) {
        //     if ( String.isBlank(temp.ProfilingPrivacy__c)) {
        //         temp.ProfilingPrivacy__c='Non espresso';
        //     }
        //     if ( String.isBlank(temp.MarketingPrivacy__c)) {
        //         temp.MarketingPrivacy__c='Non espresso';
        //     }
        // }
    }
}