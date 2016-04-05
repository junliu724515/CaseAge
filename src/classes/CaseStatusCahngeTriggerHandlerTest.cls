@IsTest
public class CaseStatusCahngeTriggerHandlerTest {

    @testSetup static void setupTestdata() {
        
        Case newCase = new Case();
        newCase.Subject = 'Unittest';
        newCase.Status = 'New';
        insert newCase; 
        
        Case testCase = [select Subject, Status from Case where Subject = 'Unittest']; 
        System.assertEquals(testCase.Subject, 'Unittest');
    }
    
    
    
    @IsTest static void testOnAfterInsert(){

        Case[] testCase = [select Subject, CaseNumber, Status, Owner.Name from Case where Subject = 'Unittest'];
        
        CaseStatusChangeTriggerHandler.OnAfterInsert(testCase);
        
        Case_Status_Change__c[] caseStatusChange = [select Name from Case_Status_Change__c where Case__r.Id =:testCase[0].Id];
        
        System.assertEquals(caseStatusChange[0].Name, testCase[0].CaseNumber + ' status: New');
    
    }
    
    
    @IsTest static void testOnAfterUpdate(){

        Map<Id, Case> oldObjectMap = new Map<Id, Case>();
          
        Case[] testCase = [select Subject, CaseNumber, Status, Owner.Name from Case where Subject = 'Unittest'];
        
        Case_Status_Change__c  statusChange = new  Case_Status_Change__c();
        statusChange.Name = testCase[0].CaseNumber + ' status: New';
        statusChange.Case__c = testCase[0].Id;
        statusChange.Status_Name__c = testCase[0].Status;
        statusChange.Set_Time__c = Datetime.now();
        insert statusChange;
        
        testCase[0].Status = 'Escalated';

        Case oldCase = new Case();
        oldCase.Subject ='Unittest';
        oldCase.Status = 'New';
        oldCase.Id=testCase[0].Id;
        oldObjectMap.put(testCase[0].Id, oldCase);

        
        CaseStatusChangeTriggerHandler.OnAfterUpdate(testCase, oldObjectMap);
        
        Case_Status_Change__c[] caseStatusChange = [select Name from Case_Status_Change__c where Case__r.Id=:testCase[0].Id and Change_Time__c = null];
        
        
        System.assertEquals(caseStatusChange[0].Name, testCase[0].CaseNumber + ' from New to Escalated');
    
    }
    
}