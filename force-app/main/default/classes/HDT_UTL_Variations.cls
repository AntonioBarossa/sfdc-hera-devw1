public inherited sharing class HDT_UTL_Variations {


    public static Boolean consistencyCheck(String recordId, String useCategory, String supplyType, String servicePointType){

        return HDT_QR_Variations.queryConsistencyTable(recordId, useCategory, supplyType, servicePointType);

    }

    public static Boolean modifyRate(String caseId){

        List<Case> otherCases = new List<Case>();

        Boolean check;

        Integer flag = 0;
        Integer count = 0;

        Case currentCase =  HDT_QR_Variations.getCaseInfo(caseId);


        List<ServicePoint__c> servicePoints = HDT_QR_Variations.queryServicePoint(currentCase.AccountId,
            currentCase.CommodityFormula__c, currentCase.ServicePoint__c);

        List<Id> spIds= new List<Id>();

        if(servicePoints.size() > 0){        
            
            for(ServicePoint__c sp : servicePoints){

                spIds.add(sp.Id);

          }

            otherCases = HDT_QR_Variations.queryOtherCases(spIds, caseId);

            if(otherCases.size() == 0){

                check = false;

            } else {

                for(Id spId : spIds){

                    flag = 0;

                    for(Case c : otherCases){

                        if(c.ServicePoint__c == spId){

                            ++flag;

                        }

                    }

                    if(flag > 0){

                        ++count;

                    }

                }

                if(count == spIds.size()){

                    check = true;

                } else {

                    check = false;

                }

            }
        
        }else{

            check = true;

        }

        return check;


    }

}