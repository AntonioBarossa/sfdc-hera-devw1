public inherited sharing class HDT_UTL_NewsNotificationCenter {

    private static HDT_QR_Knowledge qrKb = new HDT_QR_Knowledge();

    public static String sendNotification(Knowledge__kav article){

        List<String> rolesToNotificate = new List<String>();
        List<String> userToNotificate = new List<String>();
        List<Knowledge__DataCategorySelection> dataCategories = new List<Knowledge__DataCategorySelection>();
        List<NewsNotificationCenter__c> newsList = new List<NewsNotificationCenter__c>();

        Set<String> userSet = new Set<String>();
        Set<String> clusterSet = new Set<String>();
        Set<String> channelSet = new Set<String>();

        String title;
        String body;
        String result;
        String rolesString = '';


        try{
            
            dataCategories = qrKb.getDataCategories(article.Id);
		
        } catch(Exception e){

            System.debug(e.getMessage());

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
                            System.debug('Rule Not Found');
                        }
                    }else{
                        System.debug('Rule Not Found');
                    }
                    
                }
            
                rolesToNotificate = rolesString.split(';');
        
                userToNotificate = qrKb.getUserIdToNotificate(rolesToNotificate);
        
                userSet.addAll(userToNotificate);
        
                result = fireNotification(article.Title, 'Una nuova News è stata pubblicata',article.Id, userSet);
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


}