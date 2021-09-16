@isTest
public with sharing class HDT_SRV_DocumentalManagementFacadeTst {
    
    //DEBUG
    public static final String TEST_NAME = 'HDT_SRV_DocumentalManagementFacadeTst';
    
    //DATA
    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();
    
    
    
    
    //TEST SETUP
    
    
    
    //TESTS
    
    //sendDocument
    @isTest
    public static void sendDocumentTest(){
        
        //DEBUG
        
        
        //SETUP
        
        
        
        //PREPARAZIONE ARGOMENTI
        String context = 'DocumentazioneAnticipata';//se non lo è, cambia codice
        
        Map<String,Object> formParams = new Map<String,Object>();
        String formParamsJSON = JSON.serialize(formParams);
        
        
        //TESTING
        HDT_SRV_DocumentalManagementFacade.sendDocument('', context, formParamsJSON);
        
        
        //RETRIEVING DATA
        
        
        
        //ASSERTS
        
        
        
        
    }
    
    
    //sendDocumentAsync
    
    
    
    //sendAdvanceDocumentation
    
    @isTest
    private static void sendAdvanceDocumentation() {
        //MOCK TEST
        
    }
    
    
    
    //getSignSendMode
    
    
    
    //getInfoAccountStatement
    
    
    
    //showOriginalDocument
    
    
    
    //showArchivedAttachment
    
    
    
    //resendDocusignEnvelope
    
    
    
    //discardDocusignEnvelope
    
    
    
    //handleDocusignNotify
    
    
    
    
}
