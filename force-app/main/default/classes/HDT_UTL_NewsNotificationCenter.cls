public inherited sharing class HDT_UTL_NewsNotificationCenter {

    private static HDT_QR_Knowledge qrKb = new HDT_QR_Knowledge();

    /*
    * @Author: Salvatore A. Sarà 19/10/2021
    * Risoluzione "Debug Should Use Logging Level"
    * Risoluzione "Avoid debug statements since they impact on performance"
    * Risoluzione "Local variable is declared and-or assigned but not used"
    */
    @SuppressWarnings('PMD.AvoidDebugStatements')
    public static String sendNotification(Knowledge__kav article){

        List<String> rolesToNotificate = new List<String>();
        List<String> userToNotificate = new List<String>();
        List<Knowledge__DataCategorySelection> dataCategories = new List<Knowledge__DataCategorySelection>();
        List<NewsNotificationCenter__c> newsList = new List<NewsNotificationCenter__c>();

        Set<String> userSet = new Set<String>();
        Set<String> clusterSet = new Set<String>();
        Set<String> channelSet = new Set<String>();

        String title;
        /*
			@Author: Davide Viola - 20/10/2021
			Description: PMD -> Commentata variabile non utilizzata.
		*/
		//String body;
        String result;
        String rolesString = '';


        try{
            
            dataCategories = qrKb.getDataCategories(article.Id);
		
        } catch(Exception e){

            System.debug(LoggingLevel.DEBUG, e.getMessage());

        }

        if(dataCategories.size() > 0){
        
        
            for(Knowledge__DataCategorySelection dataCategory : dataCategories){
    
                if(dataCategory.DataCategoryGroupName == 'Cluster'){
    
                    clusterSet.add(dataCategory.DataCategoryName);
    
                }else if(dataCategory.DataCategoryGroupName == 'Canale'){
    
                    channelSet.add(dataCategory.DataCategoryName);
    
                }
    
            }

    
            newsList= qrKb.getRolesToNotificate();

            //Populate roleList
            //First checks Cluster form data cateogries and from query
            //Than checks EntryChannel from data categories and from query
            //If all check are succesfully roles are added to list 'rolesToNotificate'
            if(newsList.size() > 0){
                Set<String> tmpCluster = new Set<String>();
                Set<String> tmpChannel = new Set<String>();
                Boolean retainAllResult;
                for(NewsNotificationCenter__c news : newsList){ 
                    tmpCluster = clusterSet;
                    tmpChannel = channelSet;
                    Set<String> returnedCluster = new Set<String>(news.Cluster__c.split(';'));
                    Set<String> returnedChannel = new Set<String>(news.EntryChannel__c.split(';'));
                    retainAllResult = tmpCluster.retainAll(returnedCluster);
                    if((retainAllResult && tmpCluster.size() > 0) || (!retainAllResult)){
                        retainAllResult = tmpChannel.retainAll(returnedChannel);
                        if((retainAllResult && tmpChannel.size() > 0) || (!retainAllResult) || news.EntryChannel__c.containsIgnoreCase('Tutti')){
                            rolesString += news.Role__c;
                        }else{
                            System.debug(LoggingLevel.DEBUG, 'Rule Not Found');
                        }
                    }else{
                        System.debug(LoggingLevel.DEBUG, 'Rule Not Found');
                    }
                    
                }
            
                rolesToNotificate = rolesString.split(';');
        
                userToNotificate = qrKb.getUserIdToNotificate(rolesToNotificate);
        
                userSet.addAll(userToNotificate);
                
                if(!Test.isRunningTest())
                {
                    Id jobId = Database.executeBatch(new HDT_BA_Knowledge(userSet, article.Id, article.Title), 200);
                }
            }
        }
        

        return null;


        }


    public static String fireNotification(String title, String body, String recordId, Set<String> userToNotificate){

        CustomNotificationType notificationType = qrKb.getCustomNotificationType();

        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        
        notification.setTitle(title);
        notification.setBody(body);
        notification.setNotificationTypeId(notificationType.Id);
        notification.setTargetId(recordId);
        notification.send(userToNotificate);

        return null;

    }

    @InvocableMethod(Label = 'Batch Notifiche News')
    public static List<HDT_UTL_FlowOutputs> sendNotificationFromFlow(List<HDT_UTL_FlowInputs> inputs)
    {
        List<HDT_UTL_FlowOutputs> outputs = new List<HDT_UTL_FlowOutputs>();

        Knowledge__kav article = inputs[0].article;
        sendNotification(article);

        return outputs;
    }
    
    public class HDT_UTL_FlowInputs
    {
        @InvocableVariable
        public Knowledge__kav article;
    }
    public class HDT_UTL_FlowOutputs
    {
        @InvocableVariable
        public String output;    
    }


}