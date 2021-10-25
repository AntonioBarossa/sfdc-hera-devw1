/**
 * @description       : Wrappers for Script CB
 * @author            : gabriele.rota@webresults.it
 * @group             : WR
 * @last modified on  : 2021-10-22
 * @last modified by  : gabriele.rota@webresults.it
**/
public with sharing class HDT_UTL_ScriptWrappers {

    public class HDT_WRP_ScriptOutput{
        @AuraEnabled public string sectionLabel;
        @AuraEnabled public string sectionText;
        @AuraEnabled public String type;
        @AuraEnabled public Decimal nextSection;
        @AuraEnabled public List<HDT_WRP_ScriptDecision> decisions;

        private final List<Schema.SObjectField> DECISION_FIELDS = new List<Schema.SObjectField>{
            ScriptConfig__c.LabelOption1__c,
            ScriptConfig__c.LabelOption2__c,
            ScriptConfig__c.LabelOption3__c
        };

        public HDT_WRP_ScriptOutput(ScriptConfig__c section, String text, String additionalLabel){
            sectionLabel = section.SectionLabel__c+additionalLabel;
            sectionText = text;
    
            if (section.isSet('ScriptType__c')) {
                type = (String)section.get('ScriptType__c');
            }
    
            if (section.isSet('NextSection__c')) {
                nextSection = (Decimal)section.get('NextSection__c');
            }
    
            readDecisions(section);
        }

        public HDT_WRP_ScriptOutput(ScriptConfig__c section){
            if (section.isSet('NextSection__c')) {
                nextSection = (Decimal)section.get('NextSection__c');
            }
        }

        private void readDecisions(ScriptConfig__c section) {
            decisions = new List<HDT_UTL_ScriptWrappers.HDT_WRP_ScriptDecision>();
            for (Schema.SObjectField decisionField:DECISION_FIELDS) {
                if (section.isSet(decisionField)) {
                    String decision = (String)section.get(decisionField);
                    if (String.isNotBlank(decision)) {
                        decisions.add(new HDT_WRP_ScriptDecision(decision));
                    }
                }
            }
        }
    }

    public class HDT_WRP_ScriptDecision{
        @AuraEnabled public String label;
        @AuraEnabled public Integer targetPage;

        public HDT_WRP_ScriptDecision(String decision) {
            List<String> decisionSplit = decision.split('::');
            label = decisionSplit[0];
            targetPage = Integer.valueOf( decisionSplit[1] );
        }
    }

    public class HDT_WRP_ScriptCondition{

        public String fieldName;
        public String operator;
        public String valueToCheck;

        private final List<String> OPERATORS = new List<String>{'==','!=','NOT LIKE','LIKE'};

        public HDT_WRP_ScriptCondition(String condition) {
            for (String operatorLoop:OPERATORS) {
                if (condition.contains(operatorLoop)) {
                    operator = operatorLoop;
                    break;
                }
            }
            
            List<String> arraySingleCondition = condition.split(operator);
            fieldName = arraySingleCondition[0].trim();
            valueToCheck = arraySingleCondition[1].trim();
        }

        public Boolean checkCondition(String actualFieldValue) {
            switch on operator {
                when '==' {
                    return checkEqual(actualFieldValue);
                }
                when '!=' {
                    return !checkEqual(actualFieldValue);
                }
                when 'LIKE' {
                    return checkLike(actualFieldValue);
                }
                when 'NOT LIKE' {
                    return !checkLike(actualFieldValue);
                }
            }
            return false;
        }

        public Boolean checkEqual(String actualFieldValue) {
            Boolean areStringsEqual;
            if ('null'.equalsIgnoreCase(valueToCheck)) {//null means "empty string"
                areStringsEqual = String.isBlank(actualFieldValue);
            }
            else {
                areStringsEqual = actualFieldValue.equalsIgnoreCase( valueToCheck );
            }
            return areStringsEqual;
        }

        public Boolean checkLike(String actualFieldValue) {
            return actualFieldValue.containsIgnoreCase(valueToCheck);
        }
    }
}
