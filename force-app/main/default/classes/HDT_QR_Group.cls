public with sharing class HDT_QR_Group {
   public Group getQueueByDevelopername(String Developername){
        Group g = [Select id from Group where type = 'Queue' AND Developername = :developername];
        return g;
   }
}
