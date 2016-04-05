public with sharing class CaseStatusChangeTriggerHandler {

    public static void OnAfterInsert(Case[] newObjects){
        
        List<Case_Status_Change__c> statusChanges = new List<Case_Status_Change__c>();
        
        for (Case newCase: newObjects) {
 
            statusChanges.add(createCaseStatus(newCase, null));
        }
        insert statusChanges;
    }
    
    public static void OnAfterUpdate(Case[] updatedObjects, Map<Id, Case> oldObjectMap){
         
        List<Case_Status_Change__c> statusChanges = new List<Case_Status_Change__c>();
        List<String> oldStatuses = new List<String>();
        List<Id> caseIds = new List<Id>();
        
        for (Case updatedObject: updatedObjects) {
            
            Case oldObject = oldObjectMap.get(updatedObject.Id);    
            if (updatedObject.Status != oldObject.Status) { 
                
                statusChanges.add(createCaseStatus(updatedObject, oldObject));                
                oldStatuses.add(oldObject.Status);
                caseIds.add(updatedObject.Id);
            }
        }
        
        if (caseIds.size()>0) {
           
           List<Case_Status_Change__c> oldStatusChanges = [select Name, Set_Time__c from Case_Status_Change__c where Status_Name__c IN :oldStatuses and Case__c IN :caseIds and Change_Time__c=null];
           BusinessHours bh = [SELECT Id FROM BusinessHours WHERE IsDefault=true];
          
           for (Case_Status_Change__c oldStatusChange: oldStatusChanges) {
                
                // calculate business hours               
                oldStatusChange.Change_Time__c = Datetime.now();
                Double milliseconds = BusinessHours.diff(bh.Id, oldStatusChange.Set_Time__c, oldStatusChange.Change_Time__c);                 
                oldStatusChange.Status_Time__c = (Decimal.valueOf(milliseconds)).Divide((60*60*1000), 2);
                oldStatusChange.Age__c = getAge(milliseconds);
                statusChanges.add(oldStatusChange);
            }
        }
        
        upsert statusChanges;
    
    }
    
    
    private static Case_Status_Change__c createCaseStatus(Case caseObject, Case oldObject){
        
        List<Case> cases = [select CaseNumber, Owner.Name from Case where Id=:caseObject.Id];
        Case_Status_Change__c  statusChange = new  Case_Status_Change__c();
        String name = '';
        statusChange.Case__c = caseObject.Id;
        statusChange.Status_Name__c = caseObject.Status;
        if (cases.size()>0) {
           statusChange.Current_Case_Owner__c = cases.get(0).Owner.Name;
           name = cases.get(0).CaseNumber;
        }
        statusChange.Set_Time__c = Datetime.now();
        if (oldObject != null) {
          statusChange.Status_From__c  = oldObject.Status;
          statusChange.Name = name+' from '+oldObject.Status +' to '+caseObject.Status;
        }
        else {
          statusChange.Name = name+' status: '+caseObject.Status; 
        }
        
        return statusChange;
    }
    
    private static String getAge(Double milliseconds) {
        
        Double duration = milliseconds;
        Double d = Math.floor(duration/86400000); //Get whole days
        duration -= d*86400000;
        Double h = Math.floor(duration/3600000); //Get whole hours
        duration -= h*3600000;
        Double m = Math.floor(duration/60000);
        duration -= m*60000;
        Double s = Math.floor(duration/1000);
        return d.format()+' days '+h.format()+' hours '+ m.format() + ' minutes ' + s.format() +' seconds';
    }
    
    
    
}