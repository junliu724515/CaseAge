trigger CaseStatusChangeTrigger on Case (after insert, after update) {

    if(Trigger.isInsert && Trigger.isAfter){
        CaseStatusChangeTriggerHandler.OnAfterInsert(Trigger.new);
    } 
    else if (Trigger.isUpdate && Trigger.isAfter) {
        CaseStatusChangeTriggerHandler.OnAfterUpdate(Trigger.new, Trigger.oldMap);
    }

}