@IsTest
public with sharing class HDT_BA_KnowledegeTst
{

    @TestSetup
    static void setup()
    {
        /** Insert knowledge Article */
        Knowledge__kav kArt = new Knowledge__kav();
        kArt.Title = 'Test Original Title';
        kArt.urlName = 'original';
        insert kArt;
    }    
    @isTest
    static void executeTst()
    {
        List<Knowledge__kav> article = [SELECT Id, Title FROM Knowledge__kav];
        List<User> userList = [SELECT Id FROM User LIMIT 200];
        Set<String> userSet = new Set<String>();
        for(User u : userList)
        {
            userSet.add(u.Id);
        }
        Test.startTest();
            Id jobId = Database.executeBatch(new HDT_BA_Knowledge(userSet, article[0].Id, article[0].Title), 500);
        Test.stopTest();
        System.assertEquals(true, String.isNotEmpty(jobId), 'Job Fallito');
    }
}
