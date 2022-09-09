public with sharing class HDT_UTL_RestCallRespBodyLogUtility {
    @SuppressWarnings('PMD.AvoidDebugStatements')
    public static Boolean mustSetBody(String namedCredential, String path){
        try{
            path = String.isNotBlank(path) ? path.replace(' ','_').toLowerCase() : '';
            namedCredential = String.isNotBlank(namedCredential)? namedCredential : '';
            Set<String> checkPathRequest = new Set<String>();
            List<HDT_RestCalloutResponseBodyLog__mdt> restCalloutPathLog = !Test.isRunningTest() ? 
                HDT_RestCalloutResponseBodyLog__mdt.getAll().values()
                : new List<HDT_RestCalloutResponseBodyLog__mdt>{
                    new HDT_RestCalloutResponseBodyLog__mdt(Label = 'Test 1' , DeveloperName = 'Test1', NamedCredential__c = 'Test1', PathRequest__c = 'Test 1'),
                    new HDT_RestCalloutResponseBodyLog__mdt(Label = 'Test 2' , DeveloperName = 'Test2', NamedCredential__c = 'Test1', PathRequest__c = ''),
                    new HDT_RestCalloutResponseBodyLog__mdt(Label = 'Test 3' , DeveloperName = 'Test3', NamedCredential__c = 'Test2', PathRequest__c = 'Test 2  ;   Test 3')
                };
            
            for (HDT_RestCalloutResponseBodyLog__mdt pathLog : restCalloutPathLog){
                if (namedCredential.equalsIgnoreCase(pathLog.NamedCredential__c) && String.isNotBlank(pathLog.PathRequest__c)){
                    for (String singlePath : pathLog.PathRequest__c.split(';')){
                        checkPathRequest.add(String.isBlank(singlePath)? '' : singlePath.trim().replace(' ', '_').toLowerCase());
                    }
                }else if (namedCredential.equalsIgnoreCase(pathLog.NamedCredential__c)){
                    checkPathRequest.add('');
                }
            }
            System.debug(LoggingLevel.info, '@@@checkPathRequest ' + checkPathRequest + ' path '+path + ' namedCredential ' + namedCredential);
            return checkPathRequest.contains(path);
        }catch (Exception e){
            System.debug(LoggingLevel.ERROR, e.getMessage()+ ' line: '+ e.getLineNumber() );
            return false;
        }
        
    }

}
