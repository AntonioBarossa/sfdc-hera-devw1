@SuppressWarnings('PMD.AvoidGlobalModifier')
global inherited sharing class HDT_SRV_PostSalesCriteriaManager implements wrts_prcgvr.Interfaces_1_2.IApexCriteria {

    HDT_UTL_PostSalesCriteriaManager criteriaUtl = new HDT_UTL_PostSalesCriteriaManager();

    global Boolean evaluate(Object args){

        Map<String, Object> argsMap = (Map<String, Object>) args;

        /*
            @Author: Davide Viola - 20/10/2021
            Description: PMD -> Commentate variabili non utilizzate.
        */
        /*SObject transition = (SObject) argsMap.get('transition');
        SObject action = (SObject) argsMap.get('action');*/
        String method = (String) argsMap.get('method');
        SObject sender = (SObject) argsMap.get('record');

        Boolean result;

        switch on method{
            when 'distributorManagement'{
                result = criteriaUtl.distributorManagement((String)sender.get('PhaseStory__c'));
            }
            when 'secondAdmissibility'{
                result = criteriaUtl.secondAdmissibility((String)sender.get('PhaseStory__c'));
            }
            when 'notExecWorks'{
                result = criteriaUtl.notExecWorks((String)sender.get('PhaseStory__c'));
            }
            when 'isRapidoToAnalitico'
            {
                result = criteriaUtl.isRapidoToAnalitico((String)sender.get('Id'));
            }
            when 'totalResidueNotNull'
            {
                result = criteriaUtl.totalResidueNotNull(sender);
            }
            when 'totalResidueNull'
            {
                result = criteriaUtl.totalResidueNull(sender);
            }
            when 'areActivityOpen'
            {
                result = criteriaUtl.areActivityOpen((String)sender.get('Id'));
            }
        }

        return result;
    }

}
