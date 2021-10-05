@isTest
public class HDT_UTL_NewsNotificationCenterTst {

    @TestSetup
    static void setup(){

        Knowledge__kav kArt = new Knowledge__kav();
        kArt.Title = 'Test Original Title';
        kArt.urlName = 'original';
        kArt.ExpirationDate__c = Date.today()-5;
        insert kArt;

        Knowledge__kav article = [SELECT Id FROM Knowledge__kav LIMIT 1];

        List<Knowledge__DataCategorySelection> artDataCatList = new List<Knowledge__DataCategorySelection>();
        Knowledge__DataCategorySelection artDataCat1 = new Knowledge__DataCategorySelection();
        artDataCat1.DataCategoryGroupName = 'Cluster';
        artDataCat1.DataCategoryName  = 'Disattivazioni';
        artDataCat1.ParentId = article.Id;

        Knowledge__DataCategorySelection artDataCat2 = new Knowledge__DataCategorySelection();
        artDataCat2.DataCategoryGroupName = 'Canale';
        artDataCat2.DataCategoryName  = 'Sportello';
        artDataCat2.ParentId = article.Id;

        artDataCatList.add(artDataCat1);
        artDataCatList.add(artDataCat2);
        insert artDataCatList;

        List<NewsNotificationCenter__c> notificationList = new List<NewsNotificationCenter__c>();
        NewsNotificationCenter__c nc1 = new NewsNotificationCenter__c();
        nc1.Role__c = 'Front Office HERA COMM';
        nc1.Cluster__c = 'Disattivazioni';
        nc1.EntryChannel__c = 'Sportello;Call Center Inbound;SOL e App;Teleselling Outbound;Agenti D2D;Protocollo;Back-office;Chat;Sportello Amministratori Condominio';
        nc1.Active__c = true;

        notificationList.add(nc1);
        insert notificationList;

    }

    @IsTest
    static void testSendNotificationCluster(){

        Knowledge__kav article = [SELECT Id, Title FROM Knowledge__kav WITH SECURITY_ENFORCED LIMIT 1];
        
        Test.startTest();

        String result = HDT_UTL_NewsNotificationCenter.sendNotification(article);

        System.assertEquals(null, result, 'result != null');

        Test.stopTest();
        
    }

    @IsTest
    static void testSendNotificationCanale(){

        Knowledge__kav article = [SELECT Id, Title FROM Knowledge__kav WITH SECURITY_ENFORCED LIMIT 1];
        
        Test.startTest();

        String result = HDT_UTL_NewsNotificationCenter.sendNotification(article);

        System.assertEquals(null, result, 'result != null');

        Test.stopTest();
        
    }

    @IsTest
    static void getArticleRecordType(){
        
        Test.startTest();
        
        HDT_QR_Knowledge k = new HDT_QR_Knowledge();
        List<RecordType> rtList = k.getArticleRecordType();

        System.assert(rtList.size() > 0, 'rtList.size() = 0 or rtList = null');

        Test.stopTest();
        
    }

    @IsTest
    static void getArticleToClone(){

        Knowledge__kav article = [SELECT Id FROM Knowledge__kav WITH SECURITY_ENFORCED LIMIT 1];
        
        Test.startTest();
        
        HDT_QR_Knowledge k = new HDT_QR_Knowledge();
        Knowledge__kav returnedArticle = k.getArticleToClone(article.Id);

        System.assertNotEquals(null, returnedArticle, 'returnedArticle = null');

        Test.stopTest();
        
    }

    @IsTest
    static void getArticleCreated(){
        
        Test.startTest();

        HDT_QR_Knowledge k = new HDT_QR_Knowledge();
        Knowledge__kav returnedArticle = k.getArticleCreated('Test Original Title', 'original');

        System.assertNotEquals(null, returnedArticle, 'returnedArticle = null');

        Test.stopTest();
        
    }

}
