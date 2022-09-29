@SuppressWarnings('PMD.ClassNamingConventions, PMD.IfElseStmtsMustUseBraces, PMD.IfStmtsMustUseBraces')
public with sharing class HDT_LC_TariReimbursmentFormFlow{

    @AuraEnabled
    public static List<RimborsoOptionsByCity> getRimborsoOptionsByCity() {
        List<RimborsoOptionsByCity> result = new List<RimborsoOptionsByCity>();
    
        List<CityReimbursmentType__c> typeList = [
            SELECT Id, City__c, ReimbursmentType__c, BeneficiaryType__c
            FROM CityReimbursmentType__c
            WITH Security_Enforced
        ];

        for(CityReimbursmentType__c curType : typeList){
            RimborsoOptionsByCity resultItem = new RimborsoOptionsByCity();
            resultItem.city = curType.City__c;
            resultItem.reimbursementTypes = new List<String>();
            resultItem.beneficiaryTypes = new List<String>();

            List<String> retypes = curType.ReimbursmentType__c != null ? curType.ReimbursmentType__c.split(';') : new List<String>();
            List<String> betypes = curType.BeneficiaryType__c != null ? curType.BeneficiaryType__c.split(';') : new List<String>();

            for(String curRType : retypes) resultItem.reimbursementTypes.add(curRType);
            for(String curBType : betypes) resultItem.beneficiaryTypes.add(curBType);

            result.add(resultItem);
        }
        system.debug('>>getReimbursementOptionsByCity result: ' + JSON.serializePretty(result));
        return result;
    }

    public class RimborsoOptionsByCity {
    
        @AuraEnabled
        public String city;

        @AuraEnabled
        public List<String> reimbursementTypes;
    
        @AuraEnabled
        public List<String> beneficiaryTypes;
    }
}