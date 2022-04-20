@SuppressWarnings('PMD.AvoidDebugStatements, PMD.ClassNamingConventions, PMD.ExcessiveParameterList, PMD.IfElseStmtsMustUseBraces, PMD.IfStmtsMustUseBraces')
public inherited sharing  class HDT_UTL_SIE14 {

    private static final List<String> OPERATORS = new List<String>{'==','!=', 'STARTS', 'NOT STARTS'};
    private static final Pattern PATTERN_OPERATORS = Pattern.compile('([A-Za-z0-9_.]+)[\\xa0\\s]*('+STRING.join(OPERATORS, '|')+')(.+)');
    private static HDT_UTL_Sobject utlSbj = new HDT_UTL_Sobject();

    public class HDT_WRP_SIE14Rule{
        public String segmento;
        String logic;
        Set<String> salesCompany;
        List<HDT_WRP_SIECondition> conditions;

        public HDT_WRP_SIE14Rule(String segmento, List<String> conditions, String logic, String salesCompany){
            this.segmento = segmento;
            //this.conditions = conditions;
            this.conditions= new List<HDT_WRP_SIECondition>();
            if(conditions?.size()>0){
                for(String condition : conditions){
                    this.conditions.add(new HDT_WRP_SIECondition(condition));
                }
            }
            this.logic = logic;
            this.salesCompany = String.isNotBlank(salesCompany)? new Set<String>(salesCompany.toLowerCase().split(';')) : null;
        }
 
        public boolean checkLogic(SObject obj, String company){//Tutte le condizioni sono valutate in "AND"
            if(this.salesCompany?.size() > 0 && !this.salesCompany.contains(company.toLowerCase()))   return false;

            if(this.conditions?.size() > 0){
                for(HDT_WRP_SIECondition condition : this.conditions){
                    String actualValue=utlSbj.dinamicFieldValue(condition.fieldName, obj);
                    if(!condition.checkCondition(actualValue))   return false;
                }
            }
            
            return true;
        }
    }

    class HDT_WRP_SIECondition {

        String fieldName;
        String operator;
        String valueToCheck;

        

        HDT_WRP_SieCondition(String conditionString){
            Matcher matcher=PATTERN_OPERATORS.matcher(conditionString);
            while(matcher.find()){
                this.fieldName=matcher.group(1).toLowerCase().trim();
                this.operator=matcher.group(2).trim();
                this.valueToCheck=matcher.group(3).toLowerCase().trim();
            }
        }

        Boolean checkCondition(String actualValue){
            switch on this.operator {
                when '==' {
                    return checkEqual(actualValue);
                }
                when '!=' {
                    return !checkEqual(actualValue);
                }
                when 'STARTS' {
                    return startsWith(actualValue);
                }
                when 'NOT STARTS' {
                    return !startsWith(actualValue);
                }
                when else {
                    return false;
                }
            }
        }

        Boolean checkEqual(String actualFieldValue) {
            Boolean areStringsEqual=false;
            if ('null'.equalsIgnoreCase(this.valueToCheck)) {//null means "empty string"
                areStringsEqual = String.isBlank(actualFieldValue);
            }
            else if(String.isNotBlank(actualFieldValue)){
                areStringsEqual = actualFieldValue.equalsIgnoreCase( this.valueToCheck );
            }
            return areStringsEqual;
        }

        Boolean startsWith(String actualFieldValue){
            if(STRING.isBlank(this.valueToCheck) && STRING.isBlank(actualFieldValue))    return true;
            if(STRING.isBlank(this.valueToCheck) || STRING.isBlank(actualFieldValue))    return false;
            return actualFieldValue.startsWithIgnoreCase(this.valueToCheck);
        }

    }

    private inherited sharing class HDT_UTL_Sobject extends HDT_UTL_FormatTextScript{
        private String dinamicFieldValue(String fieldPath, SObject relation){
            String retValue = getFieldValue(fieldPath, relation);
            return retValue=='null'? '' : retValue;
        }
    }
}
