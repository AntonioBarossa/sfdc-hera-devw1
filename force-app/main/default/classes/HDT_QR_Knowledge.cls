public inherited sharing class HDT_QR_Knowledge {
    

    public List<RecordType> getArticleRecordType(){

        return [SELECT Id, 
        Name 
        FROM RecordType 
        WHERE SobjectType = 'Knowledge__kav'
        WITH SECURITY_ENFORCED
        ];


    }


    public Knowledge__kav getArticleToClone(Id articleId){

        return [SELECT Language, 
        Question__c, 
        Answer__c,
        FlowDiagram__c,
        FlowManagement__c,
        MailArea__c,
        ProblemType__c,
        FirstLevelClassification__c,
        SecondLevelClassification__c,
        OfferedService__c,
        FrontOffice__c,
        CommercialDocumentationType__c,
        FormationDocumentationType__c,
        SalesCompany__c,
        ArticleContent__c,
        MainArticle__c
        FROM Knowledge__kav 
        WHERE Id = :articleId 
        WITH SECURITY_ENFORCED
        LIMIT 1];


    }


    public Knowledge__kav getArticleCreated(String title, string urlName){

        return [SELECT Id 
        FROM Knowledge__kav 
        WHERE Title = :title 
        AND UrlName = :urlName
        WITH SECURITY_ENFORCED
        LIMIT 1
        ];


    }

    public List<Knowledge__DataCategorySelection> getDataCategories(String recordId){
		
        List<Knowledge__DataCategorySelection> dataCategories = new List<Knowledge__DataCategorySelection>();

            
        dataCategories = [SELECT Id, 
        DataCategoryGroupName, 
        DataCategoryName 
        FROM Knowledge__DataCategorySelection 
        WHERE ParentId = :recordId
        WITH SECURITY_ENFORCED
        ];
        
        return dataCategories;
        

    }

    public NewsNotificationCenter__c getRolesToNotificate(List<String> cluster, List<String> channel){

        NewsNotificationCenter__c news = new NewsNotificationCenter__c();

        news = [SELECT Role__c 
        FROM NewsNotificationCenter__c 
        WHERE EntryChannel__c IN :channel
        AND Active__c = true
        /*WHERE Cluster__c IN :cluster
        AND EntryChannel__c IN :channel
        AND Active__c = true*/
        WITH SECURITY_ENFORCED
        LIMIT 1
        ];

        return news;

    }

    public NewsNotificationCenter__c getDuplicateNews(NewsNotificationCenter__c news){

        NewsNotificationCenter__c newsDup = new NewsNotificationCenter__c();
        
        newsDup = [ SELECT Id, 
        Name
        FROM NewsNotificationCenter__c
        WHERE EntryChannel__c = :news.EntryChannel__c
        AND Active__c = true
        /*WHERE Cluster__c = :news.Cluster__c
        AND EntryChannel__c = :news.EntryChannel__c
        AND Active__c = true*/
        WITH SECURITY_ENFORCED
        LIMIT 1
        ];


        return newsDup;

    }


    public List<String> getUserIdToNotificate(List<String> roles){

        List<String> userIds = new List<String>();
        List<User> userList = new List<User>();
        
        userList =[SELECT Id
        FROM User
        WHERE UserRole.Name IN :roles
        WITH SECURITY_ENFORCED];
        
        for(User singleUser : userList){

            userIds.add(singleUser.Id);

        }

        return userIds;
        

    }

    public CustomNotificationType getCustomNotificationType(){

        CustomNotificationType customNotification = new CustomNotificationType();

        customNotification = [SELECT Id
        FROM CustomNotificationType
        WHERE DeveloperName = 'HDT_NewsNotification'
        WITH SECURITY_ENFORCED
        LIMIT 1];

        return customNotification;

    }



}