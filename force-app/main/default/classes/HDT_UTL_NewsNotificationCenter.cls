public inherited sharing class HDT_UTL_NewsNotificationCenter {

    private static HDT_QR_Knowledge qrKb = new HDT_QR_Knowledge();

    public static String sendNotification(Knowledge__kav article){

        List<String> clusterCategory = new List<String>();
        List<String> channelCategory = new List<String>();
        List<String> rolesToNotificate = new List<String>();
        List<String> userToNotificate = new List<String>();
        List<Knowledge__DataCategorySelection> dataCategories = new List<Knowledge__DataCategorySelection>();

        Set<String> userSet = new Set<String>();

        String rolesString;
        String title;
        String body;
        String result;


        try{
            
            dataCategories = qrKb.getDataCategories(article.Id);
		
        } catch(Exception e){

            System.debug(e.getMessage());

        }

        if(dataCategories.size() > 0){
        
        
            for(Knowledge__DataCategorySelection dataCategory : dataCategories){
    
                if(dataCategory.DataCategoryGroupName == 'Cluster'){
    
                    clusterCategory.add(dataCategory.DataCategoryName);
    
                }else if(dataCategory.DataCategoryGroupName == 'Canale'){
    
                    channelCategory.add(dataCategory.DataCategoryName);
    
                }
    
            }
    
            rolesString= qrKb.getRolesToNotificate(clusterCategory, channelCategory).Role__c;
    
            rolesToNotificate = rolesString.split(';');
    
            userToNotificate = qrKb.getUserIdToNotificate(rolesToNotificate);
    
            userSet.addAll(userToNotificate);
    
            result = fireNotification(article.Title, 'Una nuova News è stata pubblicata',article.Id, userSet);
            
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