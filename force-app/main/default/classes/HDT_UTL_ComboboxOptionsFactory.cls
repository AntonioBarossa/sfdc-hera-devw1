public with sharing class HDT_UTL_ComboboxOptionsFactory {
    public static HDT_UTL_ComboboxOptionsInterface getInstance(String serviceClass){
        Type t = Type.forName(serviceClass);
        HDT_UTL_ComboboxOptionsInterface retVal = (HDT_UTL_ComboboxOptionsInterface)t.newInstance();
        return retVal;
    }
}