public inherited sharing class HDT_UTL_Variations {


    public static Boolean consistencyCheck(String recordId, String useCategory, String supplyType, String servicePointType){

        return HDT_QR_Variations.queryConsistencyTable(recordId, useCategory, supplyType, servicePointType);

    }



    @InvocableMethod(label = 'Modifica Tariffa Residente/Non Residente')
    public static List<Boolean> modifyRate(List<HDT_UTL_FlowInputs> inputs){

        List<Boolean> existingCase = new List<Boolean>();

        String caseId = inputs[0].caseId;
        String accountId = inputs[0].accountId;
        String commodity = inputs[0].commodity;
        String servicePointId = inputs[0].servicePointId;

        List<ServicePoint__c> servicePoints = HDT_QR_Variations.queryServicePoint(accountId, commodity, servicePointId);

        List<Id> spIds= new List<Id>();

        for(ServicePoint__c sp : servicePoints){

            spIds.add(sp.Id);

        }


        List<Case> otherCases = HDT_QR_Variations.queryOtherCases(spIds, caseId);

        if(otherCases.size() == 0){

            existingCase.add(false);

        } else {

            existingCase.add(true);

        }

        return existingCase;


    }


    public class HDT_UTL_FlowInputs{

        @InvocableVariable
        public String caseId;

        @InvocableVariable
        public String accountId;

        @InvocableVariable
        public String commodity;

        @InvocableVariable
        public String servicePointId;


    }

}