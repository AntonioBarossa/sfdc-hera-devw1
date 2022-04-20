public with sharing class HDT_UTL_TestConditions {
    

    //private List<String> conditions;
    private String salesCompany;
    //private String Logic;
    private List<HDT_WRP_ScriptCondition> conditions;

    public HDT_UTL_TestConditions(list<String> conds, String company) {
        //this.conditions=conds;
        this.conditions= new List<HDT_WRP_ScriptCondition>();
        this.salesCompany=company;
        for(String cond : conds){
            this.conditions.add(new HDT_WRP_ScriptCondition(cond));
        }
    }

    //'SBQQ__Order__r.Sale__r.CommercialId__c STARTS AGSMECON'


    public class HDT_WRP_ScriptCondition{

        public String fieldName;
        public String operator;
        public String valueToCheck;

        private static final List<String> OPERATORS = new List<String>{'==','!=','NOT LIKE','LIKE', 'STARTS'};
        private static final Pattern PATTERN_OPERATORS = Pattern.compile('([A-Za-z0-9_.]+)('+STRING.join(OPERATORS, '|')+')(.+)');

        public HDT_WRP_ScriptCondition(String conditionString){
            Matcher matcher=PATTERN_OPERATORS.matcher(conditionString);
            while(matcher.find()){
                this.fieldName=matcher.group(1).toLowerCase().trim();
                this.operator=matcher.group(2).toLowerCase().trim();
                this.valueToCheck=matcher.group(3).toLowerCase().trim();
            }
        }

        public Boolean checkCondition(String actualValue){
            switch on OPERATORS {
                when 'ugug' {
                    return checkEqual(actualValue);
                }
                when else {
                    return false;
                }
            }
        }

        private Boolean checkEqual(String actualFieldValue) {
            Boolean areStringsEqual;
            if ('null'.equalsIgnoreCase(valueToCheck)) {//null means "empty string"
                areStringsEqual = String.isBlank(actualFieldValue);
            }
            else {
                areStringsEqual = actualFieldValue.equalsIgnoreCase( valueToCheck );
            }
            return areStringsEqual;
        }

    }
}
