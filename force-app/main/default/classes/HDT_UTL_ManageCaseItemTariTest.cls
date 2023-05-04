/**
    * @author Angelo Ballacchino (angelo.ballacchino@nttdata.com)
    * @date 10/04/2023
    */
@isTest
private class HDT_UTL_ManageCaseItemTariTest {

    @isTest
    static void testManageCaseItem(){
     
        Case testCase = new Case(
            Subject = 'Test Case',
            Status = 'New'
        );
        insert testCase;

    
        DocumentSelected__c testDocumentSelected = new DocumentSelected__c(
            Name = 'Test Document',
            Case__c = testCase.Id
        );
        insert testDocumentSelected;

    
        CaseItem__c testCaseItem = new CaseItem__c(
            
            DocumentSelected__c = testDocumentSelected.Id,
            Case__c = testCase.Id       
        );
        insert testCaseItem;


        List<String> caseInput = new List<String>{testCase.Id};
        Test.startTest();
        HDT_UTL_ManageCaseItemTari.manageCaseItem(caseInput);
        Test.stopTest();

        CaseItem__c updatedCaseItem = [
            SELECT Id, Status__c
            FROM CaseItem__c
            WHERE Id =: testCaseItem.Id
        ];

  
        System.assertEquals('Active', updatedCaseItem.Status__c, 'CaseItem__c record should remain Active.');

     
        delete testDocumentSelected;


        Test.startTest();
        HDT_UTL_ManageCaseItemTari.manageCaseItem(caseInput);
        Test.stopTest();

   
        CaseItem__c annulledCaseItem = [
            SELECT Id, Status__c
            FROM CaseItem__c
            WHERE Id =: testCaseItem.Id
        ];

     
        System.assertEquals('Annullato', annulledCaseItem.Status__c, 'CaseItem__c record should be annulled.');
    }
}