public inherited sharing class HDT_SRV_IndemnityConfirmation {

    @InvocableMethod(label = 'Check Conferma Indennizzo')
    public static List<HDT_UTL_FlowOutputs> checkIndemnityConfirmation(List<HDT_UTL_FlowInputs> inputs){

        HDT_QR_IndemnityConfirmation indemnityQr = new HDT_QR_IndemnityConfirmation();
        HDT_QR_Case caseQr = new HDT_QR_Case();

        List<Case> cases = new List<Case>();
        List<HDT_UTL_FlowOutputs> outputs = new List<HDT_UTL_FlowOutputs>();
        HDT_UTL_FlowOutputs output = new HDT_UTL_FlowOutputs();

        //Boolean flag = false;
        

        String recordId = inputs[0].recordId;
        String accountId = inputs[0].accountId;
        String servicePointId = inputs[0].servicePointId;
        String firstLevel = inputs[0].firstLevel;
        String secondLevel = inputs[0].secondLevel;
        String note = inputs[0].note;
        Boolean isContainer = inputs[0].isContainer;

        if(isContainer != null && isContainer)
        {
            List<Case> childCaseToUpdate = new List<Case>();
            /* Get All child Cases */
            List<Case> childCases = caseQr.getChildCasesReclamo(note, recordId);
            /**Edge case
             * If there are no child cases
             * No indemnity
             */
            if(childCases.isEmpty())
            {
                output.indemnityNotConfirmed = true;
                outputs.add(output);
                return outputs;
            }
            /* Build sets for the query */
            Set<String> servicePointSet = new Set<String>();
            Set<String> firstLevelSet = new Set<String>();
            Set<String> secondLevelSet = new Set<String>();
            for(Case c : childCases)
            {
                servicePointSet.add(c.ServicePoint__c);
                firstLevelSet.add(c.FirstLevelComplaintClassification__c);
                secondLevelSet.add(c.SecondLevelComplaintClassification__c);
            }
            /* Excute the query to find cases with Cluster__c "Indennizzo" with same account, servicepoint, first level and second level */
            List<Case> targetCase = indemnityQr.getOtherIndemnityCases(recordId, accountId, servicePointSet, firstLevelSet, secondLevelSet);
            /* Check Indemnity Confirmation.
            * If true no update required 
            * (default value for the field is false)
            */
            for(Case c : childCases)
            {
                if(!calculateIndemnityNotConfirmed(c, targetCase))
                {
                    Case caseToUpdate = new Case();
                    caseToUpdate.Id = c.Id;
                    caseToUpdate.IndemnityConfirmed__c = true;
                    childCaseToUpdate.add(caseToUpdate);
                }
            }
            if(!childCaseToUpdate.isEmpty())
            {
                HDT_UTL_DatabaseService.updateSObject(childCaseToUpdate);
            }
            /* Creare List<String> con i servicepoints, firstLevel, secondLevel */
            /* Interrogare i case con quei valori */
            /* Ciclare sulla Lista ritornata */
            /* Determinare per ogni case se l'indennizzo e' confermato*/
            /* update child cases */
        }
        else
        {
            cases = indemnityQr.getOtherIndemnityCases(recordId, accountId, servicePointId, firstLevel, secondLevel);
            output.indemnityNotConfirmed = cases.size() > 0;
            outputs.add(output);
        }
        return outputs;

    }

    /* Takes in input the case to test and testCases
    * Compares first ServicePoint__c
    * Then FirstLevelComplaintClassification__c
    * Then SecondLevelComplaintClassification__c
    * If all checks pass returns true
    * returns false in any other case
    * If the targetCase.FirstLevelComplaintClassification__c == Richiesta di Informazioni return true
    */
    @TestVisible
    private static Boolean calculateIndemnityNotConfirmed(Case targetCase, List<Case> checkingCases)
    {
        Boolean result = false;
        if(String.isBlanK(targetCase.FirstLevelComplaintClassification__c) || targetCase.FirstLevelComplaintClassification__c.equalsIgnoreCase('Richiesta di Informazioni'))
        {
            return true;
        }
        for(Case check : checkingCases)
        {
            if(targetCase.ServicePoint__c != check.Parent.ServicePoint__c)
            {
                continue;
            }
            if(!targetCase.FirstLevelComplaintClassification__c.equalsIgnoreCase(check.Parent.FirstLevelComplaintClassification__c))
            {
                continue;
            }
            if(!targetCase.SecondLevelComplaintClassification__c.equalsIgnoreCase(check.Parent.SecondLevelComplaintClassification__c))
            {
                continue;
            }
            result = true;
            break;
        }
        return result;
    }

    public class HDT_UTL_FlowInputs{

        @InvocableVariable
        public String recordId;

        @InvocableVariable
        public String accountId;

        @InvocableVariable
        public String servicePointId;

        @InvocableVariable
        public String firstLevel;

        @InvocableVariable
        public String secondLevel;

        @InvocableVariable
        public String note;

        @InvocableVariable
        public Boolean isContainer;

    }

    public class HDT_UTL_FlowOutputs{

        @InvocableVariable
        public Boolean indemnityNotConfirmed;

    }
}