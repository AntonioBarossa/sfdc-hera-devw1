global inherited sharing class HDT_SRV_SalesCriteriaManager implements wrts_prcgvr.Interfaces_1_2.IApexCriteria {

    HDT_UTL_PostSalesCriteriaManager criteriaUtl = new HDT_UTL_PostSalesCriteriaManager();

    global Boolean evaluate(Object args){

        Map<String, Object> argsMap = (Map<String, Object>) args;

        //SObject transition = (SObject) argsMap.get('transition');
        //SObject action = (SObject) argsMap.get('action');
        String method = (String) argsMap.get('method');
        SObject sender = (SObject) argsMap.get('record');

        Order currentOrd = (Order) sender;
        Boolean result;

        switch on method{

            when 'distributorManagement'{

                result = criteriaUtl.distributorManagement(currentOrd.PhaseStory__c);

            }
            when 'secondAdmissibility'{

                result = criteriaUtl.secondAdmissibility(currentOrd.PhaseStory__c);

            }
            when 'notExecWorks'{

                result = criteriaUtl.notExecWorks(currentOrd.PhaseStory__c);
            
            }

        }

        return result;

    }

}
