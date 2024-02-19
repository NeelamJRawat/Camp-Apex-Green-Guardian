global with sharing class AssignTask {

global static void setStartDate(List<CAMPX__Garden__c> newList){
	for(CAMPX__Garden__c grd:newList){
		if(grd.CAMPX__Manager__c!=null)
		{
			grd.CAMPX__Manager_Start_Date__c = system.today();
		}else
		{
			grd.CAMPX__Manager_Start_Date__c = null;
		}
	}
}
global static void assignTask(List<CAMPX__Garden__c> newList) {
	List <Task> TaskList = new List<Task>();
	if(newList != null && !newList.isEmpty()) {
		for(Integer i = 0; i < newList.size(); i++) {
			if(newList[i].CAMPX__Manager__c != null) {
				Task t = new Task();
				t.subject = 'Acquire Plants';
				t.OwnerId = newList[i].CAMPX__Manager__c;
				t.WhatId = newList[i].Id;
				TaskList.add(t);
			}
		}
	}
	if(!TaskList.isEmpty()) {
		insert TaskList;
	}
}



global static void reassignTask(List<CAMPX__Garden__c> newList, List<CAMPX__Garden__c> OldList) {
	List<Task> taskListToUpdate = new List<Task>();
	List<Task> taskListToDelete = new List<Task>();

	Map<Id, CAMPX__Garden__c> newGardenMap = new Map<Id, CAMPX__Garden__c>(newList);
	Map<Id, CAMPX__Garden__c> oldGardenMap = new Map<Id, CAMPX__Garden__c>(OldList);
	for(CAMPX__Garden__c grd:newList){
		CAMPX__Garden__c oldGardenRecord1 = oldGardenMap.get(grd.id);
		if(grd.CAMPX__Manager__c!=null && oldGardenRecord1.CAMPX__Manager__c==null)
		{
			Task t = new Task();
			t.subject = 'Acquire Plants';
			t.OwnerId = grd.CAMPX__Manager__c;
			t.WhatId = grd.Id;
			taskListToUpdate.add(t);
		}
	}

	for (Task taskRecord : [SELECT Id, OwnerId, WhatId FROM Task WHERE WhatId IN :newGardenMap.keySet() and status !='Completed']) {
		CAMPX__Garden__c newGardenRecord = newGardenMap.get(taskRecord.WhatId);
		CAMPX__Garden__c oldGardenRecord = oldGardenMap.get(taskRecord.WhatId);
		if (newGardenRecord.CAMPX__Manager__c != null && oldGardenRecord.CAMPX__Manager__c != null
		    && newGardenRecord.CAMPX__Manager__c != oldGardenRecord.CAMPX__Manager__c
		    && taskRecord.OwnerId == oldGardenRecord.CAMPX__Manager__c) {
			taskRecord.OwnerId = newGardenRecord.CAMPX__Manager__c;
			taskListToUpdate.add(taskRecord);
		}else if (newGardenRecord.CAMPX__Manager__c == null && oldGardenRecord.CAMPX__Manager__c != null
		          && taskRecord.OwnerId == oldGardenRecord.CAMPX__Manager__c)
		{
			taskListToDelete.add(taskRecord);
		}
	}

	if (!taskListToUpdate.isEmpty()) {
		Upsert taskListToUpdate;
	}
	if (!taskListToDelete.isEmpty()) {
		delete taskListToDelete;
	}
}

}