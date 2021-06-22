/**
* This factory class is used to instantiate concrete class
* of respective support type
* */
public without sharing class HDT_UTL_CaseValidationFactory {
    public static HDT_UTL_CaseValidationInterface getInstance(String validationClass){
        Type t = Type.forName(validationClass);
        HDT_UTL_CaseValidationInterface retVal = (HDT_UTL_CaseValidationInterface)t.newInstance();
        return retVal;
    }
}