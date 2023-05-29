@SuppressWarnings('PMD.AvoidDebugStatements, PMD.ClassNamingConventions, PMD.ExcessiveParameterList, PMD.IfElseStmtsMustUseBraces, PMD.IfStmtsMustUseBraces, PMD.LocalVariableNamingConventions')
public inherited sharing  class  HDT_UTL_SieXiv {

    private static final List<String> OPERATORS = new List<String>{'==','!=', 'STARTS', 'NOT STARTS'};
    private static final Pattern PATTERN_OPERATORS = Pattern.compile('([A-Za-z0-9_.]+)[\\xa0\\s]*('+STRING.join(OPERATORS, '|')+')(.+)');
    
    private static HDT_UTL_Sobject utlSbj = new HDT_UTL_Sobject();

    private static final String STRING_INDENTED_PATTERN = '\\(([^()]*?)\\)';
    private static final String STRING_LOGIC_PATTERN = '((\\d|true|false)([\\s]+(AND)[\\s]+(\\d|true|false))+)|((\\d|true|false)([\\s]+(OR)[\\s]+(\\d|true|false))+)';
    //group 4 contiene il logic gate, 
    private static final Pattern INDENTED_PATTERN = Pattern.compile(STRING_INDENTED_PATTERN);
    private static final Pattern LOGIC_PATTERN = Pattern.compile(STRING_LOGIC_PATTERN);

    private static final Pattern PATTERN_BOOLEAN = Pattern.compile('true|false');

    public class HDT_WRP_SieXivRule{
        public String segmento;
        String logic;
        Set<String> salesCompany;
        List<HDT_WRP_SieCondition> conditions;

        public HDT_WRP_SieXivRule(String segmento, List<String> conditions, String logic, String salesCompany){
            this.segmento = segmento;
            //this.conditions = conditions;
            this.conditions= new List<HDT_WRP_SieCondition>();
            if(conditions?.size()>0){
                for(String condition : conditions){
                    this.conditions.add(new HDT_WRP_SieCondition(condition));
                }
            }
            this.logic = logic;
            this.salesCompany = String.isNotBlank(salesCompany)? new Set<String>(salesCompany.toLowerCase().split(';')) : null;
        }

        public boolean checkLogic(SObject obj, String company){
            //if(this.salesCompany?.size() > 0 && !this.salesCompany.contains(company.toLowerCase()))   return false;
            return STRING.isBlank(this.logic)? allConditionsAndGate(obj):  checkDynamicLogic(obj);
        }

        private boolean checkDynamicLogic(SObject obj){
            String stringReplaceLogic=this.logic;
            Boolean result = true;
            Matcher match = INDENTED_PATTERN.matcher(this.logic);
            while(match.find()){
                //system.debug('external1 '+match.group(0)+' '+match.group(1));
                
                Matcher logicMatch = LOGIC_PATTERN.matcher(match.group(0));
                while(logicMatch.find()){
                        String gate =String.isNotBlank(logicMatch.group(4))? logicMatch.group(4) : logicMatch.group(9);
                        //system.debug('internal '+logicMatch.group(0)+' '+gate);//gruppo 4 (and) o 9 (or)
                        //logicString=doLogicAndSimplifyExpr(match.group(0), match.group(4));
                        
                        result= checkLogicAndOrGateChain(obj, match.group(0), gate);
                        stringReplaceLogic=result? ' true ' : ' false ';
                        //stringReplaceLogic dovrebbe ricevere il risultato booleano da un metodo che abbiamo scritto per valutare le condizioni booleane. (parte 2 per suggerimenti)
                        //group(0) qui torna una concatenazione di booleani tutti in and o tutti in or (non mischiati),
                        // gate invece contiene l'operatore (and o or) della catena
                    
                        //system.debug(logicMatch.replaceFirst(stringReplaceLogic));
                        logicMatch=LOGIC_PATTERN.matcher(logicMatch.replaceFirst(stringReplaceLogic));
                }
                stringReplaceLogic = match.replaceFirst(stringReplaceLogic);
                match=INDENTED_PATTERN.matcher(stringReplaceLogic);
                //system.debug(stringReplaceLogic);
                //match=indentedPattern.matcher(logicString);
            }

            //Alla fine dei due cicli sopra, mi trovo tutte le operazioni non indentate sulla stessa linea.
            //non mi resta che fare un ultimo match - while con il pattern logico
            //system.debug(stringReplaceLogic);

            match=LOGIC_PATTERN.matcher(stringReplaceLogic);
            while(match.find()){
                String gate =String.isNotBlank(match.group(4))? match.group(4) : match.group(9);
                //system.debug('internal '+match.group(0)+' '+gate);//gruppo 4 (and) o 9 (or)
                //logicString=doLogicAndSimplifyExpr(match.group(0), operator);
                result= checkLogicAndOrGateChain(obj, match.group(0), gate);
                stringReplaceLogic=result? ' true ' : ' false ';
                //stringReplaceLogic dovrebbe ricevere il risultato booleano da un metodo
                //group(0) qui torna una concatenazione di booleani tutti in and o tutti in or (non mischiati),
                // operator invece contiene l'operatore (and o or) della catena
                
                //system.debug(match.replaceFirst(stringReplaceLogic));
                match=LOGIC_PATTERN.matcher(match.replaceFirst(stringReplaceLogic));
            }
            return result;
        }

        private List<String> getIndexes(String booleanChain, String gate){
            return STRING.isBlank(booleanChain)? null :  booleanChain.split(gate);
        }


        private boolean checkLogicAndOrGateChain(SObject obj, String booleanChain, String gate){//Logica AND
            //l'oggetto contiene una lista di condizioni. Se la lista è vuota O se tutte sono vere, torna true.
            //if(!indexes?.size() > 0)     return true;
            List<String> indexes = getIndexes(booleanChain, gate);
            if(!(this.conditions?.size()>0))  return true;//If no conditions, always true
            if(!(indexes?.size() > 0))    return allConditionsAndGate(obj);//if no indexes, all conditions are and evaluated
            //system.debug('indexes present');
            Boolean isAnd = gate.equalsIgnoreCase('AND')? true : false;
            return checkIndexes(obj, indexes, isAnd);
            //Se abbiamo finito il ciclo e siamo in AND, vuoldire che era tutto true e torniamo true.
            //Se abbiamo finito il ciclo e siamo in OR, non c'era neanche un true e torniamo false.
        }

        @TestVisible
        private boolean checkIndexes(SObject obj, List<String> indexes, Boolean isAnd){
            for(String boolOrIndex : indexes){
                String boolOrIndexTrim = boolOrIndex.trim();
                //system.debug('inside for '+boolOrIndexTrim+' '+isAnd);
                if(!boolOrIndexTrim.isNumeric()){
                    if(boolOrIndexTrim!=String.valueOf(isAnd)) return !isAnd;//Condizioni precedentemente valutate, se true in OR o false in AND interrompe
                    if(boolOrIndexTrim==String.valueOf(isAnd)) continue;//Se invece true in AND e false in OR, continua
                }
                //system.debug('here i am '+this.conditions.size()+' '+this.conditions);
                Integer index = Integer.valueOf(boolOrIndexTrim)-1;
                if(!(this.conditions?.size()>index)) return false;//if the logic calls a condition not in the list, it returns false
                HDT_WRP_SieCondition condition = this.conditions.get(index);
                String actualValue=utlSbj.dinamicFieldValue(condition.fieldName, obj);
                //system.debug('check condition');
                if(condition.checkCondition(actualValue) != isAnd)   return !isAnd;
                //Se siamo in AND, Alla prima espressione falsa, il processo si blocca negativamente (short evaluation).
                //Se siamo in OR, alla prima espressione vera il processo si blocca positivamente (short evaluation).
                //Implementato tramite XOR
            }
            //system.debug('endLoop');
            return isAnd;
        }
 
        private boolean allConditionsAndGate(SObject obj){//Tutte le condizioni sono valutate in "AND"
            //if(this.salesCompany?.size() > 0 && !this.salesCompany.contains(company.toLowerCase()))   return false;

            if(this.conditions?.size() > 0){
                for(HDT_WRP_SieCondition condition : this.conditions){
                    String actualValue=utlSbj.dinamicFieldValue(condition.fieldName, obj);
                    if(!condition.checkCondition(actualValue))   return false;
                }
            }
            
            return true;
        }
    }

    @TestVisible
    class HDT_WRP_SieCondition {

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

        /*HDT_WRP_SieCondition(String logicString, Boolean test){

            String STRING_INDENTED_PATTERN = '\\(([^()]*?)\\)';
            String STRING_LOGIC_PATTERN = '((\\d|true|false)([\\s]+(AND)[\\s]+(\\d|true|false))+)|((\\d|true|false)([\\s]+(OR)[\\s]+(\\d|true|false))+)';
            //group 4 contiene il logic gate, 
            Pattern indentedPattern = Pattern.compile(STRING_INDENTED_PATTERN);
            Pattern logicPattern = Pattern.compile(STRING_LOGIC_PATTERN);
            Matcher match = indentedPattern.matcher(logicString);
            while(match.find()){
                //match.usePattern(logicPattern);
                Matcher logicMatch = logicPattern.matcher(match.group(0));
                while(logicMatch.find()){
                    //system.debug(match.group(0)+' '+match.group(4))
                    //logicString=doLogicAndSimplifyExpr(match.group(0), match.group(4));
                }
                //match=indentedPattern.matcher(logicString);
            }
            //match = logicPattern.matcher(logicString);
        }*/

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