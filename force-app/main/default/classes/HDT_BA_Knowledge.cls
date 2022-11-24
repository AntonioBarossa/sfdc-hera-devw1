public with sharing class HDT_BA_Knowledge implements Database.Batchable<String>
{

    public Set<String> userSet = new Set<String>();
    public String articleId;
    public String articleTitle;

    public HDT_BA_Knowledge(Set<String> userSet, String articleId, String articleTitle)
    {
        this.userSet = userSet;
        this.articleId = articleId;
        this.articleTitle = articleTitle;
    }

    public Iterable<String> start(Database.BatchableContext bc)
    {
        List<String> scopeList = new List<String>();
        scopeList.addAll(this.userSet);
        return scopeList;
    }
    public void execute(Database.BatchableContext bc, List<String> scope)
    {
        Set<String> userToNotify = new Set<String>();
        for(String singleScope : scope)
        {
            userToNotify.add(singleScope);
        }
        try
        {
            HDT_UTL_NewsNotificationCenter.fireNotification(this.articleTitle, 'Una nuova News è stata pubblicata',this.articleId, userToNotify);
        }
        catch(Exception e)
        {
            /**In the future
             * In case of exception a mail can be sent
             * To users
             */
            System.debug(LoggingLevel.DEBUG, 'Excpetion: ' + e.getMessage());
        }
    }
    public void finish(Database.BatchableContext bc) {
        System.debug(LoggingLevel.DEBUG, 'Finish running the JOB');
    }

}
