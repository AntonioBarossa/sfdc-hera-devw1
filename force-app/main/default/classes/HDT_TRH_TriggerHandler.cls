/**
* @author Lorenzo (lorenzo.gulotta@webresults.it)
* @date 13/02/2021
* @description HDT_TRH_TriggerHandler
* @history Lorenzo – 13/02/2021 – created class
*/
public virtual class HDT_TRH_TriggerHandler {

  @TestVisible
  private static final String JOLLY_CHAR = '*';
  @TestVisible
  private static final String LIST_SEPARATOR = ';';

  // static map of handlername, times run() was invoked
  private static Map<String, HDT_TRH_LoopCount> loopCountMap;
  private static Set<String> bypassedHandlers;

  @TestVisible
  private static Map<String,HDT_AutomationToggle__mdt> disabilitationMap;

  // the current context of the trigger, overridable in tests
  @TestVisible
  private TriggerContext context;

  // the current context of the trigger, overridable in tests
  @TestVisible
  private Boolean isTriggerExecuting;

  // static initialization
  static {
    loopCountMap = new Map<String, HDT_TRH_LoopCount>();
    bypassedHandlers = new Set<String>();

    //existing records are not considered during testing
    disabilitationMap = Test.isRunningTest() ? new Map<String,HDT_AutomationToggle__mdt>() : HDT_AutomationToggle__mdt.getAll();
  }
  
  // constructor
  public HDT_TRH_TriggerHandler() {
    this.setTriggerContext();
  }

  /***************************************
   * public instance methods
   ***************************************/

  // main method that will be called during execution
  public void run() {

    if(!validateRun()) {
      return;
    }

    addToLoopCount();

    // dispatch to the correct handler method
    if(this.context == TriggerContext.BEFORE_INSERT) {
      this.beforeInsert();
    } else if(this.context == TriggerContext.BEFORE_UPDATE) {
      this.beforeUpdate();
    } else if(this.context == TriggerContext.BEFORE_DELETE) {
      this.beforeDelete();
    } else if(this.context == TriggerContext.AFTER_INSERT) {
      this.afterInsert();
    } else if(this.context == TriggerContext.AFTER_UPDATE) {
      this.afterUpdate();
    } else if(this.context == TriggerContext.AFTER_DELETE) {
      this.afterDelete();
    } else if(this.context == TriggerContext.AFTER_UNDELETE) {
      this.afterUndelete();
    }

  }

  public void setMaxLoopCount(Integer max) {
    String handlerName = getHandlerName();
    if(!HDT_TRH_TriggerHandler.loopCountMap.containsKey(handlerName)) {
      HDT_TRH_TriggerHandler.loopCountMap.put(handlerName, new HDT_TRH_LoopCount(max));
    } else {
      HDT_TRH_TriggerHandler.loopCountMap.get(handlerName).setMax(max);
    }
  }

  public void clearMaxLoopCount() {
    this.setMaxLoopCount(-1);
  }

  /*************************************** 
   * public static methods
   ***************************************/

  public static void bypass(String handlerName) {
    HDT_TRH_TriggerHandler.bypassedHandlers.add(handlerName);
  }

  public static void clearBypass(String handlerName) {
    HDT_TRH_TriggerHandler.bypassedHandlers.remove(handlerName);
  }

  public static Boolean isBypassed(String handlerName) {
    return HDT_TRH_TriggerHandler.bypassedHandlers.contains(handlerName);
  }

  public static void clearAllBypasses() {
    HDT_TRH_TriggerHandler.bypassedHandlers.clear();
  }

  /***************************************
   * private instancemethods
   ***************************************/

  @TestVisible
  private void setTriggerContext() {
    this.setTriggerContext(null, false);
  }

  @TestVisible
  private void setTriggerContext(String ctx, Boolean testMode) {
    if(!Trigger.isExecuting && !testMode) {
      this.isTriggerExecuting = false;
      return;
    } else {
      this.isTriggerExecuting = true;
    }
    
    if((Trigger.isExecuting && Trigger.isBefore && Trigger.isInsert) ||
        (ctx != null && ctx == 'before insert')) {
      this.context = TriggerContext.BEFORE_INSERT;
    } else if((Trigger.isExecuting && Trigger.isBefore && Trigger.isUpdate) ||
        (ctx != null && ctx == 'before update')){
      this.context = TriggerContext.BEFORE_UPDATE;
    } else if((Trigger.isExecuting && Trigger.isBefore && Trigger.isDelete) ||
        (ctx != null && ctx == 'before delete')) {
      this.context = TriggerContext.BEFORE_DELETE;
    } else if((Trigger.isExecuting && Trigger.isAfter && Trigger.isInsert) ||
        (ctx != null && ctx == 'after insert')) {
      this.context = TriggerContext.AFTER_INSERT;
    } else if((Trigger.isExecuting && Trigger.isAfter && Trigger.isUpdate) ||
        (ctx != null && ctx == 'after update')) {
      this.context = TriggerContext.AFTER_UPDATE;
    } else if((Trigger.isExecuting && Trigger.isAfter && Trigger.isDelete) ||
        (ctx != null && ctx == 'after delete')) {
      this.context = TriggerContext.AFTER_DELETE;
    } else if((Trigger.isExecuting && Trigger.isAfter && Trigger.isUndelete) ||
        (ctx != null && ctx == 'after undelete')) {
      this.context = TriggerContext.AFTER_UNDELETE;
    }
  }

  // increment the loop count
  @TestVisible
  private void addToLoopCount() {
    String handlerName = getHandlerName();
    if(HDT_TRH_TriggerHandler.loopCountMap.containsKey(handlerName)) {
      Boolean exceeded = HDT_TRH_TriggerHandler.loopCountMap.get(handlerName).increment();
      if(exceeded) {
        Integer max = HDT_TRH_TriggerHandler.loopCountMap.get(handlerName).max;
        throw new HDT_TRH_TriggerHandlerException('Maximum loop count of ' + String.valueOf(max) + ' reached in ' + handlerName);
      }
    }
  }

  // make sure this trigger should continue to run
  @SuppressWarnings('PMD.AvoidDebugStatements')
  @TestVisible
  private Boolean validateRun() {
    if(!this.isTriggerExecuting || this.context == null) {
      throw new HDT_TRH_TriggerHandlerException('Trigger handler called outside of Trigger execution');
    }
    if(HDT_TRH_TriggerHandler.bypassedHandlers.contains(getHandlerName())) {
      return false;
    }
    if (isAutomationDisabled(getHandlerName())) {
      System.debug(LoggingLevel.DEBUG, 'Trigger Disabled');
      return false;
    }
    else {
      System.debug(LoggingLevel.DEBUG, 'Trigger Running');
    }
    return true;
  }

  @TestVisible
  private String getHandlerName() {
    return String.valueOf(this).substring(0,String.valueOf(this).indexOf(':'));
  }

  /**
  * @description Check if current trigger run has been disabled by Custom Metadata Type
  * @author gabriele.rota@webresults.it | 2021-10-28 
  * @return Boolean 
  **/
  @TestVisible
  private Boolean isAutomationDisabled(String handlerName) {
    if (!disabilitationMap.containsKey(handlerName)) {
      //no disabilitations defined for current trigger
      return false;
    }

    HDT_AutomationToggle__mdt toggleMd = disabilitationMap.get(handlerName);
    return isMatchingEvent(toggleMd) && isMatchingUser(toggleMd) && isBeforeDueDate(toggleMd);
  }

  /**
  * @description Check if current trigger event (before insert, after update ...) is disabled
  * @author gabriele.rota@webresults.it | 2021-10-28 
  * @param toggleMd  
  * @return Boolean 
  **/
  private Boolean isMatchingEvent(HDT_AutomationToggle__mdt toggleMd) {
    if (toggleMd.SkipEvents__c == JOLLY_CHAR) {
      return true;
    }

    if (String.isNotBlank(toggleMd.SkipEvents__c)) {
      String contextName = this.context.name();
      for (String event:toggleMd.SkipEvents__c.split(LIST_SEPARATOR)) {
        //' before insert ' -> 'BEFORE_INSERT'
        String disabledEvent = event.trim().toUpperCase().replace(' ','_');
        if (contextName == disabledEvent) {
          return true;
        }
      }
    }
    return false;
  }

  /**
  * @description Check if current trigger is disabled for the running user
  * @author gabriele.rota@webresults.it | 2021-10-28 
  * @param toggleMd  
  * @return Boolean 
  **/
  private Boolean isMatchingUser(HDT_AutomationToggle__mdt toggleMd) {
    if (toggleMd.SkipUsernames__c == JOLLY_CHAR) {
      return true;
    }

    if (String.isNotBlank(toggleMd.SkipUsernames__c)) {
      String username = UserInfo.getUserName();
      for (String usernameLoop:toggleMd.SkipUsernames__c.split(LIST_SEPARATOR)) {
        if (username.equalsIgnoreCase(usernameLoop.trim())) {
          return true;
        }
      }
    }
    return false;
  }

  /**
  * @description Check if current trigger disabilitation is expired
  * @author gabriele.rota@webresults.it | 2021-10-28 
  * @param toggleMd  
  * @return Boolean 
  **/
  private Boolean isBeforeDueDate(HDT_AutomationToggle__mdt toggleMd) {
    if (toggleMd.SkipDueDateTime__c == null) {
      return true;
    }
    else {
      return (Datetime.now() < toggleMd.SkipDueDateTime__c);
    }
  }

  /***************************************
   * context methods
   ***************************************/

  // context-specific methods for override
  @TestVisible
  protected virtual void beforeInsert(){
    return;
  }
  @TestVisible
  protected virtual void beforeUpdate(){
    return;
  }
  @TestVisible
  protected virtual void beforeDelete(){
    return;
  }
  @TestVisible
  protected virtual void afterInsert(){
    return;
  }
  @TestVisible
  protected virtual void afterUpdate(){
    return;
  }
  @TestVisible
  protected virtual void afterDelete(){
    return;
  }
  @TestVisible
  protected virtual void afterUndelete(){
    return;
  }

  /***************************************
   * inner classes
   ***************************************/

  // inner class for managing the loop count per handler
  @TestVisible
  private class HDT_TRH_LoopCount {
    private Integer max;
    private Integer count;

    public HDT_TRH_LoopCount() {
      this.max = 5;
      this.count = 0;
    }

    public HDT_TRH_LoopCount(Integer max) {
      this.max = max;
      this.count = 0;
    }

    public Boolean increment() {
      this.count++;
      return this.exceeded();
    }

    public Boolean exceeded() {
      if(this.max < 0) {
        return false;
      }
      if(this.count > this.max) {
        return true;
      }
      return false;
    }

    public Integer getMax() {
      return this.max;
    }

    public Integer getCount() {
      return this.count;
    }

    public void setMax(Integer max) {
      this.max = max;
    }
  }

  // possible trigger contexts
  @TestVisible
  private enum TriggerContext {   
    BEFORE_INSERT, BEFORE_UPDATE, BEFORE_DELETE,
    AFTER_INSERT, AFTER_UPDATE, AFTER_DELETE,
    AFTER_UNDELETE
  }

  // exception class
  public class HDT_TRH_TriggerHandlerException extends Exception {}

}